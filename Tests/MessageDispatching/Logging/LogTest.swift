//
//  LogTest.swift
//  SoftwareEtudes
//
//  Created by Ani Klekchyan Work on 17.01.25.
//

import Testing
import Foundation
import Logging
@testable import SoftwareEtudesLogging
@testable import SoftwareEtudesCoreMessageDispatching

@Suite("Log Initialization Tests")
struct LogInitializationTests {
    
    @Test
    func log_initWithMessageAndPriority_preservesMessageAndPriority() {
        // Given
        let payload = MessagePayload.code(code: 123)
        let message = Message(payload: payload, priority: .debug, arguments: ["foo":"bar"])
        
        // When
        let log     = Log(message: message, priority: .high)

        // Then
        #expect(log.message == message)
        #expect(log.priority == .high)
    }
    
    @Test
    func log_initWithDifferentPayloadTypes_preservesPayload() {
        // Given: key payload
        let keyPayload  = MessagePayload.key(key: "test message")
        let keyMessage  = Message(payload: keyPayload, priority: .info)
        
        // When
        let keyLog      = Log(message: keyMessage, priority: .normal)
        
        // Then
        #expect(keyLog.message.payload == keyPayload)
        #expect(keyLog.priority == .normal)
        
        // Given: code payload
        let codePayload = MessagePayload.code(code: 404)
        let codeMessage = Message(payload: codePayload, priority: .critical)
        
        // When
        let codeLog     = Log(message: codeMessage, priority: .high)
        
        // Then
        #expect(codeLog.message.payload == codePayload)
        #expect(codeLog.priority == .high)
    }
    
    @Test
    func log_initWithAllMessagePriorities_preservesPriority() {
        let payload                       = MessagePayload.key(key: "test")
        let message                       = Message(payload: payload, priority: .debug)
        
        let priorities: [MessagePriority] = [.info, .debug, .background, .normal, .low, .high, .critical]
        
        for priority in priorities {
            let log                       = Log(message: message, priority: priority)
            #expect(log.priority == priority, "Failed for priority: \(priority)")
        }
    }
}

@Suite("Log Make Static Method Tests")
struct LogMakeStaticMethodTests {
    
    @Test
    func log_makeWithTraceLevel_mapsToPriorityDebug() {
        // When
        let log               = Log.make(level: .trace, message: "trace message")
        
        // Then
        #expect(log.priority == .debug)
        if case let .key(key) = log.message.payload {
            #expect(key == "trace message")
        } else {
            #expect(Bool(false), "Expected .key payload")
        }
    }
    
    @Test
    func log_makeWithDebugLevel_mapsToPriorityDebug() {
        // When
        let log               = Log.make(level: .debug, message: "debug message")
        
        // Then
        #expect(log.priority == .debug)
        if case let .key(key) = log.message.payload {
            #expect(key == "debug message")
        } else {
            #expect(Bool(false), "Expected .key payload")
        }
    }
    
    @Test
    func log_makeWithInfoLevel_mapsToPriorityInfo() {
        // When
        let log               = Log.make(level: .info, message: "info message")
        
        // Then
        #expect(log.priority == .info)
        if case let .key(key) = log.message.payload {
            #expect(key == "info message")
        } else {
            #expect(Bool(false), "Expected .key payload")
        }
    }
    
    @Test
    func log_makeWithNoticeLevel_mapsToPriorityNormal() {
        // When
        let log = Log.make(level: .notice, message: "notice message")
        
        // Then
        #expect(log.priority == .normal)
    }
    
    @Test
    func log_makeWithWarningLevel_mapsToPriorityNormal() {
        // When
        let log = Log.make(level: .warning, message: "warning message")
        
        // Then
        #expect(log.priority == .normal)
    }
    
    @Test
    func log_makeWithErrorLevel_mapsToPriorityHigh() {
        // When
        let log = Log.make(level: .error, message: "error message")

        // Then
        #expect(log.priority == .high)
    }
    
    @Test
    func log_makeWithCriticalLevel_mapsToPriorityCritical() {
        // When
        let log = Log.make(level: .critical, message: "critical message")
        
        // Then
        #expect(log.priority == .critical)
    }
    
    @Test
    func log_makeWithAllParameters_buildsCorrectArguments() {
        // Given
        let metadata: Logging.Logger.Metadata = ["user": "Ani", "session": "abc123"]
        
        // When
        let log = Log.make(
            level: .info,
            message: "User action",
            metadata: metadata,
            source: "UserService",
            file: "UserService.swift",
            function: "performAction()",
            line: 42
        )
        
        // Then
        #expect(log.priority == .info)
        if case let .key(key) = log.message.payload {
            #expect(key == "User action")
        } else {
            #expect(Bool(false), "Expected .key payload")
        }
        
        let arguments = log.message.arguments!
        #expect(arguments[Log.MessageArgumentKeys.source.rawValue] == "UserService")
        #expect(arguments[Log.MessageArgumentKeys.file.rawValue] == "UserService.swift")
        #expect(arguments[Log.MessageArgumentKeys.function.rawValue] == "performAction()")
        #expect(arguments[Log.MessageArgumentKeys.line.rawValue] == "42")
        
        // Verify metadata is serialised to JSON
        let metadataJson = arguments[Log.MessageArgumentKeys.metadata.rawValue]!
        #expect(metadataJson.contains("\"user\""))
        #expect(metadataJson.contains("\"Ani\""))
        #expect(metadataJson.contains("\"session\""))
        #expect(metadataJson.contains("\"abc123\""))
    }
    
    @Test
    func log_makeWithNilOptionalParameters_omitsThemFromArguments() {
        // When
        let log = Log.make(
            level: .info,
            message: "Simple message",
            metadata: nil,
            source: nil,
            file: nil,
            function: nil,
            line: nil
        )
        
        // Then
        let arguments = log.message.arguments ?? [:]
        #expect(arguments[Log.MessageArgumentKeys.metadata.rawValue] == nil)
        #expect(arguments[Log.MessageArgumentKeys.source.rawValue] == nil)
        #expect(arguments[Log.MessageArgumentKeys.file.rawValue] == nil)
        #expect(arguments[Log.MessageArgumentKeys.function.rawValue] == nil)
        #expect(arguments[Log.MessageArgumentKeys.line.rawValue] == nil)
    }
    
    @Test
    func log_makeWithEmptyMetadata_omitsMetadataFromArguments() {
        // Given
        let emptyMetadata: Logging.Logger.Metadata = [:]
        
        // When
        let log = Log.make(level: .info, message: "test", metadata: emptyMetadata)
        
        // Then
        let arguments = log.message.arguments ?? [:]
        #expect(arguments[Log.MessageArgumentKeys.metadata.rawValue] != nil)
        #expect(arguments[Log.MessageArgumentKeys.metadata.rawValue] == "{}")
    }
}

@Suite("Log Metadata Serialization Tests")
struct LogMetadataSerialisationTests {
    
    @Test
    func log_makeWithStringMetadata_serializesCorrectly() {
        // Given
        let metadata: Logging.Logger.Metadata = [
            "key1": "value1",
            "key2": "value2"
        ]
        
        // When
        let log = Log.make(level: .info, message: "test", metadata: metadata)
        
        // Then
        let args = log.message.arguments!
        let metadataJson = args[Log.MessageArgumentKeys.metadata.rawValue]!
        
        #expect(metadataJson.contains("\"key1\""))
        #expect(metadataJson.contains("\"value1\""))
        #expect(metadataJson.contains("\"key2\""))
        #expect(metadataJson.contains("\"value2\""))
    }
    
    @Test
    func log_makeWithMixedMetadata_convertsAllToStrings() {
        // Given
        let metadata: Logging.Logger.Metadata = [
            "string": "text",
            "int": .stringConvertible(42),
            "double": .stringConvertible(3.14),
            "bool": .stringConvertible(true)
        ]
        
        // When
        let log = Log.make(level: .info, message: "test", metadata: metadata)
        
        // Then
        let args = log.message.arguments!
        let metadataJson = args[Log.MessageArgumentKeys.metadata.rawValue]!
        
        #expect(metadataJson.contains("\"string\""))
        #expect(metadataJson.contains("\"text\""))
        #expect(metadataJson.contains("\"int\""))
        #expect(metadataJson.contains("\"42\""))
        #expect(metadataJson.contains("\"double\""))
        #expect(metadataJson.contains("\"3.14\""))
        #expect(metadataJson.contains("\"bool\""))
        #expect(metadataJson.contains("\"true\""))
    }
}

@Suite("Log Dispatch Tests")
struct LogDispatchTests {
    
    /// Test dispatcher that records handled messages
    class DispatcherSpy: MessageDispatching {
        var dispatcherDelegate: MessageDispatchingDelegate?
        private(set) var handledMessages: [Message] = []
        private(set) var handleCallCount = 0
        
        func nextDispatchers() -> [MessageDispatching] { [] }
        func addToNextDispatchers(_ dispatcher: MessageDispatching) { }
        func removeFromNextDispatchers(_ dispatcher: MessageDispatching) { }
        func removeAllFromNextDispatchers() { }
        
        func handle(_ message: Message) async throws {
            handledMessages.append(message)
            handleCallCount += 1
        }
    }
    
    /// Test delegate that can control message filtering
    class DelegateSpy: MessageDispatchingDelegate {
        var shouldDispatchMessage: Bool = true
        var shouldDispatchPriority: Bool = true
        
        func shouldDispatchMessage(_ message: Message) -> Bool {
            shouldDispatchMessage
        }
        
        func shouldDispatchMessageWithPriority(_ priority: MessagePriority) -> Bool {
            shouldDispatchPriority
        }
        
        func shouldDispatchSensitiveMessageArgument() -> Bool { true }
        func shouldDispatchPrivateMessageArgument() -> Bool { true }
    }
    
    @Test
    func log_dispatchToEmptyArray_doesNothing() async {
        // Given
        let message = Message(payload: .key(key: "test"), priority: .info)
        let log = Log(message: message, priority: .info)
        
        // When
        await log.dispatch(to: [])
        
        // Then: No errors should occur
    }
    
    @Test
    func log_dispatchToSingleDispatcher_callsHandle() async {
        // Given
        let message = Message(payload: .key(key: "test"), priority: .info)
        let log = Log(message: message, priority: .info)
        let dispatcher = DispatcherSpy()
        
        // When
        await log.dispatch(to: [dispatcher])
        
        // Then
        #expect(dispatcher.handleCallCount == 1)
        #expect(dispatcher.handledMessages.count == 1)
        #expect(dispatcher.handledMessages.first == message)
    }
    
    @Test
    func log_dispatchToMultipleDispatchers_callsAllHandlers() async {
        // Given
        let message = Message(payload: .key(key: "test"), priority: .info)
        let log = Log(message: message, priority: .info)
        let dispatcher1 = DispatcherSpy()
        let dispatcher2 = DispatcherSpy()
        let dispatcher3 = DispatcherSpy()
        
        // When
        await log.dispatch(to: [dispatcher1, dispatcher2, dispatcher3])
        
        // Then
        #expect(dispatcher1.handleCallCount == 1)
        #expect(dispatcher2.handleCallCount == 1)
        #expect(dispatcher3.handleCallCount == 1)
        
        #expect(dispatcher1.handledMessages.first == message)
        #expect(dispatcher2.handledMessages.first == message)
        #expect(dispatcher3.handledMessages.first == message)
    }
    
    @Test
    func log_dispatchWithDelegateRejectingMessage_skipsDispatcher() async {
        // Given
        let message = Message(payload: .key(key: "test"), priority: .info)
        let log = Log(message: message, priority: .info)
        let dispatcher = DispatcherSpy()
        let delegate = DelegateSpy()
        delegate.shouldDispatchMessage = false
        dispatcher.dispatcherDelegate = delegate
        
        // When
        await log.dispatch(to: [dispatcher])
        
        // Then
        #expect(dispatcher.handleCallCount == 0)
        #expect(dispatcher.handledMessages.isEmpty)
    }
    
    @Test
    func log_dispatchWithDelegateRejectingPriority_skipsDispatcher() async {
        // Given
        let message = Message(payload: .key(key: "test"), priority: .high)
        let log = Log(message: message, priority: .high)
        let dispatcher = DispatcherSpy()
        let delegate = DelegateSpy()
        delegate.shouldDispatchPriority = false
        dispatcher.dispatcherDelegate = delegate
        
        // When
        await log.dispatch(to: [dispatcher])
        
        // Then
        #expect(dispatcher.handleCallCount == 0)
        #expect(dispatcher.handledMessages.isEmpty)
    }
    
    @Test
    func log_dispatchWithNilDelegate_allowsDispatch() async {
        // Given
        let message = Message(payload: .key(key: "test"), priority: .info)
        let log = Log(message: message, priority: .info)
        let dispatcher = DispatcherSpy()
        dispatcher.dispatcherDelegate = nil
        
        // When
        await log.dispatch(to: [dispatcher])
        
        // Then
        #expect(dispatcher.handleCallCount == 1)
        #expect(dispatcher.handledMessages.count == 1)
    }
    
    @Test
    func log_dispatchWithMixedDelegateResponses_onlyDispatchesToAllowing() async {
        // Given
        let message                             = Message(payload: .key(key: "test"), priority: .info)
        let log                                 = Log(message: message, priority: .info)
        
        let allowingDispatcher                  = DispatcherSpy()
        let allowingDelegate                    = DelegateSpy()
        allowingDelegate.shouldDispatchMessage  = true
        allowingDispatcher.dispatcherDelegate   = allowingDelegate
        
        let rejectingDispatcher                 = DispatcherSpy()
        let rejectingDelegate                   = DelegateSpy()
        rejectingDelegate.shouldDispatchMessage = false
        rejectingDispatcher.dispatcherDelegate  = rejectingDelegate
        
        // When
        await log.dispatch(to: [allowingDispatcher, rejectingDispatcher])
        
        // Then
        #expect(allowingDispatcher.handleCallCount == 1)
        #expect(rejectingDispatcher.handleCallCount == 0)
    }
}

@Suite("Log Edge Cases Tests")
struct LogEdgeCasesTests {
    
    @Test
    func log_messageArgumentKeys_hasCorrectRawValues() {
        #expect(Log.MessageArgumentKeys.metadata.rawValue == "metadata")
        #expect(Log.MessageArgumentKeys.source.rawValue   == "source")
        #expect(Log.MessageArgumentKeys.file.rawValue     == "file")
        #expect(Log.MessageArgumentKeys.function.rawValue == "function")
        #expect(Log.MessageArgumentKeys.line.rawValue     == "line")
    }
    
    @Test
    func log_makeWithLargeLineNumber_convertsToString() {
        // When
        let log = Log.make(level: .info, message: "test", line: UInt.max)
        
        // Then
        let args = log.message.arguments!
        #expect(args[Log.MessageArgumentKeys.line.rawValue] == "\(UInt.max)")
    }
    
    @Test
    func log_makeWithSpecialCharactersInMessage_preservesThem() {
        // Given
        let specialMessage = "Special chars: \n\t\"'\\/@#$%^&*()+=[]{}|;:,.<>?"
        
        // When
        let log = Log.make(level: .info, message: specialMessage)
        
        // Then
        if case let .key(key) = log.message.payload {
            #expect(key == specialMessage)
        } else {
            #expect(Bool(false), "Expected .key payload")
        }
    }
    
    @Test
    func log_makeWithUnicodeInMessage_preservesThem() {
        // Given
        let unicodeMessage    = "Unicode: 🚀 测试 العربية עברית русский"
        
        // When
        let log               = Log.make(level: .info, message: unicodeMessage)
        
        // Then
        if case let .key(key) = log.message.payload {
            #expect(key == unicodeMessage)
        } else {
            #expect(Bool(false), "Expected .key payload")
        }
    }
    
    @Test
    func log_makeWithEmptyStringMessage_preservesEmptyString() {
        // When
        let log               = Log.make(level: .info, message: "")
        
        // Then
        if case let .key(key) = log.message.payload {
            #expect(key == "")
        } else {
            #expect(Bool(false), "Expected .key payload")
        }
    }
}
