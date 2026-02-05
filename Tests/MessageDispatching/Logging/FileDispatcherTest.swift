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

/// Shared test utilities for FileDispatcher tests
fileprivate class FileDispatcherTestHelpers {
    
    /// Helper to create a temporary file URL for testing
    static func createTempFileURL() -> URL {
        let tempDir = FileManager.default.temporaryDirectory
        return tempDir.appendingPathComponent("test_log_\(UUID().uuidString).log")
    }
    
    /// Helper to clean up test files
    static func cleanupFile(at url: URL) {
        try? FileManager.default.removeItem(at: url)
    }
    
    /// Helper to read file contents
    static func readFileContents(at url: URL) throws -> String {
        return try String(contentsOf: url, encoding: .utf8)
    }
    
    /// Helper to clean up test files and any rotated backup files
    static func cleanupFileAndRotations(at url: URL) {
        try? FileManager.default.removeItem(at: url)
        
        // Also clean up any rotated files
        let dir      = url.deletingLastPathComponent()
        let prefix   = url.deletingPathExtension().lastPathComponent + "_"
        let ext      = url.pathExtension
        
        if let files = try? FileManager.default.contentsOfDirectory(at: dir, includingPropertiesForKeys: nil) {
            for file in files {
                if file.lastPathComponent.hasPrefix(prefix) && file.pathExtension == ext {
                    try? FileManager.default.removeItem(at: file)
                }
            }
        }
    }
    
    /// Helper to count rotated backup files
    static func countBackupFiles(for url: URL) -> Int {
        let dir         = url.deletingLastPathComponent()
        let prefix      = url.deletingPathExtension().lastPathComponent + "_"
        let ext         = url.pathExtension
        
        guard let files = try? FileManager.default.contentsOfDirectory(at: dir, includingPropertiesForKeys: nil) else {
            return 0
        }
        
        return files.filter { file in
            file.lastPathComponent.hasPrefix(prefix) && file.pathExtension == ext
        }.count
    }
}

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
    
    @Test("FileDispatcher initialises with default values")
    func initialisationWithDefaults() throws {
        
        // Given
        let fileURL    = FileDispatcherTestHelpers.createTempFileURL()
        defer { FileDispatcherTestHelpers.cleanupFile(at: fileURL) }
        
        // When
        let dispatcher = try FileDispatcher(fileURL: fileURL)
        
        // Then
        #expect(dispatcher.nextDispatchers().isEmpty)
        #expect(FileManager.default.fileExists(atPath: fileURL.path))
    }
    
    @Test("FileDispatcher initialises with custom parameters")
    func initialisationWithCustomParameters() throws {
        
        // Given
        let fileURL             = FileDispatcherTestHelpers.createTempFileURL()
        defer { FileDispatcherTestHelpers.cleanupFile(at: fileURL) }
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
        let fileURL = FileDispatcherTestHelpers.createTempFileURL()
        defer { FileDispatcherTestHelpers.cleanupFile(at: fileURL) }
        
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

@Suite("FileDispatcher Child Dispatcher Tests")
struct FileDispatcherChildDispatcherTests {
    
    
    @Test("FileDispatcher initialises with no children")
    func initializesWithNoChildren() throws {
        
        // Given
        let fileURL    = FileDispatcherTestHelpers.createTempFileURL()
        defer { FileDispatcherTestHelpers.cleanupFile(at: fileURL) }
        
        let dispatcher = try FileDispatcher(fileURL: fileURL)
        
        // When
        let children   = dispatcher.nextDispatchers()
        
        // Then
        #expect(children.isEmpty)
    }
    
    @Test("FileDispatcher can add child dispatchers")
    func addChildDispatchers() throws {
        
        // Given
        let fileURL    = FileDispatcherTestHelpers.createTempFileURL()
        defer { FileDispatcherTestHelpers.cleanupFile(at: fileURL) }
        
        let dispatcher = try FileDispatcher(fileURL: fileURL)
        let child1     = ChildDispatcherExample()
        let child2     = ChildDispatcherExample()
        
        // When
        dispatcher.addToNextDispatchers(child1)
        dispatcher.addToNextDispatchers(child2)
        
        // Then
        let children = dispatcher.nextDispatchers()
        #expect(children.count == 2)
    }
    
    @Test("FileDispatcher can remove specific child dispatcher")
    func removeSpecificChildDispatcher() throws {
        
        // Given
        let fileURL    = FileDispatcherTestHelpers.createTempFileURL()
        defer { FileDispatcherTestHelpers.cleanupFile(at: fileURL) }
        
        let dispatcher = try FileDispatcher(fileURL: fileURL)
        let child1     = ChildDispatcherExample()
        let child2     = ChildDispatcherExample()
        
        dispatcher.addToNextDispatchers(child1)
        dispatcher.addToNextDispatchers(child2)
        
        // When
        dispatcher.removeFromNextDispatchers(child1)
        
        // Then
        let children   = dispatcher.nextDispatchers()
        #expect(children.count == 1)
    }
    
    @Test("FileDispatcher can remove all child dispatchers")
    func removeAllChildDispatchers() throws {
        
        // Given
        let fileURL    = FileDispatcherTestHelpers.createTempFileURL()
        defer { FileDispatcherTestHelpers.cleanupFile(at: fileURL) }
        
        let dispatcher = try FileDispatcher(fileURL: fileURL)
        let child1     = ChildDispatcherExample()
        let child2     = ChildDispatcherExample()
        
        dispatcher.addToNextDispatchers(child1)
        dispatcher.addToNextDispatchers(child2)
        
        // When
        dispatcher.removeAllFromNextDispatchers()
        
        // Then
        let children   = dispatcher.nextDispatchers()
        #expect(children.isEmpty)
    }
    
    @Test("FileDispatcher forwards messages to child dispatchers")
    func forwardMessagesToChildDispatchers() async throws {
        
        // Given
        let fileURL = FileDispatcherTestHelpers.createTempFileURL()
        defer { FileDispatcherTestHelpers.cleanupFile(at: fileURL) }
        
        let dispatcher = try FileDispatcher(fileURL: fileURL)
        let child1 = ChildDispatcherExample()
        let child2 = ChildDispatcherExample()
        
        dispatcher.addToNextDispatchers(child1)
        dispatcher.addToNextDispatchers(child2)
        
        let message = Message(payload: .key(key: "Forward test"), priority: .info)
        
        // When
        try await dispatcher.handle(message)
        try await dispatcher.flush()
        
        // Then
        #expect(child1.handleCallCount == 1)
        #expect(child2.handleCallCount == 1)
        #expect(child1.receivedMessages.count == 1)
        #expect(child2.receivedMessages.count == 1)
        #expect(child1.receivedMessages.first?.description == message.description)
        #expect(child2.receivedMessages.first?.description == message.description)
    }
}

@Suite("FileDispatcher Message Handling Tests")
struct FileDispatcherMessageHandlingTests {
    
    @Test("FileDispatcher handles basic message writing")
    func handlesBasicMessageWriting() async throws {
        
        // Given
        let fileURL      = FileDispatcherTestHelpers.createTempFileURL()
        defer { FileDispatcherTestHelpers.cleanupFile(at: fileURL) }
        
        let dispatcher   = try FileDispatcher(fileURL: fileURL)
        let message      = Message(payload: .key(key: "Test message"), priority: .info)
        
        // When
        try await dispatcher.handle(message)
        try await dispatcher.flush()
        
        // Then
        let fileContents = try FileDispatcherTestHelpers.readFileContents(at: fileURL)
        #expect(fileContents.contains("Test message"))
        #expect(fileContents.contains("INFO"))
    }
    
    @Test("FileDispatcher handles different message types")
    func handlesDifferentMessageTypes() async throws {
        
        // Given
        let fileURL      = FileDispatcherTestHelpers.createTempFileURL()
        defer { FileDispatcherTestHelpers.cleanupFile(at: fileURL) }
        
        let dispatcher   = try FileDispatcher(fileURL: fileURL)
        let keyMessage   = Message(payload: .key(key: "Key message"), priority: .debug)
        let codeMessage  = Message(payload: .code(code: 404), priority: .critical)
        
        // When
        try await dispatcher.handle(keyMessage)
        try await dispatcher.handle(codeMessage)
        try await dispatcher.flush()
        
        // Then
        let fileContents = try FileDispatcherTestHelpers.readFileContents(at: fileURL)
        #expect(fileContents.contains("Key message"))
        #expect(fileContents.contains("404"))
        #expect(fileContents.contains("DEBUG"))
        #expect(fileContents.contains("CRITICAL"))
    }
    
    @Test("FileDispatcher handles multiple messages")
    func handlesMultipleMessages() async throws {
        
        // Given
        let fileURL      = FileDispatcherTestHelpers.createTempFileURL()
        defer { FileDispatcherTestHelpers.cleanupFile(at: fileURL) }
        
        let dispatcher   = try FileDispatcher(fileURL: fileURL)
        let messages     = [
            Message(payload: .key(key: "First message"), priority: .info),
            Message(payload: .key(key: "Second message"), priority: .high),
            Message(payload: .key(key: "Third message"), priority: .critical)
        ]
        
        // When
        for message in messages {
            try await dispatcher.handle(message)
        }
        try await dispatcher.flush()
        
        // Then
        let fileContents = try FileDispatcherTestHelpers.readFileContents(at: fileURL)
        #expect(fileContents.contains("First message"))
        #expect(fileContents.contains("Second message"))
        #expect(fileContents.contains("Third message"))
    }
    
    @Test("FileDispatcher includes timestamp in log entries")
    func includesTimestampInLogEntries() async throws {
        
        // Given
        let fileURL      = FileDispatcherTestHelpers.createTempFileURL()
        defer { FileDispatcherTestHelpers.cleanupFile(at: fileURL) }
        
        let dispatcher   = try FileDispatcher(fileURL: fileURL)
        let message      = Message(payload: .key(key: "Timestamped message"), priority: .info)
        
        // When
        try await dispatcher.handle(message)
        try await dispatcher.flush()
        
        // Then
        let fileContents = try FileDispatcherTestHelpers.readFileContents(at: fileURL)
        // Check for ISO8601 timestamp format pattern
        #expect(fileContents.contains("["))
        #expect(fileContents.contains("T"))
        #expect(fileContents.contains("Z"))
        #expect(fileContents.contains("Timestamped message"))
    }
}

@Suite("FileDispatcher Delegation Tests")
struct FileDispatcherDelegationTests {
    
    @Test("FileDispatcher respects delegate message filtering")
    func respectDelegateMessageFiltering() async throws {
        
        // Given
        let fileURL                    = FileDispatcherTestHelpers.createTempFileURL()
        defer { FileDispatcherTestHelpers.cleanupFile(at: fileURL) }
        
        let delegate                   = DelegateExample()
        delegate.shouldDispatchMessage = false
        
        let dispatcher                 = try FileDispatcher(fileURL: fileURL)
        dispatcher.dispatcherDelegate  = delegate
        
        let message                    = Message(payload: .key(key: "Filtered message"), priority: .info)
        
        // When
        try await dispatcher.handle(message)
        try await dispatcher.flush()
        
        // Then
        #expect(delegate.receivedMessages.count == 1)
        #expect(delegate.receivedMessages.first?.description == message.description)
        
        // File should be empty (or only contain newlines/whitespace)
        let fileContents               = try FileDispatcherTestHelpers.readFileContents(at: fileURL)
        #expect(fileContents.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
    }
    
    @Test("FileDispatcher respects delegate priority filtering")
    func respectDelegatePriorityFiltering() async throws {
        
        // Given
        let fileURL                     = FileDispatcherTestHelpers.createTempFileURL()
        defer { FileDispatcherTestHelpers.cleanupFile(at: fileURL) }
        
        let delegate                    = DelegateExample()
        delegate.shouldDispatchPriority = false
        
        let dispatcher                  = try FileDispatcher(fileURL: fileURL)
        dispatcher.dispatcherDelegate   = delegate
        
        let message                     = Message(payload: .key(key: "Priority filtered"), priority: .high)
        
        // When
        try await dispatcher.handle(message)
        try await dispatcher.flush()
        
        // Then
        #expect(delegate.receivedPriorities.count == 1)
        #expect(delegate.receivedPriorities.first == .high)
        
        // File should be empty (or only contain newlines/whitespace)
        let fileContents                = try FileDispatcherTestHelpers.readFileContents(at: fileURL)
        #expect(fileContents.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
    }
    
    @Test("FileDispatcher handles messages when delegate allows")
    func handleMessagesWhenDelegateAllows() async throws {
        
        // Given
        let fileURL                     = FileDispatcherTestHelpers.createTempFileURL()
        defer { FileDispatcherTestHelpers.cleanupFile(at: fileURL) }
        
        let delegate                    = DelegateExample()
        delegate.shouldDispatchMessage  = true
        delegate.shouldDispatchPriority = true
        
        let dispatcher                  = try FileDispatcher(fileURL: fileURL)
        dispatcher.dispatcherDelegate   = delegate
        
        let message                     = Message(payload: .key(key: "Allowed message"), priority: .info)
        
        // When
        try await dispatcher.handle(message)
        try await dispatcher.flush()
        
        // Then
        #expect(delegate.receivedMessages.count == 1)
        #expect(delegate.receivedPriorities.count == 1)
        
        // File should contain the message
        let fileContents                = try FileDispatcherTestHelpers.readFileContents(at: fileURL)
        #expect(fileContents.contains("Allowed message"))
    }
    
    @Test("FileDispatcher stops processing when delegate filters message")
    func stopsProcessingWhenDelegateFiltersMessage() async throws {
        
        // Given
        let fileURL                    = FileDispatcherTestHelpers.createTempFileURL()
        defer { FileDispatcherTestHelpers.cleanupFile(at: fileURL) }
        
        let delegate                   = DelegateExample()
        delegate.shouldDispatchMessage = false  // Block file writing
        
        let dispatcher                 = try FileDispatcher(fileURL: fileURL)
        dispatcher.dispatcherDelegate  = delegate
        
        let child                      = ChildDispatcherExample()
        dispatcher.addToNextDispatchers(child)
        
        let message                    = Message(payload: .key(key: "Filtered but forwarded"), priority: .info)
        
        // When
        try await dispatcher.handle(message)
        try await dispatcher.flush()
        
        // Then
        // File should be empty due to filtering
        let fileContents               = try FileDispatcherTestHelpers.readFileContents(at: fileURL)
        #expect(fileContents.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        
        // Child should NOT receive the message when delegate filters at top level
        #expect(child.handleCallCount == 0)
        #expect(child.receivedMessages.count == 0)
    }
}

@Suite("FileDispatcher File Operations Tests")
struct FileDispatcherFileOperationsTests {
    
    @Test("FileDispatcher flushes buffered entries manually")
    func flushesBufferedEntriesManually() async throws {
        
        // Given
        let fileURL      = FileDispatcherTestHelpers.createTempFileURL()
        defer { FileDispatcherTestHelpers.cleanupFile(at: fileURL) }
        
        let dispatcher   = try FileDispatcher(fileURL: fileURL)
        let message      = Message(payload: .key(key: "Buffered message"), priority: .info)
        
        // When - handle message but don't flush automatically
        try await dispatcher.handle(message)
        
        // Then - manually flush
        //The dispatcher only automatically flushes when:
        //1. The buffer reaches 50 entries (maxBufferSize = 50)
        //2. 2 seconds have passed since the last flush (flushInterval = 2.0)
        try await dispatcher.flush()
        
        // Then - file should contain the message now
        let fileContents = try FileDispatcherTestHelpers.readFileContents(at: fileURL)
        #expect(fileContents.contains("Buffered message"))
    }
    
    
    @Test("FileDispatcher handles multiple messages with buffering")
    func handlesMultipleMessagesWithBuffering() async throws {
        
        // Given
        let fileURL      = FileDispatcherTestHelpers.createTempFileURL()
        defer { FileDispatcherTestHelpers.cleanupFile(at: fileURL) }
        
        let dispatcher   = try FileDispatcher(fileURL: fileURL)
        let messageCount = 10
        
        // When
        for i in 0..<messageCount {
            let message  = Message(payload: .key(key: "Message \(i)"), priority: .info)
            try await dispatcher.handle(message)
        }
        try await dispatcher.flush()
        
        // Then
        let fileContents = try FileDispatcherTestHelpers.readFileContents(at: fileURL)
        for i in 0..<messageCount {
            #expect(fileContents.contains("Message \(i)"))
        }
    }
    
    @Test("FileDispatcher continues working after write errors")
    func continuesWorkingAfterWriteErrors() async throws {
        
        // Given
        let fileURL             = FileDispatcherTestHelpers.createTempFileURL()
        defer { FileDispatcherTestHelpers.cleanupFile(at: fileURL) }
        
        let dispatcher          = try FileDispatcher(fileURL: fileURL)
        let validMessage        = Message(payload: .key(key: "Valid message"), priority: .info)
        let anotherValidMessage = Message(payload: .key(key: "Another valid message"), priority: .info)
        
        // When - handle valid message
        try await dispatcher.handle(validMessage)
        
        // Simulate potential write error scenario by removing the file
        try? FileManager.default.removeItem(at: fileURL)
        
        // Handle another message - should not throw even if write fails
        try await dispatcher.handle(anotherValidMessage)
        
        // Then - should not crash and should continue functioning
        #expect(true) // If we reach here, error handling worked
    }
    
    @Test("FileDispatcher handles empty messages gracefully")
    func handlesEmptyMessagesGracefully() async throws {
        
        // Given
        let fileURL         = FileDispatcherTestHelpers.createTempFileURL()
        defer { FileDispatcherTestHelpers.cleanupFile(at: fileURL) }
        
        let dispatcher      = try FileDispatcher(fileURL: fileURL)
        let emptyKeyMessage = Message(payload: .key(key: ""), priority: .info)
        let zeroCodeMessage = Message(payload: .code(code: 0), priority: .info)
        
        // When
        try await dispatcher.handle(emptyKeyMessage)
        try await dispatcher.handle(zeroCodeMessage)
        try await dispatcher.flush()
        
        // Then - should not crash and should write something
        let fileContents    = try FileDispatcherTestHelpers.readFileContents(at: fileURL)
        #expect(!fileContents.isEmpty)
        #expect(fileContents.contains("INFO"))
    }
    
    @Test("FileDispatcher preserves message order")
    func preservesMessageOrder() async throws {
        
        // Given
        let fileURL           = FileDispatcherTestHelpers.createTempFileURL()
        defer { FileDispatcherTestHelpers.cleanupFile(at: fileURL) }
        
        let dispatcher        = try FileDispatcher(fileURL: fileURL)
        let messages          = [
            Message(payload: .key(key: "First"), priority: .info),
            Message(payload: .key(key: "Second"), priority: .info),
            Message(payload: .key(key: "Third"), priority: .info),
            Message(payload: .key(key: "Fourth"), priority: .info)
        ]
        
        // When
        for message in messages {
            try await dispatcher.handle(message)
        }
        try await dispatcher.flush()
        
        // Then
        let fileContents      = try FileDispatcherTestHelpers.readFileContents(at: fileURL)
        let firstIndex        = fileContents.range(of: "First")?.lowerBound
        let secondIndex       = fileContents.range(of: "Second")?.lowerBound
        let thirdIndex        = fileContents.range(of: "Third")?.lowerBound
        let fourthIndex       = fileContents.range(of: "Fourth")?.lowerBound
        
        #expect(firstIndex  != nil)
        #expect(secondIndex != nil)
        #expect(thirdIndex  != nil)
        #expect(fourthIndex != nil)
        
        if let first          = firstIndex, let second = secondIndex, let third = thirdIndex, let fourth = fourthIndex {
            #expect(first < second)
            #expect(second < third)
            #expect(third < fourth)
        }
    }
}

@Suite("FileDispatcher Concurrency Tests")
struct FileDispatcherConcurrencyTests {
    
    @Test("FileDispatcher handles concurrent message writes safely")
    func handlesConcurrentMessageWritesSafely() async throws {
        
        // Given
        let fileURL                 = FileDispatcherTestHelpers.createTempFileURL()
        defer { FileDispatcherTestHelpers.cleanupFile(at: fileURL) }
        
        let dispatcher              = try FileDispatcher(fileURL: fileURL)
        let messageCount            = 25
        let concurrentTasks         = 4
        
        // When - write messages concurrently from multiple tasks
        await withTaskGroup(of: Void.self) { group in
            for taskId in 0..<concurrentTasks {
                group.addTask {
                    for messageId in 0..<messageCount {
                        let message = Message(
                            payload: .key(key: "Task \(taskId) Message \(messageId)"),
                            priority: .info
                        )
                        try? await dispatcher.handle(message)
                    }
                }
            }
        }
        
        try await dispatcher.flush()
        
        // Then - all messages should be written without corruption
        let fileContents            = try FileDispatcherTestHelpers.readFileContents(at: fileURL)
        
        // Check that we have messages from all tasks
        for taskId in 0..<concurrentTasks {
            #expect(fileContents.contains("Task \(taskId)"))
        }
    }
    
    @Test("FileDispatcher handles concurrent flush operations safely")
    func handlesConcurrentFlushOperationsSafely() async throws {
        
        // Given
        let fileURL      = FileDispatcherTestHelpers.createTempFileURL()
        defer { FileDispatcherTestHelpers.cleanupFile(at: fileURL) }
        
        let dispatcher   = try FileDispatcher(fileURL: fileURL)
        let messageCount = 15
        
        // Write some messages first
        for i in 0..<messageCount {
            let message  = Message(payload: .key(key: "Message \(i)"), priority: .info)
            try await dispatcher.handle(message)
        }
        
        // When - flush concurrently from multiple tasks
        await withTaskGroup(of: Void.self) { group in
            for _ in 0..<8 {
                group.addTask {
                    try? await dispatcher.flush()
                }
            }
        }
        
        // Then - should not crash and all messages should be written
        let fileContents = try FileDispatcherTestHelpers.readFileContents(at: fileURL)
        for i in 0..<messageCount {
            #expect(fileContents.contains("Message \(i)"))
        }
    }
    
    @Test("FileDispatcher maintains thread safety during rotation")
    func maintainsThreadSafetyDuringRotation() async throws {
        
        // Given
        let fileURL = FileDispatcherTestHelpers.createTempFileURL()
        defer { FileDispatcherTestHelpers.cleanupFile(at: fileURL) }
        
        let smallMaxSize: UInt64 = 150 // Small size to trigger rotation
        let dispatcher = try FileDispatcher(fileURL: fileURL, maxFileSize: smallMaxSize, maxBackupCount: 2)
        
        let messageCount = 15
        let concurrentTasks = 3
        
        // When - write large messages concurrently to trigger rotation
        await withTaskGroup(of: Void.self) { group in
            for taskId in 0..<concurrentTasks {
                group.addTask {
                    for messageId in 0..<messageCount {
                        let largeMessage = String(repeating: "Large message from task \(taskId) message \(messageId). ", count: 2)
                        let message = Message(payload: .key(key: largeMessage), priority: .info)
                        try? await dispatcher.handle(message)
                    }
                }
            }
        }
        
        try await dispatcher.flush()
        
        // Then - should not crash and should handle rotation safely
        #expect(FileManager.default.fileExists(atPath: fileURL.path))
        
        // Should have some content in the current file
        let fileContents = try FileDispatcherTestHelpers.readFileContents(at: fileURL)
        #expect(!fileContents.isEmpty)
    }
    
    @Test("FileDispatcher handles concurrent operations with child dispatchers")
    func handlesConcurrentOperationsWithChildDispatchers() async throws {
        
        // Given
        let fileURL                 = FileDispatcherTestHelpers.createTempFileURL()
        defer { FileDispatcherTestHelpers.cleanupFile(at: fileURL) }
        
        let dispatcher              = try FileDispatcher(fileURL: fileURL)
        let child1                  = ChildDispatcherExample()
        let child2                  = ChildDispatcherExample()
        
        dispatcher.addToNextDispatchers(child1)
        dispatcher.addToNextDispatchers(child2)
        
        let messageCount            = 3
        
        // When - write messages concurrently
        await withTaskGroup(of: Void.self) { group in
            for taskId in 0..<3 {
                group.addTask {
                    for messageId in 0..<messageCount {
                        let message = Message(
                            payload: .key(key: "Concurrent Task \(taskId) Message \(messageId)"),
                            priority: .info
                        )
                        try? await dispatcher.handle(message)
                    }
                }
            }
        }
        
        try await dispatcher.flush()
        
        // Then - file and child dispatchers should have all messages
        let fileContents            = try FileDispatcherTestHelpers.readFileContents(at: fileURL)
        for taskId in 0..<3 {
            #expect(fileContents.contains("Concurrent Task \(taskId)"))
        }
        
        // Child dispatchers should have received all messages
        #expect(child1.receivedMessages.count == messageCount * 3)
        #expect(child2.receivedMessages.count == messageCount * 3)
    }
}

@Suite("FileDispatcher File Rotation Tests")
struct FileDispatcherFileRotationTests {
    
    @Test("FileDispatcher rotates file when size limit is reached")
    func rotatesFileWhenSizeLimitReached() async throws {
        
        // Given
        let fileURL                                  = FileDispatcherTestHelpers.createTempFileURL()
        defer { FileDispatcherTestHelpers.cleanupFileAndRotations(at: fileURL) }
        
        let smallMaxSize: UInt64                     = 15 // Very small size to trigger rotation quickly
        let dispatcher                               = try FileDispatcher(fileURL: fileURL, maxFileSize: smallMaxSize, maxBackupCount: 2)
        
        // Create a message that will definitely exceed the size limit
        // Each log entry includes timestamp: [timestamp] message\n
        // ISO8601 timestamp is ~25 chars, so we need a message that with timestamp exceeds 15 bytes
        let largeMessage                             = String(repeating: "Ani", count: 20) // 20 chars + timestamp > 15 bytes
        let message                                  = Message(payload: .key(key: largeMessage), priority: .info)
        
        // When - write messages and force flush after each to trigger rotation checks
        // Note: Size check is throttled to once per second, so we need to wait between checks
        for i in 0..<4 {
            try await dispatcher.handle(message)
            try await dispatcher.flush() // Force flush to trigger rotation checks
            
            // Debug output
            let currentFileSize                      = try FileManager.default.attributesOfItem(atPath: fileURL.path)[.size] as? UInt64 ?? 0
            print("After message \(i + 1): file size = \(currentFileSize) bytes")
            
            // Wait 1.1 seconds to ensure size check interval passes
            if i < 3 {
                try await Task.sleep(nanoseconds: 1_100_000_000) // 1.1 seconds
            }
        }
        
        // Then - should have created backup files
        let backupCount                              = FileDispatcherTestHelpers.countBackupFiles(for: fileURL)
        print("Backup files found: \(backupCount)")
        
        #expect(backupCount > 0, "Should have created at least one backup file, but found \(backupCount)")
        
        // Original file should still exist
        #expect(FileManager.default.fileExists(atPath: fileURL.path))
    }
    
    @Test("FileDispatcher respects maximum backup count")
    func respectsMaximumBackupCount() async throws {
        
        // Given
        let fileURL                                  = FileDispatcherTestHelpers.createTempFileURL()
        defer { FileDispatcherTestHelpers.cleanupFileAndRotations(at: fileURL) }
        
        // Use a very small max size to force rotations
        let smallMaxSize: UInt64                     = 15  // Very small to ensure rotation
        let maxBackups                               = 3
        let dispatcher                               = try FileDispatcher(fileURL: fileURL, maxFileSize: smallMaxSize, maxBackupCount: maxBackups)
        
        // Create a message that will definitely exceed the size limit
        // Each log entry includes timestamp: [timestamp] message\n
        // ISO8601 timestamp is ~25 chars, so we need a message that with timestamp exceeds 15 bytes
        let largeMessage                             = String(repeating: "A", count: 20)  // 20 chars + timestamp > 15 bytes
        let message                                  = Message(payload: .key(key: largeMessage), priority: .info)
        
        // When - write enough messages to trigger multiple rotations
        // We need at least 4 rotations to test the backup limit (3 + current file)
        // Note: Size check is throttled to once per second, so we need to wait between checks
        for i in 0..<6 {
            try await dispatcher.handle(message)
            try await dispatcher.flush() // Force flush to trigger rotation checks
            
            // Debug output
            let currentFileSize                      = try FileManager.default.attributesOfItem(atPath: fileURL.path)[.size] as? UInt64 ?? 0
            print("After message \(i + 1): file size = \(currentFileSize) bytes")
            
            // Wait 1.1 seconds to ensure size check interval passes
            if i < 5 { // Don't wait after the last message
                try await Task.sleep(nanoseconds: 1_100_000_000) // 1.1 seconds
            }
        }
        
        // Then - should not exceed maximum backup count
        let backupCount                              = FileDispatcherTestHelpers.countBackupFiles(for: fileURL)
        
        // Debug output to verify rotation is working
        let currentFileSize                          = try FileManager.default.attributesOfItem(atPath: fileURL.path)[.size] as? UInt64 ?? 0
        print("Current file size: \(currentFileSize) bytes")
        print("Backup files found: \(backupCount)")
        
        #expect(backupCount <= maxBackups, "Should not exceed maximum backup count of \(maxBackups), but found \(backupCount)")
        #expect(backupCount > 0, "Should have created at least one backup file, but found \(backupCount)")
    }
    
    @Test("FileDispatcher with zero max backup count works correctly")
    func withZeroMaxBackupCountWorksCorrectly() async throws {
        
        // Given
        let fileURL              = FileDispatcherTestHelpers.createTempFileURL()
        defer { FileDispatcherTestHelpers.cleanupFileAndRotations(at: fileURL) }
        
        let smallMaxSize: UInt64 = 15  // Very small to ensure rotation
        let dispatcher           = try FileDispatcher(fileURL: fileURL, maxFileSize: smallMaxSize, maxBackupCount: 0)
        
        // Create a message that will definitely exceed the size limit
        let largeMessage         = String(repeating: "NoBackup", count: 20) // 20 chars + timestamp > 15 bytes
        let message              = Message(payload: .key(key: largeMessage), priority: .info)
        
        // When - write messages that would trigger rotation
        // Note: Size check is throttled to once per second, so we need to wait between checks
        for i in 0..<4 {
            try await dispatcher.handle(message)
            try await dispatcher.flush() // Force flush to trigger rotation checks
            
            // Debug output
            let currentFileSize  = try FileManager.default.attributesOfItem(atPath: fileURL.path)[.size] as? UInt64 ?? 0
            print("After message \(i + 1): file size = \(currentFileSize) bytes")
            
            // Wait 1.1 seconds to ensure size check interval passes
            if i < 3 {
                try await Task.sleep(nanoseconds: 1_100_000_000) // 1.1 seconds
            }
        }
        
        // Then - should have no backup files (they get immediately deleted with maxBackupCount: 0)
        let backupCount          = FileDispatcherTestHelpers.countBackupFiles(for: fileURL)
        print("Backup files found: \(backupCount)")
        
        #expect(backupCount == 0, "Should have no backup files with maxBackupCount: 0, but found \(backupCount)")
        
        // Original file should still exist
        #expect(FileManager.default.fileExists(atPath: fileURL.path))
    }
}
