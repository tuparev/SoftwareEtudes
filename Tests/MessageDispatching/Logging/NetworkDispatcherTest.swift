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
    var ExampleResponses: [URL: (Data?, URLResponse?, Error?)] = [:]
    var capturedRequests: [URLRequest] = []
    
    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        capturedRequests.append(request)
        
        guard let url                     = request.url,
              let (data, response, error) = ExampleResponses[url] else {
            throw URLError(.notConnectedToInternet)
        }
        
        if let error                      = error {
            throw error
        }
        
        return (data ?? Data(), response ?? URLResponse())
    }
    
    func setExampleResponse(for url: URL, data: Data? = nil, response: URLResponse? = nil, error: Error? = nil) {
        ExampleResponses[url] = (data, response, error)
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
