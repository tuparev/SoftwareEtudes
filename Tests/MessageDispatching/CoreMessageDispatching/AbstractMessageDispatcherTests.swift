//
//  AbstractMessageDispatcherTests.swift
//  SoftwareEtudes
//
//  Created by Ani Klekchyan Work on 24.04.25.
//

import Foundation
import Testing
@testable import SoftwareEtudesCoreMessageDispatching

@Suite("AbstractMessageDispatcher Tests")
struct AbstractMessageDispatcherTests {
    
    /// Example delegate controlling global and priority filters.
    class DelegateExample: MessageDispatchingDelegate {
        var allowMessage = true
        var allowPriority = true
        func shouldDispatchMessage(_ message: Message) -> Bool { allowMessage }
        func shouldDispatchMessageWithPriority(_ priority: MessagePriority) -> Bool { allowPriority }
        func shouldDispatchSensitiveMessageArgument() -> Bool { true }
        func shouldDispatchPrivateMessageArgument() -> Bool { true }
    }
    
    /// Example dispatcher to capture forwarded messages.
    class DispatcherExample: MessageDispatching {
        var dispatcherDelegate: MessageDispatchingDelegate?
        private(set) var handled: [Message] = []
        func nextDispatchers() -> [any MessageDispatching] { [] }
        func addToNextDispatchers(_ dispatcher: any MessageDispatching) {}
        func removeFromNextDispatchers(_ dispatcher: any MessageDispatching) {}
        func removeAllFromNextDispatchers() {}
        
        func handle(_ message: Message) async throws {
            handled.append(message)
        }
    }
    
    @Test
    func handle_dropsWhenDelegateRejectsMessage() async throws {
        let dispatcher = AbstractMessageDispatcher(name: "")
        let delegate = DelegateExample()
        delegate.allowMessage = false
        dispatcher.dispatcherDelegate = delegate
        
        let child = DispatcherExample()
        dispatcher.addToNextDispatchers(child)
        
        let message = Message(payload: .key(key: "test"))
        try await dispatcher.handle(message)
        // allow async flush to complete
        try await Task.sleep(nanoseconds: 100_000_000)
        #expect(child.handled.isEmpty)
    }
    
    @Test
    func handle_dropsWhenDelegateRejectsByPriority() async throws {
        let dispatcher = AbstractMessageDispatcher(name: "")
        let delegate = DelegateExample()
        delegate.allowPriority = false
        dispatcher.dispatcherDelegate = delegate
        
        let child = DispatcherExample()
        dispatcher.addToNextDispatchers(child)
        
        let message = Message(payload: .key(key: "test"), priority: .high)
        try await dispatcher.handle(message)
        try await Task.sleep(nanoseconds: 100_000_000)
        #expect(child.handled.isEmpty)
    }
    
    @Test
    func handle_forwardsWhenDelegateAccepts() async throws {
        let dispatcher = AbstractMessageDispatcher(name: "")
        let delegate = DelegateExample()
        dispatcher.dispatcherDelegate = delegate
        
        let child = DispatcherExample()
        dispatcher.addToNextDispatchers(child)
        
        let message = Message(payload: .key(key: "test"), priority: .normal)
        try await dispatcher.handle(message)
        try await Task.sleep(nanoseconds: 100_000_000)
        
        #expect(child.handled.count == 1)
        #expect(child.handled.first?.payload == .key(key: "test"))
    }
}
