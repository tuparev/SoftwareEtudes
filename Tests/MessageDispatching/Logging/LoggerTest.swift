//
//  LoggerTests.swift
//  SoftwareEtudes
//
//  Created by Ani Klekchyan Work on 17.01.25.
//

import Testing
import Foundation
import Logging
import SoftwareEtudesCoreMessageDispatching
@testable import SoftwareEtudesLogging

@Suite("Logger Initialization Tests")
struct LoggerInitializationTests {
    
    @Test("Logger initialises with correct defaults")
    func initWithDefaults() {
        
        // When
        let logger = Logger()
        
        // Then
        #expect(logger.logLevel == .info)
        #expect(logger.metadata.isEmpty)
        #expect(logger.dispatchers.isEmpty)
        #expect(logger.metadataProvider == nil)
    }
    
    @Test("Logger initialises with custom parameters")
    func initWithCustomParameters() {
        
        // Given
        let metadata: Logging.Logger.Metadata = ["app": "test", "version": "1.0"]
        let dispatcher = DispatcherExample()
        
        // When
        let logger = Logger(logLevel: .debug, metadata: metadata, dispatchers: [dispatcher])
        
        // Then
        #expect(logger.logLevel == .debug)
        #expect(logger.metadata["app"] == "test")
        #expect(logger.metadata["version"] == "1.0")
        #expect(logger.dispatchers.count == 1)
    }
    
    @Test("Logger initialises correctly with all log levels", arguments: [
        Logging.Logger.Level.trace, .debug, .info, .notice, .warning, .error, .critical
    ])
    func initWithAllLogLevels(level: Logging.Logger.Level) {
        // When
        let logger = Logger(logLevel: level)
        
        // Then
        #expect(logger.logLevel == level)
    }
}

@Suite("Logger Metadata Tests")
struct LoggerMetadataTests {
    
    @Test("Logger metadata subscript works correctly")
    func subscriptGetSet() {
        
        // Given
        let logger                    = Logger()
        
        // When & Then: Set string value
        logger[metadataKey: "key1"]   = .string("value1")
        #expect(logger[metadataKey: "key1"] == "value1")
        
        // When & Then: Set different types
        logger[metadataKey: "int"]    = .stringConvertible(42)
        logger[metadataKey: "double"] = .stringConvertible(3.14)
        logger[metadataKey: "bool"]   = .stringConvertible(true)
        
        #expect(logger[metadataKey: "int"] == .stringConvertible(42))
        #expect(logger[metadataKey: "double"] == .stringConvertible(3.14))
        #expect(logger[metadataKey: "bool"] == .stringConvertible(true))
        
        // When & Then: Clear value
        logger[metadataKey: "key1"]   = nil
        #expect(logger[metadataKey: "key1"] == nil)
    }
    
    @Test("Logger metadata subscript updates existing metadata correctly")
    func subscriptWithExistingMetadata() {
        
        // Given
        let initialMetadata: Logging.Logger.Metadata = ["existing": "value"]
        let logger                                   = Logger(metadata: initialMetadata)
        
        // When
        logger[metadataKey: "new"]                   = .string("newValue")
        logger[metadataKey: "existing"]              = .string("updatedValue")
        
        // Then
        #expect(logger[metadataKey: "existing"] == "updatedValue")
        #expect(logger[metadataKey: "new"]      == "newValue")
        #expect(logger.metadata.count           == 2)
    }
    
    @Test("Logger metadata subscript returns nil for non-existent keys")
    func subscriptGetNonExistentKey() {
        // Given
        let logger = Logger()
        
        // When & Then
        #expect(logger[metadataKey: "nonexistent"] == nil)
    }
}

@Suite("Logger Log Level Tests")
struct LoggerLogLevelTests {
    
    @Test("Logger filters messages below log level threshold")
    func logWithLevelBelowThreshold() async throws {
        
        // Given
        let dispatcher = DispatcherExample()
        let logger = Logger(logLevel: .warning, dispatchers: [dispatcher])
        
        // When
        logger.log(level: .info, message: "Info message", metadata: nil, source: "test", file: "test.swift", function: "test", line: 1)
        logger.log(level: .debug, message: "Debug message", metadata: nil, source: "test", file: "test.swift", function: "test", line: 2)
        
        // Wait for async processing
        try await Task.sleep(nanoseconds: 100_000_000)
        
        // Then
        #expect(dispatcher.received.isEmpty)
    }
    
    @Test("Logger dispatches messages at or above log level threshold")
    func logWithLevelAtOrAboveThreshold() async throws {
        
        // Given
        let dispatcher = DispatcherExample()
        let logger = Logger(logLevel: .warning, dispatchers: [dispatcher])
        
        // When
        logger.log(level: .warning, message: "Warning message", metadata: nil, source: "test", file: "test.swift", function: "test", line: 1)
        logger.log(level: .error, message: "Error message", metadata: nil, source: "test", file: "test.swift", function: "test", line: 2)
        logger.log(level: .critical, message: "Critical message", metadata: nil, source: "test", file: "test.swift", function: "test", line: 3)
        
        // Wait for async processing
        try await Task.sleep(nanoseconds: 100_000_000)
        
        // Then
        #expect(dispatcher.received.count == 3)
    }
    
    @Test("Logger log level modification affects subsequent logs")
    func logLevelModificationAffectsSubsequentLogs() async throws {
        
        // Given
        let dispatcher        = DispatcherExample()
        let logger            = Logger(logLevel: .error, dispatchers: [dispatcher])
        
        // When: Log below threshold
        logger.log(level: .warning, message: "Warning 1", metadata: nil, source: "test", file: "test.swift", function: "test", line: 1)
        try await Task.sleep(nanoseconds: 50_000_000)
        
        // Change threshold
        logger.logLevel       = .debug
        logger.log(level: .warning, message: "Warning 2", metadata: nil, source: "test", file: "test.swift", function: "test", line: 2)
        try await Task.sleep(nanoseconds: 50_000_000)
        
        // Then
        #expect(dispatcher.received.count == 1)
        if case let .key(key) = dispatcher.received.first?.payload {
            #expect(key == "Warning 2")
        }
    }
}

@Suite("Logger Log Method Tests")
struct LoggerLogMethodTests {
    
    @Test("Logger creates correct message with all parameters")
    func logWithAllParameters() async throws {
        
        // Given
        let dispatcher                        = DispatcherExample()
        let logger                            = Logger(logLevel: .debug, dispatchers: [dispatcher])
        let metadata: Logging.Logger.Metadata = ["user": "testUser", "session": "abc123"]
        
        // When
        logger.log(
            level: .warning,
            message: "Test message",
            metadata: metadata,
            source: "TestModule",
            file: "TestFile.swift",
            function: "testFunction()",
            line: 42
        )
        
        // Wait for async processing
        try await Task.sleep(nanoseconds: 100_000_000)
        
        // Then
        #expect(dispatcher.received.count == 1)
        let message                           = dispatcher.received.first!
        
        if case let .key(key)                 = message.payload {
            #expect(key == "Test message")
        } else {
            #expect(Bool(false), "Expected .key payload")
        }
        
        #expect(message.priority == .normal) // warning maps to normal
        
        let args                              = message.arguments!
        #expect(args["source"] == "TestModule")
        #expect(args["file"] == "TestFile.swift")
        #expect(args["function"] == "testFunction()")
        #expect(args["line"] == "42")
        
        let metadataJson                      = args["metadata"]!
        #expect(metadataJson.contains("\"user\""))
        #expect(metadataJson.contains("\"testUser\""))
        #expect(metadataJson.contains("\"session\""))
        #expect(metadataJson.contains("\"abc123\""))
    }
    
    @Test("Logger omits metadata when nil")
    func logWithNilMetadata() async throws {
        
        // Given
        let dispatcher = DispatcherExample()
        let logger = Logger(dispatchers: [dispatcher])
        
        // When
        logger.log(
            level: .info,
            message: "Simple message",
            metadata: nil,
            source: "TestModule",
            file: "TestFile.swift",
            function: "testFunction()",
            line: 10
        )
        
        // Wait for async processing
        try await Task.sleep(nanoseconds: 100_000_000)
        
        // Then
        #expect(dispatcher.received.count == 1)
        let args = dispatcher.received.first!.arguments ?? [:]
        #expect(args["metadata"] == nil)
    }
    
    @Test("Logger preserves empty message")
    func logWithEmptyMessage() async throws {
        
        // Given
        let dispatcher = DispatcherExample()
        let logger = Logger(dispatchers: [dispatcher])
        
        // When
        logger.log(level: .info, message: "", metadata: nil, source: "test", file: "test.swift", function: "test", line: 1)
        
        // Wait for async processing
        try await Task.sleep(nanoseconds: 100_000_000)
        
        // Then
        #expect(dispatcher.received.count == 1)
        if case let .key(key) = dispatcher.received.first?.payload {
            #expect(key == "")
        }
    }
    
    @Test("Logger maps Swift-Log levels to MessagePriority correctly", arguments: [
        (Logging.Logger.Level.trace, MessagePriority.debug),
        (.debug, .debug),
        (.info, .info),
        (.notice, .normal),
        (.warning, .normal),
        (.error, .high),
        (.critical, .critical)
    ])
    func logLevelMapping(input: (level: Logging.Logger.Level, expectedPriority: MessagePriority)) async throws {
        
        // Given
        let dispatcher = DispatcherExample()
        let logger = Logger(logLevel: .trace, dispatchers: [dispatcher]) // Allow all levels
        
        // When
        logger.log(level: input.level, message: "Test message", metadata: nil, source: "test", file: "test.swift", function: "test", line: 1)
        
        // Wait for async processing
        try await Task.sleep(nanoseconds: 100_000_000)
        
        // Then
        #expect(dispatcher.received.count == 1)
        #expect(dispatcher.received.first?.priority == input.expectedPriority)
    }
}

@Suite("Logger Async Dispatch Tests")
struct LoggerAsyncDispatchTests {
    
    @Test("Logger forwards messages to all dispatchers")
    func logToMultipleDispatchers() async throws {
        
        // Given
        let dispatcher1 = DispatcherExample()
        let dispatcher2 = DispatcherExample()
        let dispatcher3 = DispatcherExample()
        let logger = Logger(dispatchers: [dispatcher1, dispatcher2, dispatcher3])
        
        // When
        logger.log(level: .info, message: "Test message", metadata: nil, source: "test", file: "test.swift", function: "test", line: 1)
        
        // Wait for async processing
        try await Task.sleep(nanoseconds: 100_000_000)
        
        // Then
        #expect(dispatcher1.handleCallCount == 1)
        #expect(dispatcher2.handleCallCount == 1)
        #expect(dispatcher3.handleCallCount == 1)
        
        #expect(dispatcher1.received.count == 1)
        #expect(dispatcher2.received.count == 1)
        #expect(dispatcher3.received.count == 1)
    }
    
    @Test("Logger skips dispatcher when delegate rejects message")
    func logWithDelegateRejectingMessage() async throws {
        
        // Given
        let allowingDispatcher                  = DispatcherExample()
        let rejectingDispatcher                 = DispatcherExample()
        let rejectingDelegate                   = DelegateExample()
        rejectingDelegate.shouldDispatchMessage = false
        rejectingDispatcher.dispatcherDelegate  = rejectingDelegate
        
        let logger = Logger(dispatchers: [allowingDispatcher, rejectingDispatcher])
        
        // When
        logger.log(level: .info, message: "Test message", metadata: nil, source: "test", file: "test.swift", function: "test", line: 1)
        
        // Wait for async processing
        try await Task.sleep(nanoseconds: 100_000_000)
        
        // Then
        #expect(allowingDispatcher.handleCallCount == 1)
        #expect(rejectingDispatcher.handleCallCount == 0)
    }
    
    @Test("Logger skips dispatcher when delegate rejects priority")
    func logWithDelegateRejectingPriority() async throws {
        
        // Given
        let allowingDispatcher                   = DispatcherExample()
        let rejectingDispatcher                  = DispatcherExample()
        let rejectingDelegate                    = DelegateExample()
        rejectingDelegate.shouldDispatchPriority = false
        rejectingDispatcher.dispatcherDelegate   = rejectingDelegate
        
        let logger = Logger(dispatchers: [allowingDispatcher, rejectingDispatcher])
        
        // When
        logger.log(level: .error, message: "Test message", metadata: nil, source: "test", file: "test.swift", function: "test", line: 1)
        
        // Wait for async processing
        try await Task.sleep(nanoseconds: 100_000_000)
        
        // Then
        #expect(allowingDispatcher.handleCallCount == 1)
        #expect(rejectingDispatcher.handleCallCount == 0)
    }
    
    @Test("Logger processes multiple sequential messages correctly")
    func logMultipleMessagesSequentially() async throws {
        
        // Given
        let dispatcher = DispatcherExample()
        let logger     = Logger(dispatchers: [dispatcher])
        
        // When
        logger.log(level: .info, message: "Message 1", metadata: nil, source: "test", file: "test.swift", function: "test", line: 1)
        logger.log(level: .warning, message: "Message 2", metadata: nil, source: "test", file: "test.swift", function: "test", line: 2)
        logger.log(level: .error, message: "Message 3", metadata: nil, source: "test", file: "test.swift", function: "test", line: 3)
        
        // Wait for async processing
        try await Task.sleep(nanoseconds: 200_000_000)
        
        // Then
        #expect(dispatcher.handleCallCount == 3)
        #expect(dispatcher.received.count == 3)
        
        let messages = dispatcher.received
        if case let .key(key1) = messages[0].payload,
           case let .key(key2) = messages[1].payload,
           case let .key(key3) = messages[2].payload {
            #expect(key1 == "Message 1")
            #expect(key2 == "Message 2")
            #expect(key3 == "Message 3")
        } else {
            #expect(Bool(false), "Expected .key payloads")
        }
    }
}

@Suite("Logger Queue Handling Tests")
struct LoggerQueueHandlingTests {
    
    @Test("Logger handles concurrent logging correctly")
    func concurrentLogging() async throws {
        
        // Given
        let dispatcher = DispatcherExample()
        let logger = Logger(dispatchers: [dispatcher])
        
        // When: Log from multiple concurrent tasks
        await withTaskGroup(of: Void.self) { group in
            for i in 1...10 {
                group.addTask {
                    logger.log(level: .info, message: "Message \(i)", metadata: nil, source: "test", file: "test.swift", function: "test", line: UInt(i))
                }
            }
        }
        
        // Wait for all async processing
        try await Task.sleep(nanoseconds: 200_000_000)
        
        // Then
        #expect(dispatcher.handleCallCount == 10)
        #expect(dispatcher.received.count == 10)
    }
    
    @Test("Logger uses current dispatchers during processing")
    func dispatchersModifiedAfterLogging() async throws {
        
        // Given
        let originalDispatcher = DispatcherExample()
        let newDispatcher = DispatcherExample()
        let logger = Logger(dispatchers: [originalDispatcher])
        
        // When: Log message
        logger.log(level: .info, message: "Original message", metadata: nil, source: "test", file: "test.swift", function: "test", line: 1)
        
        // Immediately modify dispatchers
        logger.dispatchers = [newDispatcher]
        
        // Wait for async processing
        try await Task.sleep(nanoseconds: 100_000_000)
        
        // Then: New dispatcher should have received the message (current behavior)
        #expect(originalDispatcher.handleCallCount == 0)
        #expect(newDispatcher.handleCallCount == 1)
    }
    
    @Test("Logger with no dispatchers doesn't crash")
    func loggerWithNoDispatchers() async throws {
        
        // Given
        let logger = Logger(dispatchers: [])
        
        // When & Then: Should not crash
        logger.log(level: .info, message: "Test message", metadata: nil, source: "test", file: "test.swift", function: "test", line: 1)
        
        // Wait for async processing
        try await Task.sleep(nanoseconds: 100_000_000)
        
        // No assertions needed - just ensuring no crash
    }
}

@Suite("Logger Edge Cases Tests")
struct LoggerEdgeCasesTests {
    
    @Test("Logger handles very long messages")
    func veryLongMessage() async throws {
        
        // Given
        let dispatcher  = DispatcherExample()
        let logger      = Logger(dispatchers: [dispatcher])
        let longMessage = String(repeating: "A", count: 10000)
        
        // When
        logger.log(level: .info, message: Logging.Logger.Message(stringLiteral: longMessage), metadata: nil, source: "test", file: "test.swift", function: "test", line: 1)
        
        // Wait for async processing
        try await Task.sleep(nanoseconds: 100_000_000)
        
        // Then
        #expect(dispatcher.received.count == 1)
        if case let .key(key) = dispatcher.received.first?.payload {
            #expect(key == longMessage)
        }
    }
    
    @Test("Logger handles metadata with special characters")
    func metadataWithSpecialCharacters() async throws {
        
        // Given
        let dispatcher                               = DispatcherExample()
        let logger                                   = Logger(dispatchers: [dispatcher])
        let specialMetadata: Logging.Logger.Metadata = [
            "special": "Contains \"quotes\" and \\backslashes\\ and \nnewlines",
            "unicode": "🎉 Special chars: @#$%^&*()"
        ]
        
        // When
        logger.log(level: .info, message: "Test", metadata: specialMetadata, source: "test", file: "test.swift", function: "test", line: 1)
        
        // Wait for async processing
        try await Task.sleep(nanoseconds: 100_000_000)
        
        // Then
        #expect(dispatcher.received.count == 1)
        let args = dispatcher.received.first!.arguments!
        let metadataJson = args["metadata"]!
        #expect(metadataJson.contains("special"))
        #expect(metadataJson.contains("unicode"))
    }
    
}

// MARK: - Helper Classes
    
/// A simple test double that records every `handle(_:)` call.
fileprivate class DispatcherExample: MessageDispatching {
    
        var dispatcherDelegate: MessageDispatchingDelegate?
        private(set) var received: [Message] = []
    private(set) var handleCallCount         = 0
        
        func nextDispatchers() -> [MessageDispatching] { [] }
        func addToNextDispatchers(_ dispatcher: MessageDispatching) { }
        func removeFromNextDispatchers(_ dispatcher: MessageDispatching) { }
        func removeAllFromNextDispatchers() { }
        
        func handle(_ message: Message) async throws {
            received.append(message)
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
