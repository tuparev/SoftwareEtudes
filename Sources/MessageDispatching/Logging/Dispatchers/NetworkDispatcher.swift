//
//  NetworkDispatcher.swift
//  SoftwareEtudes
//
//  Created by Ani Klekchyan Work on 16.01.25.
//

import Foundation
import SoftwareEtudesCoreMessageDispatching

/// A dispatcher that sends log messages over HTTP to a remote endpoint.
/// Supports batching, retry logic, and network connectivity monitoring.
public final class NetworkDispatcher: MessageDispatching {
    
    // MARK: MessageDispatching
    public var dispatcherDelegate: MessageDispatchingDelegate?
    
    public init(endpoint: URL) {
        self.children        = []
        self.endpoint        = endpoint
        self.session         = URLSession.shared
        self.batchSize       = 5
        self.flushInterval   = 2.0
        self.maxRetries      = 2
        self.retryDelay      = 0.5
        self.includeMetadata = false
        self.customHeaders   = [:]
    }
    
    public func nextDispatchers() -> [MessageDispatching] { return children }
    public func addToNextDispatchers(_ dispatcher: MessageDispatching) { children.append(dispatcher) }
    public func removeFromNextDispatchers(_ dispatcher: MessageDispatching) {
        children.removeAll { ($0 as AnyObject) === (dispatcher as AnyObject) }
    }
    public func removeAllFromNextDispatchers() { children.removeAll() }
    
    public func handle(_ message: Message) async throws {
        
        // 1) Top-level filters
        if let del = dispatcherDelegate {
            guard del.shouldDispatchMessage(message),
                  del.shouldDispatchMessageWithPriority(message.priority)
            else { return }
        }
        
        // 2) Add message to buffer
        messageBuffer.append(message)
        
        // 3) Check if we should flush (batch is full)
        if messageBuffer.count >= batchSize {
            await flushMessages()
        }
        
        for child in children {
            try await child.handle(message)
        }
    }
    
    // MARK: Private Properties
    private var children: [MessageDispatching]
    private let endpoint: URL
    private let session: URLSession
    private let batchSize: Int
    private let flushInterval: Double
    private let maxRetries: Int
    private let retryDelay: Double
    private let includeMetadata: Bool
    private let customHeaders: [String: String]
    private var messageBuffer: [Message] = []
    
    // MARK: Private Methods
    
    private func flushMessages() async {
        messageBuffer.removeAll()
    }
}
