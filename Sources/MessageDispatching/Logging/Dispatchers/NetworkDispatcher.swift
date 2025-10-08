//
//  NetworkDispatcher.swift
//  SoftwareEtudes
//
//  Created by Ani Klekchyan Work on 16.01.25.
//

import Foundation
import SoftwareEtudesCoreMessageDispatching

/// Protocol for URLSession to enable testing
public protocol URLSessionProtocol {
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
}

extension URLSession: URLSessionProtocol {}

/// A dispatcher that sends log messages over HTTP to a remote endpoint.
/// Supports batching, retry logic, and network connectivity monitoring.
public final class NetworkDispatcher: MessageDispatching {
    
    // MARK: MessageDispatching
    public var dispatcherDelegate: MessageDispatchingDelegate?
    
    public init(endpoint: URL, session: URLSessionProtocol = URLSession.shared) {
        self.children        = []
        self.endpoint        = endpoint
        self.session         = session
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
        
        // 2) Add message to bufferx
        messageBuffer.append(message)
        
        // 3) Check if we should flush (batch is full)
        if messageBuffer.count >= batchSize {
            await flushMessages()
        }
        
        for child in children {
            try await child.handle(message)
        }
    }
    
    /// Manually flush any buffered messages to the network endpoint
    public func flush() async {
        await flushMessages()
    }
    
    // MARK: Private Properties
    private var children: [MessageDispatching]
    private let endpoint: URL
    private let session: URLSessionProtocol
    private let batchSize: Int
    private let flushInterval: Double
    private let maxRetries: Int
    private let retryDelay: Double
    private let includeMetadata: Bool
    private let customHeaders: [String: String]
    private var messageBuffer: [Message] = []
    
    // MARK: Private Methods
    
    private func flushMessages() async {
        
        let messagesToSend   = messageBuffer
        messageBuffer.removeAll()
        
        // Skip if no messages
        guard !messagesToSend.isEmpty else { return }
        
        // Create HTTP request
        var request          = URLRequest(url: endpoint)
        request.httpMethod   = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Add custom headers
        for (key, value) in customHeaders {
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        // Create JSON payload
        let payload          = createPayload(from: messagesToSend)
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: payload)
        } catch {
            print("NetworkDispatcher: Failed to serialise messages - \(error)")
            return
        }
        
        // Send HTTP request with retry logic
        await sendRequestWithRetry(request)
    }
    
    /// Sends HTTP request with retry logic
    private func sendRequestWithRetry(_ request: URLRequest) async {
        var attempt = 0
        
        while attempt <= maxRetries {
            do {
                let (_, response) = try await session.data(for: request)
                
                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode >= 200 && httpResponse.statusCode < 300 {
                        // Success
                        return
                    } else {
                        print("NetworkDispatcher: HTTP error \(httpResponse.statusCode)")
                    }
                }
                
                // If we get here, it's an error
                if attempt < maxRetries {
                    print("NetworkDispatcher: Attempt \(attempt + 1) failed, retrying in \(retryDelay)s...")
                    try await Task.sleep(nanoseconds: UInt64(retryDelay * 1_000_000_000))
                    attempt += 1
                } else {
                    print("NetworkDispatcher: All retry attempts failed")
                    return
                }
                
            } catch {
                print("NetworkDispatcher: Request failed - \(error)")
                if attempt < maxRetries {
                    print("NetworkDispatcher: Attempt \(attempt + 1) failed, retrying in \(retryDelay)s...")
                    try? await Task.sleep(nanoseconds: UInt64(retryDelay * 1_000_000_000))
                    attempt += 1
                } else {
                    print("NetworkDispatcher: All retry attempts failed")
                    return
                }
            }
        }
    }
    
    /// Creates a JSON payload from an array of messages for HTTP transmission.
    ///
    /// The resulting JSON structure:
    /// ```json
    /// {
    ///   "messages": [
    ///     {
    ///       "payload": "Key: test",
    ///       "priority": "INFO", 
    ///       "timestamp": "2025-09-09T10:30:00Z",
    ///       "arguments": {...},     // if includeMetadata = true
    ///       "actions": {...},       // if includeMetadata = true
    ///       "formattingInfo": {...} // if includeMetadata = true
    ///     }
    ///   ],
    ///   "batchSize": 1,
    ///   "timestamp": "2025-09-09T10:30:00Z"
    /// }
    /// ```
    ///
    /// - Parameter messages: Array of messages to include in the payload
    /// - Returns: Dictionary suitable for JSON serialisation
    private func createPayload(from messages: [Message]) -> [String: Any] {
        
        let messageData = messages.map { message in
            var messageDict: [String: Any]        = [
                "payload": message.payload.description,
                "priority": message.priority.description,
                "timestamp": ISO8601DateFormatter().string(from: Date())
            ]
            
            if includeMetadata {
                if let arguments                  = message.arguments {
                    messageDict["arguments"]      = arguments
                }
                if let actions                    = message.actions {
                    messageDict["actions"]        = actions
                }
                if let formattingInfo             = message.formattingInfo {
                    messageDict["formattingInfo"] = formattingInfo
                }
            }
            
            return messageDict
        }
        
        return [
            "messages": messageData,
            "batchSize": messages.count,
            "timestamp": ISO8601DateFormatter().string(from: Date())
        ]
    }
}
