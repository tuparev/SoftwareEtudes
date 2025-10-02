//
//  FileDispatcher.swift
//  SoftwareEtudes
//
//  Created by Ani Klekchyan Work on 03.07.25.
//

import Foundation
import SoftwareEtudesCoreMessageDispatching

/// Thread-safe file operations actor with buffering
private actor FileActor {
    private let fileURL: URL
    private var fileHandle: FileHandle
    private let maxFileSize: UInt64
    private let maxBackupCount: Int
    private var lastSizeCheck: Date             = Date()
    private let sizeCheckInterval: TimeInterval = 1.0 // Check size at most once per second
    
    // Buffering for performance
    private var buffer: [String]                = []
    private let maxBufferSize: Int              = 50
    private let flushInterval: TimeInterval     = 2.0
    private var lastFlush: Date                 = Date()
    
    // Prevent concurrent rotation
    private var isRotating: Bool                = false
    
    init(fileURL: URL, maxFileSize: UInt64, maxBackupCount: Int) throws {
        self.fileURL        = fileURL
        self.maxFileSize    = maxFileSize
        self.maxBackupCount = maxBackupCount
        
        let fileManager     = FileManager.default
        if !fileManager.fileExists(atPath: fileURL.path) {
            fileManager.createFile(atPath: fileURL.path, contents: nil, attributes: nil)
        }
        self.fileHandle     = try FileHandle(forWritingTo: fileURL)
        try self.fileHandle.seekToEnd()
    }
    
    func writeEntry(_ entry: String) throws {
        // Add to buffer
        buffer.append(entry)
        
        // Flush if buffer is full or enough time has passed
        let now       = Date()
        if buffer.count >= maxBufferSize || now.timeIntervalSince(lastFlush) >= flushInterval {
            try flushBuffer()
            lastFlush = now
        }
    }
    
    
    private func flushBuffer() throws {
        guard !buffer.isEmpty else { return }
        
        // Performance optimisation: only check file size periodically
        if Date().timeIntervalSince(lastSizeCheck) > sizeCheckInterval {
            try rotateIfNeeded()
            lastSizeCheck = Date()
        }
        
        // Write all buffered entries at once
        let combinedEntries = buffer.joined()
        if let data = combinedEntries.data(using: .utf8) {
            do {
                try fileHandle.write(contentsOf: data)
                try fileHandle.synchronize() // Ensure data is written to disk
            } catch {
                // If file operations fail, the file handle might be corrupted
                // Safely recreate it without calling close() on potentially corrupted handle
                if !FileManager.default.fileExists(atPath: fileURL.path) {
                    FileManager.default.createFile(atPath: fileURL.path, contents: nil, attributes: nil)
                }
                
                // Create new file handle
                self.fileHandle = try FileHandle(forWritingTo: fileURL)
                try self.fileHandle.write(contentsOf: data)
                try self.fileHandle.synchronize()
            }
        }
        buffer.removeAll()
    }
    
    func flush() throws {
        try flushBuffer()
    }
    
    private func rotateIfNeeded() throws {
        // Prevent concurrent rotation
        guard !isRotating else { return }
        
        let attributes  = try FileManager.default.attributesOfItem(atPath: fileURL.path)
        guard let size  = attributes[.size] as? UInt64, size >= maxFileSize else { return }
        
        isRotating = true
        defer { isRotating = false }
        
        // Prepare rotation in a safe way
        let timestamp   = ISO8601DateFormatter().string(from: Date())
        let rotatedName = fileURL.deletingPathExtension().lastPathComponent
        + "_" + timestamp.replacingOccurrences(of: ":", with: "-")
        + "." + fileURL.pathExtension
        let rotatedURL  = fileURL.deletingLastPathComponent()
            .appendingPathComponent(rotatedName)
        
        // Safely close the current file handle
        do {
            try fileHandle.close()
        } catch {
            // If close fails, new handle anyway will be created anyway
        }
        
        // Perform file operations
        try FileManager.default.moveItem(at: fileURL, to: rotatedURL)
        cleanupOldBackups()
        FileManager.default.createFile(atPath: fileURL.path, contents: nil, attributes: nil)
        
        // Create new file handle - this must succeed
        self.fileHandle = try FileHandle(forWritingTo: fileURL)
    }
    
    private func cleanupOldBackups() {
        let dir = fileURL.deletingLastPathComponent()
        let prefix = fileURL.deletingPathExtension().lastPathComponent + "_"
        let ext = fileURL.pathExtension
        let fileManager = FileManager.default
        guard let files = try? fileManager.contentsOfDirectory(
            at: dir,
            includingPropertiesForKeys: [.creationDateKey],
            options: []
        ) else { return }
        let backups = files.filter {
            $0.lastPathComponent.hasPrefix(prefix) && $0.pathExtension == ext
        }
        let sorted = backups.sorted { a, b in
            let da = (try? a.resourceValues(forKeys: [.creationDateKey]).creationDate) ?? .distantPast
            let db = (try? b.resourceValues(forKeys: [.creationDateKey]).creationDate) ?? .distantPast
            return da < db
        }
        let excess = sorted.count - maxBackupCount
        if excess > 0 {
            for url in sorted.prefix(excess) {
                try? fileManager.removeItem(at: url)
            }
        }
    }
    
    func close() throws {
        try flushBuffer() // Ensure all buffered data is written
        try fileHandle.close()
    }
}

/// A dispatcher that writes log Messages to a file, handling rotation, and forwarding downstream.
/// Thread-safe implementation using actor for file operations.
public final class FileDispatcher: MessageDispatching {
    // MARK: MessageDispatching
    public var dispatcherDelegate: MessageDispatchingDelegate?
    private var children: [MessageDispatching] = []
    
    public func nextDispatchers() -> [MessageDispatching] { children }
    public func addToNextDispatchers(_ dispatcher: MessageDispatching) { children.append(dispatcher) }
    public func removeFromNextDispatchers(_ dispatcher: MessageDispatching) {
        children.removeAll { ($0 as AnyObject) === (dispatcher as AnyObject) }
    }
    public func removeAllFromNextDispatchers() { children.removeAll() }
    
    // File operations actor for thread safety
    private let fileActor: FileActor
    private let isoFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }()
    
    /// Initialise with a file URL, rotation size threshold, and maximum backups.
    /// - Parameters:
    ///   - fileURL: location to write logs
    ///   - maxFileSize: size in bytes at which to rotate (default 10 MiB)
    ///   - maxBackupCount: number of rotated files to keep (default 5)
    public init(
        fileURL: URL,
        maxFileSize: UInt64 = 10 * 1024 * 1024,
        maxBackupCount: Int = 5
    ) throws {
        self.fileActor = try FileActor(
            fileURL: fileURL,
            maxFileSize: maxFileSize,
            maxBackupCount: maxBackupCount
        )
    }
    
    /// Handles a single Message: applies filters, writes entry with thread safety,
    /// and forwards downstream.
    public func handle(_ message: Message) async throws {
        // 1) Top-level filters
        if let del = dispatcherDelegate {
            guard del.shouldDispatchMessage(message),
                  del.shouldDispatchMessageWithPriority(message.priority)
            else { return }
        }
        
        // 2) Prepare log entry (lazy evaluation - only if we pass filters)
        let timestamp = isoFormatter.string(from: Date())
        let entry = "[\(timestamp)] \(message.description)\n"
        
        // 3) Thread-safe write through actor
        do {
            try await fileActor.writeEntry(entry)
        } catch {
            // Log write failure but don't prevent downstream processing
            print("FileDispatcher: Failed to write log entry - \(error)")
            // Consider adding fallback mechanism here
        }
        
        // 4) Forward to downstream dispatchers
        for child in children {
            do {
                try await child.handle(message)
            } catch {
                // Log child dispatcher failure but don't prevent other children from processing
                print("FileDispatcher: Child dispatcher failed to handle message - \(error)")
            }
        }
    }
    
    /// Manually flush any buffered log entries to disk
    public func flush() async throws {
        try await fileActor.flush()
    }
    
    deinit {
        // Capture fileActor locally to avoid retaining self in the Task
        let actor = fileActor
        Task.detached {
            try? await actor.close()
        }
    }
}
