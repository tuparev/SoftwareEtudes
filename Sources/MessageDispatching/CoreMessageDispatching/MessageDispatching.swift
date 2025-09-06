//
//  MessageDispatching.swift
//
//
//  Created by Georg Tuparev on 07.03.2023.
//  Copyright © See Framework's LICENSE file
//

import Foundation

// MARK: - Dispatching Layer

/// Defines policy hooks for filtering messages and deciding how to treat
/// sensitive or private arguments before dispatch.
///
/// Conformers can provide global and priority‐based filtering logic, as well
/// as per‐argument sensitivity controls.

/// Policy delegate for filtering and argument‑level decisions.
public protocol MessageDispatchingDelegate {
    
    /// Whether the given message should be dispatched at all.
    ///
    /// - Parameter message: The incoming `Message`.
    /// - Returns: `true` to allow dispatch, `false` to drop it.
    ///
    func shouldDispatchMessage(_ message: Message) -> Bool
    
    
    /// Whether messages of the given priority should be dispatched.
    ///
    ///  - Parameter priority: The `MessagePriority` of the message.
    ///  - Returns: `true` to allow dispatch, `false` to drop it.
    ///
    func shouldDispatchMessageWithPriority(_ priority: MessagePriority) -> Bool
    
    /// Whether sensitive arguments (prefixed with `?`) should be forwarded
    /// or passed on to the interpreter for masking.
    ///  - Returns: `true`to allow sensitive arguments through, `false` to mask them.
    ///  
    func shouldDispatchSensitiveMessageArgument() -> Bool
    
    
    /// Whether private arguments (prefixed with `!`) should be forwarded
    /// or dropped entirely.
    ///
    /// - Returns: `true` to allow private arguments through, `false` to drop them.
    ///
    func shouldDispatchPrivateMessageArgument() -> Bool
}

/// A dispatcher buffers incoming `Message` instances, applies top-level
/// filters, and then forwards them (possibly via an interpreter) to its
/// downstream dispatchers.
///
/// Conforms to `MessageHandling` so it may be invoked via `handle(_:)`.
public protocol MessageDispatching: MessageHandling {
    
    /// An optional policy delegate for high-level and per-argument decisions.
    ///
    var dispatcherDelegate: MessageDispatchingDelegate? { get set }
    
    
    /// Returns the list of downstream dispatchers.
    ///
    /// - Returns: Array of `MessageDispatching` to which messages will be forwarded.
    ///
    func nextDispatchers() -> [MessageDispatching]
    
    
    /// Adds a downstream dispatcher to the fan-out list.
    ///
    /// - Parameter dispatcher: The dispatcher to receive messages after this one.
    ///
    func addToNextDispatchers(_ dispatcher: MessageDispatching)
    
    
    /// Removes a previously added downstream dispatcher.
    ///
    /// - Parameter dispatcher: The dispatcher to remove.
    ///
    func removeFromNextDispatchers(_ dispatcher: MessageDispatching)
    
    
    /// Removes *all* downstream dispatchers.
    ///
    /// After calling this, `nextDispatchers()` will be empty.
    ///
    func removeAllFromNextDispatchers()
}

/// An abstract base implementation of `MessageDispatching`.
///
/// - Buffers incoming messages.
/// - Applies global and priority filters via its `dispatcherDelegate`.
/// - Fans out to a downstream interpreter (if it also conforms) and to child dispatchers.
open class AbstractMessageDispatcher: MessageDispatching {

    /// Optional delegate for filtering and argument-level policies.
    public var dispatcherDelegate: MessageDispatchingDelegate?
    
    /// Optional interpreter to apply format or argument masking.
    public let interpreter: MessageInterpreting?
    
    /// A human-readable name for debugging and diagnostics.
    public let name: String

    /// Initialise with an optional interpreter and a dispatcher name.
    ///
    /// - Parameters:
    ///   - interpreter: An object conforming to `MessageInterpreting` for argument cleanup.
    ///   - name: A string identifier for this dispatcher.
    ///
    public init(interpreter: MessageInterpreting? = nil, name: String) {
        self.interpreter = interpreter
        self.name = name
    }
    

    /// Returns the downstream dispatchers.
    ///
    public func nextDispatchers() -> [any MessageDispatching] {
        return nextDispatcher
    }
    
    
    /// Adds a child dispatcher to the fan-out list.
    ///
    public func addToNextDispatchers(_ newDispatcher: any MessageDispatching) {
        nextDispatcher.append(newDispatcher)
    }
    
    
    /// Removes a specific child dispatcher.
    ///
    public func removeFromNextDispatchers(_ dispatcher: any MessageDispatching) {
        nextDispatcher.removeAll { ($0 as AnyObject) === (dispatcher as AnyObject) }
    }
    

    /// Clears all downstream dispatchers.
    ///
    public func removeAllFromNextDispatchers() {
        nextDispatcher.removeAll()
    }
    
    
    /// Entry point for incoming messages.
    ///
    /// 1. Applies `shouldDispatchMessage(_:)` and
    ///    `shouldDispatchMessageWithPriority(_:)` if a delegate is set.
    /// 2. Buffers the message for asynchronous forwarding.
    ///
    /// - Parameter message: The `Message` to handle.
    ///
    public func handle(_ message: Message) async throws {
        // 1️⃣ Global and priority filters
        if let dispatcherDelegate = dispatcherDelegate {
            guard dispatcherDelegate.shouldDispatchMessage(message) else { return }
            guard dispatcherDelegate.shouldDispatchMessageWithPriority(message.priority) else { return }
        }
        // 2️⃣ Buffer for async flush
        outputBuffer.append(message)
        await flushBuffer()
    }
    
    
    /// Default implementation for dispatch decision; override if needed.
    ///
    public func shouldDispatch(message: Message) -> Bool {
        return true
    }
    
    
    // MARK: - Private Storage
    
    /// Internal list of children to fan out to.
    private var nextDispatcher: [any MessageDispatching] = []
    
    /// Internal FIFO buffer of messages awaiting flush.
    private var outputBuffer: [Message] = []
    
    /// Forwards buffered messages in FIFO order:
    /// 1. If the delegate also conforms to `MessageInterpreting`, runs `handle(_:)`.
    /// 2. Fans out to each child dispatcher.
    ///
    private func flushBuffer() async {
        let toSend = outputBuffer
        outputBuffer.removeAll()
        for msg in toSend {
            ///$$$GT what do you think about this numbering style?
            // 1️⃣ Interpret/format if available
            if let interpreter = dispatcherDelegate as? MessageInterpreting {
                // if the delegate ALSO conforms to interpreter, it may clean/mask arguments here
                Task.detached { try? await interpreter.handle(msg) }
            }
            // 2️⃣ Fan out to next dispatchers
            for child in nextDispatchers() {
                Task.detached { try? await child.handle(msg) }
            }
        }
    }
}
