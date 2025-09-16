//
//  FileDispatcherTest.swift
//  SoftwareEtudes
//
//  Created by Ani Klekchyan Work on 16.09.25.
//

import Foundation
import Testing
import SoftwareEtudesCoreMessageDispatching
import SoftwareEtudesLogging

// MARK: - Test Helper Classes

/// Test child dispatcher spy - each test uses its own instance
fileprivate class ChildDispatcherExample: MessageDispatching {
    var dispatcherDelegate: MessageDispatchingDelegate?
    private(set) var receivedMessages: [Message] = []
    private(set) var handleCallCount             = 0
    
    func nextDispatchers() -> [MessageDispatching] { [] }
    func addToNextDispatchers(_ dispatcher: MessageDispatching) { }
    func removeFromNextDispatchers(_ dispatcher: MessageDispatching) { }
    func removeAllFromNextDispatchers() { }
    
    func handle(_ message: Message) async throws {
        receivedMessages.append(message)
        handleCallCount += 1
    }
}

/// Test delegate that can control message filtering
fileprivate class DelegateExample: MessageDispatchingDelegate {
    
    var shouldDispatchMessage: Bool           = true
    var shouldDispatchPriority: Bool          = true
    var receivedMessages: [Message]           = []
    var receivedPriorities: [MessagePriority] = []
    
    func shouldDispatchMessage(_ message: Message) -> Bool {
        receivedMessages.append(message)
        return shouldDispatchMessage
    }
    
    func shouldDispatchMessageWithPriority(_ priority: MessagePriority) -> Bool {
        receivedPriorities.append(priority)
        return shouldDispatchPriority
    }
    
    func shouldDispatchSensitiveMessageArgument() -> Bool { true }
    func shouldDispatchPrivateMessageArgument() -> Bool { true }
}

// MARK: - Test Suite

@Suite("FileDispatcher Initialisation Tests")
struct FileDispatcherInitialisationTests {
    
    /// Helper to create a temporary file URL for testing
    private func createTempFileURL() -> URL {
        let tempDir = FileManager.default.temporaryDirectory
        return tempDir.appendingPathComponent("test_log_\(UUID().uuidString).log")
    }
    
    /// Helper to clean up test files
    private func cleanupFile(at url: URL) {
        try? FileManager.default.removeItem(at: url)
    }
    
    @Test("FileDispatcher initialises with default values")
    func initialisationWithDefaults() throws {
        
        // Given
        let fileURL    = createTempFileURL()
        defer { cleanupFile(at: fileURL) }
        
        // When
        let dispatcher = try FileDispatcher(fileURL: fileURL)
        
        // Then
        #expect(dispatcher.nextDispatchers().isEmpty)
        #expect(FileManager.default.fileExists(atPath: fileURL.path))
    }
    
    @Test("FileDispatcher initialises with custom parameters")
    func initialisationWithCustomParameters() throws {
        
        // Given
        let fileURL             = createTempFileURL()
        defer { cleanupFile(at: fileURL) }
        let maxFileSize: UInt64 = 5 * 1024 * 1024  // 5 MB
        let maxBackupCount      = 3
        
        // When
        let dispatcher          = try FileDispatcher(
            fileURL: fileURL,
            maxFileSize: maxFileSize,
            maxBackupCount: maxBackupCount
        )
        
        // Then
        #expect(dispatcher.nextDispatchers().isEmpty)
        #expect(FileManager.default.fileExists(atPath: fileURL.path))
    }
    
    @Test("FileDispatcher creates file if it doesn't exist")
    func createsFileIfNotExists() throws {
        
        // Given
        let fileURL = createTempFileURL()
        defer { cleanupFile(at: fileURL) }
        
        // Ensure file doesn't exist initially
        #expect(!FileManager.default.fileExists(atPath: fileURL.path))
        
        // When
        let _       = try FileDispatcher(fileURL: fileURL)
        
        // Then
        #expect(FileManager.default.fileExists(atPath: fileURL.path))
    }
    
    @Test("FileDispatcher throws error for invalid file path")
    func throwsErrorForInvalidPath() throws {
        
        // Given - invalid path (directory that doesn't exist)
        let invalidURL = URL(fileURLWithPath: "/invalid/directory/that/does/not/exist/test.log")
        
        // When & Then
        #expect(throws: (any Error).self) {
            let _      = try FileDispatcher(fileURL: invalidURL)
        }
    }
}
