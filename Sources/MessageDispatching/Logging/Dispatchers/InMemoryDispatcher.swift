//
//  InMemoryDispatcher.swift
//  SoftwareEtudes
//
//  Created by Ani Klekchyan Work on 21.10.25.
//

import Foundation
import SoftwareEtudesCoreMessageDispatching

/// An in-memory message dispatcher.
///
/// Stores dispatched ``Message`` values in a bounded buffer for later inspection.
/// Useful for testing, diagnostics, and ephemeral logging where persistence is not required.
public final class InMemoryDispatcher: MessageDispatching {
    
    public var dispatcherDelegate: MessageDispatchingDelegate?
    
    /// Creates an in-memory dispatcher.
    ///
    /// - Parameters:
    ///   - capacity: Maximum number of messages to retain in a circular buffer. Oldest are discarded first.
    ///   - priorities: The set of allowed message priorities to accept.
    public init(capacity: Int = 100,
                priorities: Set<MessagePriority> = [.debug, .info, .normal, .low, .background, .high, .critical]) {
        self.capacity = capacity
        self.allowedPriorities = priorities
        self.messageActor = InMemoryActor(capacity: capacity)
        self.children = []
    }
    
    // MARK: - Query Methods
    public func getAllLogs() async -> [Message] {
        await messageActor.getLogs()
    }
    
    public func filterLogs(by priority: MessagePriority) async -> [Message] {
        await messageActor.getLogs(priority: priority)
    }
    
    public func filterLogs(by priorities: Set<MessagePriority>) async -> [Message] {
        await messageActor.getLogs(priorities: priorities)
    }
    
    /// Returns stored messages whose textual description contains the given text (case-insensitive).
    public func searchLogs(text: String) async -> [Message] {
        await messageActor.searchLogs(text: text)
    }
    
    /// Currently messages do not carry timestamps; this method returns all messages.
    public func filterLogs(newerThan date: Date) async -> [Message] {
        // $$$GT
        // Note: Messages don't have built-in timestamps, so this is not supported
        // If we need time-based filtering, we should consider adding a timestamp property to Message
        await messageActor.filterLogs(newerThan: date)
    }
    
    public func clear() async {
        await messageActor.clear()
    }
    
    // MARK: - MessageDispatching Protocol
    public func nextDispatchers() -> [any MessageDispatching] {
        children
    }
    
    public func addToNextDispatchers(_ dispatcher: any MessageDispatching) {
        children.append(dispatcher)
    }
    
    public func removeFromNextDispatchers(_ dispatcher: any MessageDispatching) {
        children.removeAll { ($0 as AnyObject) === (dispatcher as AnyObject) }
    }
    
    public func removeAllFromNextDispatchers() {
        children.removeAll()
    }
    
    public func handle(_ message: Message) async throws {
        // Apply dispatcher delegate filters (like other dispatchers)
        if let delegate = dispatcherDelegate {
            guard delegate.shouldDispatchMessage(message),
                  delegate.shouldDispatchMessageWithPriority(message.priority) else { return }
        }
        
        // Priority filter
        guard allowedPriorities.contains(message.priority) else { return }
        
        await messageActor.store(message)
        
        // Forward to next dispatchers
        for child in children {
            try await child.handle(message)
        }
    }
    
    // MARK: - Private Properties
    private let capacity: Int
    private let allowedPriorities: Set<MessagePriority>
    private let messageActor: InMemoryActor
    private var children: [any MessageDispatching]
}

// MARK: - In-Memory Actor
private actor InMemoryActor {
    
    private var messages: [Message] = []
    private let capacity: Int
    
    init(capacity: Int) {
        self.capacity = capacity
    }
    
    func store(_ message: Message) {
        messages.append(message)
        if messages.count > capacity {
            messages.removeFirst()  // Remove oldest
        }
    }
    
    func getLogs() -> [Message] {
        return messages
    }

    func getLogs(priority: MessagePriority) -> [Message] {
        var result: [Message] = []
        for message in messages {
            if message.priority == priority {
                result.append(message)
            }
        }
        return result
    }

    func getLogs(priorities: Set<MessagePriority>) -> [Message] {
        var result: [Message] = []
        for message in messages {
            if priorities.contains(message.priority) {
                result.append(message)
            }
        }
        return result
    }

    func searchLogs(text: String) -> [Message] {
        let lowercaseText = text.lowercased()
        var result: [Message] = []
        for message in messages {
            if message.description.lowercased().contains(lowercaseText) {
                result.append(message)
            }
        }
        return result
    }

    func filterLogs(newerThan date: Date) -> [Message] {
        // Messages don't have timestamps in their payload, so we return all messages
        // If time-based filtering is needed, consider storing creation timestamp separately
        return messages
    }

    func clear() {
        messages.removeAll()
    }
}
