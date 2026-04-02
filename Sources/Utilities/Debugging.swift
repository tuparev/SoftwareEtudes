//
//  Debugging.swift
//
//
//  Created by Georg Tuparev on 16.03.23.
//  Copyright © See Framework's LICENSE file
//
//  Thanks for contributions, suggestions, ideas by:
//      1. Hunter William Holland - see CONTRIBUTORS
//
//  Inspired by Paul Hudson and SwiftNEO.

/// Signals that a value or code path has not been given a real implementation yet.
///
/// Use this as a typed placeholder that satisfies the compiler while a real
/// implementation is still pending:
///
///     func computeResult() -> Int {
///         undefined("computeResult is not yet implemented")
///     }
///
/// - Parameter message: An optional description of what is undefined.
/// - Returns: Never returns — always terminates the process with a fatal error.
///
/// - Important: Calling this function **always crashes**. It must not appear
///   in production code paths.
public func undefined<T>(_ message: String = "") -> T {
    fatalError("Undefined: \(message)")
}

/// Signals that a required feature or method body has not been implemented yet.
///
/// Use this inside method stubs that need to compile but whose bodies have not
/// been written:
///
///     func fetchUser(id: String) -> User {
///         notImplemented("fetchUser")
///     }
///
/// - Parameter message: An optional description of what is not implemented.
/// - Returns: Never returns — always terminates the process with a fatal error.
///
/// - Important: Calling this function **always crashes**. It must not appear
///   in production code paths.
public func notImplemented<T>(_ message: String = "") -> T {
    fatalError("Not implemented: \(message)")
}
