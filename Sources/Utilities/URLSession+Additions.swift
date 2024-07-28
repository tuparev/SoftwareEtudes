//
//  URLSession+Additions.swift
//
//
//  Created by Georg Tuparev on 28/07/2024.
//  Copyright © See Framework's LICENSE file
//

import Foundation

public extension URLSession {

    /// Adds a ``URLSession`` instance that never uses caches
    static let nonCachingSession: URLSession = {
        let config = URLSessionConfiguration.default

        config.requestCachePolicy = .reloadIgnoringLocalCacheData

        return URLSession(configuration: config)
    }()

}
