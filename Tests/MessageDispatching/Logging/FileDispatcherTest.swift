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

@Suite("FileDispatcher Child Dispatcher Tests")
struct FileDispatcherChildDispatcherTests {
    
    /// Helper to create a temporary file URL for testing
    private func createTempFileURL() -> URL {
        let tempDir = FileManager.default.temporaryDirectory
        return tempDir.appendingPathComponent("test_log_\(UUID().uuidString).log")
    }
    
    /// Helper to clean up test files
    private func cleanupFile(at url: URL) {
        try? FileManager.default.removeItem(at: url)
    }
    
    @Test("FileDispatcher initialises with no children")
    func initializesWithNoChildren() throws {
        
        // Given
        let fileURL    = createTempFileURL()
        defer { cleanupFile(at: fileURL) }
        
        let dispatcher = try FileDispatcher(fileURL: fileURL)
        
        // When
        let children   = dispatcher.nextDispatchers()
        
        // Then
        #expect(children.isEmpty)
    }
    
    @Test("FileDispatcher can add child dispatchers")
    func addChildDispatchers() throws {
        
        // Given
        let fileURL    = createTempFileURL()
        defer { cleanupFile(at: fileURL) }
        
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
        let fileURL    = createTempFileURL()
        defer { cleanupFile(at: fileURL) }
        
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
        let fileURL    = createTempFileURL()
        defer { cleanupFile(at: fileURL) }
        
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
        let fileURL = createTempFileURL()
        defer { cleanupFile(at: fileURL) }
        
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
    
    /// Helper to create a temporary file URL for testing
    private func createTempFileURL() -> URL {
        let tempDir = FileManager.default.temporaryDirectory
        return tempDir.appendingPathComponent("test_log_\(UUID().uuidString).log")
    }
    
    /// Helper to clean up test files
    private func cleanupFile(at url: URL) {
        try? FileManager.default.removeItem(at: url)
    }
    
    /// Helper to read file contents
    private func readFileContents(at url: URL) throws -> String {
        return try String(contentsOf: url, encoding: .utf8)
    }
    
    @Test("FileDispatcher handles basic message writing")
    func handlesBasicMessageWriting() async throws {
        
        // Given
        let fileURL      = createTempFileURL()
        defer { cleanupFile(at: fileURL) }
        
        let dispatcher   = try FileDispatcher(fileURL: fileURL)
        let message      = Message(payload: .key(key: "Test message"), priority: .info)
        
        // When
        try await dispatcher.handle(message)
        try await dispatcher.flush()
        
        // Then
        let fileContents = try readFileContents(at: fileURL)
        #expect(fileContents.contains("Test message"))
        #expect(fileContents.contains("INFO"))
    }
    
    @Test("FileDispatcher handles different message types")
    func handlesDifferentMessageTypes() async throws {
        
        // Given
        let fileURL      = createTempFileURL()
        defer { cleanupFile(at: fileURL) }
        
        let dispatcher   = try FileDispatcher(fileURL: fileURL)
        let keyMessage   = Message(payload: .key(key: "Key message"), priority: .debug)
        let codeMessage  = Message(payload: .code(code: 404), priority: .critical)
        
        // When
        try await dispatcher.handle(keyMessage)
        try await dispatcher.handle(codeMessage)
        try await dispatcher.flush()
        
        // Then
        let fileContents = try readFileContents(at: fileURL)
        #expect(fileContents.contains("Key message"))
        #expect(fileContents.contains("404"))
        #expect(fileContents.contains("DEBUG"))
        #expect(fileContents.contains("CRITICAL"))
    }
    
    @Test("FileDispatcher handles multiple messages")
    func handlesMultipleMessages() async throws {
        
        // Given
        let fileURL      = createTempFileURL()
        defer { cleanupFile(at: fileURL) }
        
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
        let fileContents = try readFileContents(at: fileURL)
        #expect(fileContents.contains("First message"))
        #expect(fileContents.contains("Second message"))
        #expect(fileContents.contains("Third message"))
    }
    
    @Test("FileDispatcher includes timestamp in log entries")
    func includesTimestampInLogEntries() async throws {
        
        // Given
        let fileURL      = createTempFileURL()
        defer { cleanupFile(at: fileURL) }
        
        let dispatcher   = try FileDispatcher(fileURL: fileURL)
        let message      = Message(payload: .key(key: "Timestamped message"), priority: .info)
        
        // When
        try await dispatcher.handle(message)
        try await dispatcher.flush()
        
        // Then
        let fileContents = try readFileContents(at: fileURL)
        // Check for ISO8601 timestamp format pattern
        #expect(fileContents.contains("["))
        #expect(fileContents.contains("T"))
        #expect(fileContents.contains("Z"))
        #expect(fileContents.contains("Timestamped message"))
    }
}
