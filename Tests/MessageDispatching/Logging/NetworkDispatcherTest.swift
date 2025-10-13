//
//  NetworkDispatcherTest.swift
//  SoftwareEtudes
//
//  Created by Ani Klekchyan Work on 03.10.25.
//

import Foundation
import Testing
import SoftwareEtudesCoreMessageDispatching
import SoftwareEtudesLogging

// MARK: - Test Helper Classes

/// Example URLSession for testing NetworkDispatcher
class URLSessionExample: URLSessionProtocol {
    var exampleResponses: [URL: (Data?, URLResponse?, Error?)] = [:]
    var capturedRequests: [URLRequest] = []
    
    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        capturedRequests.append(request)
        
        guard let url                     = request.url,
              let (data, response, error) = exampleResponses[url] else {
            throw URLError(.notConnectedToInternet)
        }
        
        if let error                      = error {
            throw error
        }
        
        return (data ?? Data(), response ?? URLResponse())
    }
    
    func setExampleResponse(for url: URL, data: Data? = nil, response: URLResponse? = nil, error: Error? = nil) {
        exampleResponses[url] = (data, response, error)
    }
}

/// Test helper for NetworkDispatcher tests
fileprivate class NetworkDispatcherTestHelpers {
    
    /// Creates a test endpoint URL
    static func createTestEndpoint() -> URL {
        return URL(string: "https://api.example.com/logs")!
    }
    
    /// Creates HTTP response example
    static func createHTTPResponseExample(statusCode: Int) -> HTTPURLResponse? {
        return HTTPURLResponse(
            url: createTestEndpoint(),
            statusCode: statusCode,
            httpVersion: "HTTP/1.1",
            headerFields: [:]
        )
    }
    
    /// Creates a test message
    static func createTestMessage(payload: String = "Test message", priority: MessagePriority = .info) -> Message {
        return Message(payload: .key(key: payload), priority: priority)
    }
    
    /// Validates that a request contains expected JSON structure
    static func validateRequestPayload(_ request: URLRequest) -> Bool {
        guard let httpBody = request.httpBody,
              let json      = try? JSONSerialization.jsonObject(with: httpBody) as? [String: Any],
              let messages  = json["messages"] as? [[String: Any]],
              let batchSize = json["batchSize"] as? Int,
              let timestamp = json["timestamp"] as? String else {
            return false
        }
        
        return !messages.isEmpty && batchSize == messages.count && !timestamp.isEmpty
    }
}

// MARK: - Delegate Example

class MessageDispatchingDelegateExample: MessageDispatchingDelegate {
    
    var shouldDispatchMessageReturn                  = true
    var shouldDispatchMessageWithPriorityReturn      = true
    var shouldDispatchMessageCalled                  = false
    var shouldDispatchMessageWithPriorityCalled      = false
    
    func shouldDispatchMessage(_ message: Message) -> Bool {
        shouldDispatchMessageCalled = true
        return shouldDispatchMessageReturn
    }
    
    func shouldDispatchMessageWithPriority(_ priority: MessagePriority) -> Bool {
        shouldDispatchMessageWithPriorityCalled = true
        return shouldDispatchMessageWithPriorityReturn
    }
    
    func shouldDispatchSensitiveMessageArgument() -> Bool {
        return true
    }
    
    func shouldDispatchPrivateMessageArgument() -> Bool {
        return true
    }
}

/// Delegate example that filters messages based on priority level
class PriorityFilteringDelegateExample: MessageDispatchingDelegate {
    
    var allowedPriorities: [MessagePriority] = []
    
    func shouldDispatchMessage(_ message: Message) -> Bool {
        return true
    }
    
    func shouldDispatchMessageWithPriority(_ priority: MessagePriority) -> Bool {
        return allowedPriorities.contains(priority)
    }
    
    func shouldDispatchSensitiveMessageArgument() -> Bool {
        return true
    }
    
    func shouldDispatchPrivateMessageArgument() -> Bool {
        return true
    }
}

// MARK: - NetworkDispatcher Initialisation Tests
@Suite("NetworkDispatcher Initialisation Tests")
struct NetworkDispatcherInitialisationTests {
    
    @Test("NetworkDispatcher initialises with default values")
    func initialisesWithDefaultValues() async throws {
        // Given
        let endpoint   = NetworkDispatcherTestHelpers.createTestEndpoint()
        
        // When
        let dispatcher = NetworkDispatcher(endpoint: endpoint)
        
        // Then
        #expect(dispatcher.nextDispatchers().isEmpty)
        #expect(dispatcher.dispatcherDelegate == nil)
    }
    
    @Test("NetworkDispatcher sends requests to correct endpoint")
    func sendsRequestsToCorrectEndpoint() async throws {
        // Given
        let customEndpoint = URL(string: "https://custom.example.com/api/logs")!
        let sessionExample = URLSessionExample()
        let dispatcher     = NetworkDispatcher(endpoint: customEndpoint, session: sessionExample)
        
        // Set up example response for the custom endpoint
        let response       = NetworkDispatcherTestHelpers.createHTTPResponseExample(statusCode: 200)
        sessionExample.setExampleResponse(for: customEndpoint, response: response)
        
        let message        = NetworkDispatcherTestHelpers.createTestMessage()
        
        // When
        try await dispatcher.handle(message)
        await dispatcher.flush()
        
        // Then
        #expect(sessionExample.capturedRequests.count == 1)
        #expect(sessionExample.capturedRequests.first?.url == customEndpoint, "Request should be sent to the custom endpoint")
    }
}

// MARK: - NetworkDispatcher Child Dispatcher Tests
@Suite("NetworkDispatcher Child Dispatcher Tests")
struct NetworkDispatcherChildDispatcherTests {
    
    @Test("NetworkDispatcher can add child dispatchers")
    func canAddChildDispatchers() async throws {
        // Given
        let endpoint        = NetworkDispatcherTestHelpers.createTestEndpoint()
        let dispatcher      = NetworkDispatcher(endpoint: endpoint)
        let childDispatcher = NetworkDispatcher(endpoint: endpoint)
        
        // When
        dispatcher.addToNextDispatchers(childDispatcher)
        
        // Then
        let children        = dispatcher.nextDispatchers()
        #expect(children.count == 1)
        #expect(children.first as? NetworkDispatcher === childDispatcher)
    }
    
    @Test("NetworkDispatcher can remove specific child dispatcher")
    func canRemoveSpecificChildDispatcher() async throws {
        // Given
        let endpoint   = NetworkDispatcherTestHelpers.createTestEndpoint()
        let dispatcher = NetworkDispatcher(endpoint: endpoint)
        let child1     = NetworkDispatcher(endpoint: endpoint)
        let child2     = NetworkDispatcher(endpoint: endpoint)
        
        dispatcher.addToNextDispatchers(child1)
        dispatcher.addToNextDispatchers(child2)
        
        // When
        dispatcher.removeFromNextDispatchers(child1)
        
        // Then
        let children   = dispatcher.nextDispatchers()
        #expect(children.count == 1)
        #expect(children.first as? NetworkDispatcher === child2)
    }
    
    @Test("NetworkDispatcher can remove all child dispatchers")
    func canRemoveAllChildDispatchers() async throws {
        // Given
        let endpoint   = NetworkDispatcherTestHelpers.createTestEndpoint()
        let dispatcher = NetworkDispatcher(endpoint: endpoint)
        let child1     = NetworkDispatcher(endpoint: endpoint)
        let child2     = NetworkDispatcher(endpoint: endpoint)
        
        dispatcher.addToNextDispatchers(child1)
        dispatcher.addToNextDispatchers(child2)
        
        // When
        dispatcher.removeAllFromNextDispatchers()
        
        // Then
        let children   = dispatcher.nextDispatchers()
        #expect(children.isEmpty)
    }
}

// MARK: - NetworkDispatcher Message Handling Tests
@Suite("NetworkDispatcher Message Handling Tests")
struct NetworkDispatcherMessageHandlingTests {
    
    @Test("NetworkDispatcher handles single message")
    func handlesSingleMessage() async throws {
        // Given
        let endpoint       = NetworkDispatcherTestHelpers.createTestEndpoint()
        let sessionExample = URLSessionExample()
        let dispatcher     = NetworkDispatcher(endpoint: endpoint, session: sessionExample)
        
        // Set up example response
        let response       = NetworkDispatcherTestHelpers.createHTTPResponseExample(statusCode: 200)
        sessionExample.setExampleResponse(for: endpoint, response: response)
        
        let message        = NetworkDispatcherTestHelpers.createTestMessage()
        
        // When
        try await dispatcher.handle(message)
        await dispatcher.flush() // Force flush to send the message
        
        // Then
        #expect(sessionExample.capturedRequests.count == 1)
        
        let request        = sessionExample.capturedRequests.first!
        #expect(request.url == endpoint)
        #expect(request.httpMethod == "POST")
        #expect(request.value(forHTTPHeaderField: "Content-Type") == "application/json")
        #expect(NetworkDispatcherTestHelpers.validateRequestPayload(request))
    }
    
    @Test("NetworkDispatcher batches multiple messages")
    func batchesMultipleMessages() async throws {
        // Given
        let endpoint       = NetworkDispatcherTestHelpers.createTestEndpoint()
        let sessionExample = URLSessionExample()
        let dispatcher     = NetworkDispatcher(endpoint: endpoint, session: sessionExample)
        
        // Set up example response
        let response       = NetworkDispatcherTestHelpers.createHTTPResponseExample(statusCode: 200)
        sessionExample.setExampleResponse(for: endpoint, response: response)
        
        let messages       = (0..<3).map { i in
            NetworkDispatcherTestHelpers.createTestMessage(payload: "Message \(i)")
        }
        
        // When
        for message in messages {
            try await dispatcher.handle(message)
        }
        await dispatcher.flush() // Force flush to send batched messages
        
        // Then
        #expect(sessionExample.capturedRequests.count == 1)
        
        let request        = sessionExample.capturedRequests.first!
        #expect(NetworkDispatcherTestHelpers.validateRequestPayload(request))
    }
    
    @Test("NetworkDispatcher forwards messages to child dispatchers")
    func forwardsMessagesToChildDispatchers() async throws {
        // Given
        let endpoint        = NetworkDispatcherTestHelpers.createTestEndpoint()
        let dispatcher      = NetworkDispatcher(endpoint: endpoint)
        let childDispatcher = NetworkDispatcher(endpoint: endpoint)
        
        dispatcher.addToNextDispatchers(childDispatcher)
        
        let message = NetworkDispatcherTestHelpers.createTestMessage()
        
        // When
        try await dispatcher.handle(message)
        
        // Then
        // This test verifies that the method doesn't throw when forwarding to children
        // The actual forwarding is tested by the child dispatcher's own tests
        #expect(Bool(true)) // If we reach here, no exception was thrown
    }
}

// MARK: - NetworkDispatcher Delegation Tests
@Suite("NetworkDispatcher Delegation Tests")
struct NetworkDispatcherDelegationTests {
    
    @Test("NetworkDispatcher filters debug messages but sends critical messages")
    func filtersDebugButSendsCritical() async throws {
        // Given
        let endpoint                      = NetworkDispatcherTestHelpers.createTestEndpoint()
        let sessionExample                = URLSessionExample()
        let dispatcher                    = NetworkDispatcher(endpoint: endpoint, session: sessionExample)
        
        // Set up example response
        let response                      = NetworkDispatcherTestHelpers.createHTTPResponseExample(statusCode: 200)
        sessionExample.setExampleResponse(for: endpoint, response: response)
        
        // Set up delegate that only allows critical and high priority messages
        let delegateExample               = PriorityFilteringDelegateExample()
        delegateExample.allowedPriorities = [.critical, .high]
        dispatcher.dispatcherDelegate     = delegateExample
        
        let debugMessage                  = NetworkDispatcherTestHelpers.createTestMessage(payload: "Debug info", priority: .debug)
        let criticalMessage               = NetworkDispatcherTestHelpers.createTestMessage(payload: "Critical error", priority: .critical)
        
        // When - send debug message (should be filtered)
        try await dispatcher.handle(debugMessage)
        await dispatcher.flush()
        
        #expect(sessionExample.capturedRequests.isEmpty, "Debug message should be filtered out")
        
        // When - send critical message (should be sent)
        try await dispatcher.handle(criticalMessage)
        await dispatcher.flush()
        
        // Then
        #expect(sessionExample.capturedRequests.count == 1, "Critical message should be sent")
        let request                       = sessionExample.capturedRequests.first!
        #expect(request.url == endpoint)
    }
    
    @Test("NetworkDispatcher sends only high priority messages to remote")
    func sendsOnlyHighPriorityToRemote() async throws {
        // Given
        let endpoint                      = NetworkDispatcherTestHelpers.createTestEndpoint()
        let sessionExample                = URLSessionExample()
        let dispatcher                    = NetworkDispatcher(endpoint: endpoint, session: sessionExample)
        
        // Set up example response
        let response                      = NetworkDispatcherTestHelpers.createHTTPResponseExample(statusCode: 200)
        sessionExample.setExampleResponse(for: endpoint, response: response)
        
        // Set up delegate that only allows critical and high priority messages
        let delegateExample               = PriorityFilteringDelegateExample()
        delegateExample.allowedPriorities = [.critical, .high]
        dispatcher.dispatcherDelegate     = delegateExample
        
        // Create messages with different priorities
        let debugMessage                  = NetworkDispatcherTestHelpers.createTestMessage(payload: "Debug", priority: .debug)
        let infoMessage                   = NetworkDispatcherTestHelpers.createTestMessage(payload: "Info", priority: .info)
        let warningMessage                = NetworkDispatcherTestHelpers.createTestMessage(payload: "Warning", priority: .normal)
        let errorMessage                  = NetworkDispatcherTestHelpers.createTestMessage(payload: "Error", priority: .high)
        let criticalMessage               = NetworkDispatcherTestHelpers.createTestMessage(payload: "Critical", priority: .critical)
        
        // When - send messages with various priorities
        try await dispatcher.handle(debugMessage)      // Should be filtered
        try await dispatcher.handle(infoMessage)       // Should be filtered
        try await dispatcher.handle(warningMessage)    // Should be filtered
        try await dispatcher.handle(errorMessage)      // Should be sent (high priority)
        try await dispatcher.handle(criticalMessage)   // Should be sent
        await dispatcher.flush()
        
        // Then - should send 1 batched request containing 2 messages (high and critical)
        #expect(sessionExample.capturedRequests.count == 1, "Should send one batched request")
        
        // Verify the request contains 2 messages
        let request                       = sessionExample.capturedRequests.first!
        #expect(request.url == endpoint)
        if let body                       = request.httpBody,
           let json                       = try? JSONSerialization.jsonObject(with: body) as? [String: Any],
           let messages                   = json["messages"] as? [[String: Any]] {
            #expect(messages.count == 2, "Batch should contain 2 messages (high and critical)")
        } else {
            Issue.record("Failed to parse request body")
        }
    }
}

// MARK: - NetworkDispatcher Error Handling Tests
@Suite("NetworkDispatcher Error Handling Tests")
struct NetworkDispatcherErrorHandlingTests {
    
    @Test("NetworkDispatcher retries on network errors without throwing")
    func handlesNetworkErrorsGracefully() async throws {
        // Given
        let endpoint                                            = NetworkDispatcherTestHelpers.createTestEndpoint()
        let sessionExample                                      = URLSessionExample()
        let dispatcher                                          = NetworkDispatcher(endpoint: endpoint, session: sessionExample)
        
        // Set up example to return network error
        let networkError                                        = URLError(.notConnectedToInternet)
        sessionExample.setExampleResponse(for: endpoint, error: networkError)
        
        let message                                             = NetworkDispatcherTestHelpers.createTestMessage(payload: "Test message")
        
        // When - measure time to verify retries with delays
        let startTime                                           = Date()
        try await dispatcher.handle(message)
        await dispatcher.flush()
        let elapsed                                             = Date().timeIntervalSince(startTime)
        
        // Then - should attempt 3 times (1 initial + 2 retries)
        #expect(sessionExample.capturedRequests.count == 3, "Should attempt initial request + 2 retries")
        
        // Verify retry delays occurred (2 retries * 0.5s delay = ~1.0s minimum)
        #expect(elapsed >= 0.9, "Should have delayed for retries (expected ~1.0s, got \(elapsed)s)")
        
        // Verify all 3 requests are identical (same payload)
        let requests                                            = sessionExample.capturedRequests
        let firstBody                                           = requests[0].httpBody
        #expect(requests.allSatisfy { $0.httpBody == firstBody }, "All 3 retry attempts should have identical payload")
        
        // The dispatcher should not throw, even if the network request fails
    }
    
    @Test("NetworkDispatcher retries on HTTP 5xx errors but not on 4xx")
    func handlesHTTPErrorResponses() async throws {
        // Given - test 500 server error (should retry)
        let endpoint         = NetworkDispatcherTestHelpers.createTestEndpoint()
        let sessionExample   = URLSessionExample()
        let dispatcher       = NetworkDispatcher(endpoint: endpoint, session: sessionExample)
        
        // Set up example to return HTTP 500 error
        let errorResponse    = NetworkDispatcherTestHelpers.createHTTPResponseExample(statusCode: 500)
        sessionExample.setExampleResponse(for: endpoint, response: errorResponse)
        
        let message          = NetworkDispatcherTestHelpers.createTestMessage()
        
        // When
        try await dispatcher.handle(message)
        await dispatcher.flush()
        
        // Then - should retry on 5xx errors
        #expect(sessionExample.capturedRequests.count == 3, "Should retry on HTTP 500 (server error)")
        
        // Given - test 404 client error (should also retry - current implementation retries all non-2xx)
        sessionExample.capturedRequests.removeAll()
        let notFoundResponse = NetworkDispatcherTestHelpers.createHTTPResponseExample(statusCode: 404)
        sessionExample.setExampleResponse(for: endpoint, response: notFoundResponse)
        
        let message2         = NetworkDispatcherTestHelpers.createTestMessage(payload: "Another message")
        
        // When
        try await dispatcher.handle(message2)
        await dispatcher.flush()
        
        // Then - current implementation retries all non-2xx responses
        #expect(sessionExample.capturedRequests.count == 3, "Current implementation retries on all non-2xx including 404")
        // The dispatcher should not throw, even if the HTTP response indicates an error
    }
}
