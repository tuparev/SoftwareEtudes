//
//  URLSessionAdditions.swift
//  
//
//  Created by Georg Tuparev on 26/02/2020.
//  Copyright © 2020 Tuparev Technologies. All rights reserved.
//
//  Contributions, suggestions, ideas by:
//      1. Charles Parnot - @cparnot
//

import Foundation

extension URLSession {


    /// Synchronous URLSession call
    ///
    /// There are very rare cases when one need a synchronous http request. This extension to URLSession provides a
    /// simple implementation. No special handling for timeouts is provided. This implementation is mostly suited for
    /// local network calls in a well controlled and monitored system.
    ///
    /// **Note:** Do not use for external calls!
    ///
    /// - Parameters:
    ///   - url: the url of the request
    ///   - body: optional request body
    ///   - contentType: optional content type. Default is *text/plain*
    /// - Returns: a tuple of optional response data, the URLResponse itself, and optional Error
    func synchronousDataTask(with url: URL, body: Data? = nil, contentType: String = "text/plain") -> (Data?, URLResponse?, Error?) {
        var data: Data?
        var response: URLResponse?
        var error: Error?

        let semaphore = DispatchSemaphore(value: 0)

        var request = URLRequest(url: url)
        if body != nil {
            request.httpBody = body
            request.httpMethod = "POST"
        }
        request.setValue(contentType, forHTTPHeaderField: "Content-Type")

        let dataTask = self.dataTask(with: request) {
            data = $0
            response = $1
            error = $2

            semaphore.signal()
        }
        dataTask.resume()

        _ = semaphore.wait(timeout: .distantFuture)

        return (data, response, error)
    }
}
