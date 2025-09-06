//
//  ConsoleDispatcherTest.swift
//  SoftwareEtudes
//
//  Created by Ani Klekchyan Work on 29.08.25.
//

import Foundation
import Testing
import SoftwareEtudesCoreMessageDispatching
import SoftwareEtudesLogging

/// Test child dispatcher spy
class ChildDispatcherSpy: MessageDispatching {
    var dispatcherDelegate: MessageDispatchingDelegate?
    private(set) var receivedMessages: [Message] = []
    private(set) var handleCallCount = 0
    
    func nextDispatchers() -> [MessageDispatching] { [] }
    func addToNextDispatchers(_ dispatcher: MessageDispatching) { }
    func removeFromNextDispatchers(_ dispatcher: MessageDispatching) { }
    func removeAllFromNextDispatchers() { }
    
    func handle(_ message: Message) async throws {
        receivedMessages.append(message)
        handleCallCount += 1
    }
}

@Suite("ConsoleDispatcher Initializ=sation Tests")
struct ConsoleDispatcherInitialisationTests {
    
    @Test("ConsoleDispatcher initialises with default values")
    func initialisationWithDefaults() {
        
        // When
        let dispatcher = ConsoleDispatcher()
        
        // Then
        #expect(dispatcher.nextDispatchers().isEmpty)
    }
}

@Suite("ConsoleDispatcher Child Dispatcher Tests")
struct ConsoleDispatcherChildDispatcherTests {
    
    @Test("ConsoleDispatcher initialises with no children")
    func initializesWithNoChildren() {
        
        // Given
        let dispatcher = ConsoleDispatcher()
        
        // When
        let children   = dispatcher.nextDispatchers()
        
        // Then
        #expect(children.isEmpty)
    }
    
    @Test("ConsoleDispatcher can add child dispatchers")
    func addChildDispatchers() {
        
        // Given
        let dispatcher = ConsoleDispatcher()
        let child1     = ChildDispatcherSpy()
        let child2     = ChildDispatcherSpy()
        
        // When
        dispatcher.addToNextDispatchers(child1)
        dispatcher.addToNextDispatchers(child2)
        
        // Then
        let children = dispatcher.nextDispatchers()
        #expect(children.count == 2)
    }
    
    @Test("ConsoleDispatcher can remove specific child dispatcher")
    func removeSpecificChildDispatcher() {
        
        // Given
        let dispatcher = ConsoleDispatcher()
        let child1     = ChildDispatcherSpy()
        let child2     = ChildDispatcherSpy()
        
        dispatcher.addToNextDispatchers(child1)
        dispatcher.addToNextDispatchers(child2)
        
        // When
        dispatcher.removeFromNextDispatchers(child1)
        
        // Then
        let children   = dispatcher.nextDispatchers()
        #expect(children.count == 1)
    }
    
    @Test("ConsoleDispatcher can remove all child dispatchers")
    func removeAllChildDispatchers() {
        
        // Given
        let dispatcher = ConsoleDispatcher()
        let child1     = ChildDispatcherSpy()
        let child2     = ChildDispatcherSpy()
        
        dispatcher.addToNextDispatchers(child1)
        dispatcher.addToNextDispatchers(child2)
        
        // When
        dispatcher.removeAllFromNextDispatchers()
        
        // Then
        let children = dispatcher.nextDispatchers()
        #expect(children.isEmpty)
    }
    
    @Test("ConsoleDispatcher forwards messages to child dispatchers")
    func forwardMessagesToChildDispatchers() async throws {
        
        // Given
        let dispatcher = ConsoleDispatcher()
        let child1     = ChildDispatcherSpy()
        let child2     = ChildDispatcherSpy()
        
        dispatcher.addToNextDispatchers(child1)
        dispatcher.addToNextDispatchers(child2)
        
        let message    = Message(payload: .key(key: "Forward test"), priority: .info)
        
        // When
        try await dispatcher.handle(message)
        dispatcher.flush()
        
        // Then
        #expect(child1.handleCallCount == 1)
        #expect(child2.handleCallCount == 1)
        #expect(child1.receivedMessages.count == 1)
        #expect(child2.receivedMessages.count == 1)
        #expect(child1.receivedMessages.first?.description == message.description)
        #expect(child2.receivedMessages.first?.description == message.description)
    }
}

@Suite("ConsoleDispatcher Delegation Tests")
struct ConsoleDispatcherDelegationTests {
    
    @Test("ConsoleDispatcher respects delegate message filtering")
    func respectDelegateMessageFiltering() async throws {
        
        // Given
        let delegate                   = DelegateSpy()
        delegate.shouldDispatchMessage = false
        
        let dispatcher                 = ConsoleDispatcher()
        dispatcher.dispatcherDelegate  = delegate
        
        let message                    = Message(payload: .key(key: "Filtered message"), priority: .info)
        
        // When
        try await dispatcher.handle(message)
        dispatcher.flush()
        
        // Then
        #expect(delegate.receivedMessages.count == 1)
        #expect(delegate.receivedMessages.first?.description == message.description)
    }
    
    @Test("ConsoleDispatcher respects delegate priority filtering")
    func respectDelegatePriorityFiltering() async throws {
        
        // Given
        let delegate                    = DelegateSpy()
        delegate.shouldDispatchPriority = false
        
        let dispatcher                  = ConsoleDispatcher()
        dispatcher.dispatcherDelegate   = delegate
        
        let message                     = Message(payload: .key(key: "Priority filtered"), priority: .high)
        
        // When
        try await dispatcher.handle(message)
        dispatcher.flush()
        
        // Then
        #expect(delegate.receivedPriorities.count == 1)
        #expect(delegate.receivedPriorities.first == .high)
    }
    
    @Test("ConsoleDispatcher handles messages when delegate allows")
    func handleMessagesWhenDelegateAllows() async throws {
        
        // Given
        let delegate                    = DelegateSpy()
        delegate.shouldDispatchMessage  = true
        delegate.shouldDispatchPriority = true
        
        let dispatcher                  = ConsoleDispatcher()
        dispatcher.dispatcherDelegate   = delegate
        
        let message                     = Message(payload: .key(key: "Allowed message"), priority: .info)
        
        // When
        try await dispatcher.handle(message)
        dispatcher.flush()
        
        // Then
        #expect(delegate.receivedMessages.count == 1)
        #expect(delegate.receivedPriorities.count == 1)
    }
}
