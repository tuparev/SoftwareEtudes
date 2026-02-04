//
//  MessageArgumentSensitivity.swift
//  SoftwareEtudes
//
//  Created by Georg Tuparev on 17.03.25.
//

import Foundation

/// A protocol describing how message arguments (keys and values) can be marked as
/// sensitive or private, and how to transform argument dictionaries accordingly.
///
/// Conforming types typically provide:
/// - A **sensitive** prefix (e.g., `?`) for keys containing sensitive data.
/// - A **private** prefix (e.g., `!`) for keys containing private data.
public protocol MessageArgumentSensitivityDescribing: Codable {
    
    /// A prefix used to indicate that a message argument key is sensitive.
    var sensitivityArgumentPrefix: String { get }
    /// A prefix used to indicate that a message argument key is private.
    var privateArgumentPrefix: String     { get }

    /// Determines whether the given `argumentKey` is considered sensitive.
    ///
    /// - Parameter argumentKey: The argument key to check.
    /// - Returns: `true` if `argumentKey` is considered sensitive, `false` otherwise.
    func isSensitiveArgument(_ argumentKey: String) -> Bool
    
    /// Determines whether the given `argumentKey` is considered private.
    ///
    /// - Parameter argumentKey: The argument key to check.
    /// - Returns: `true` if `argumentKey` is considered private, `false` otherwise.
    func isPrivateArgument(_ argumentKey: String) -> Bool

    /// Returns a new dictionary of arguments where all keys listed in `sensitiveKeys`
    /// are marked as **sensitive**.
    ///
    /// When a key is found in `sensitiveKeys`, this method prepends `sensitivityArgumentPrefix`
    /// to it, unless it already has a prefix indicating it is sensitive or private.
    ///
    /// - Parameters:
    ///   - arguments: The original dictionary of arguments (or `nil`).
    ///   - sensitiveKeys: A collection of keys in `arguments` that should be marked as sensitive.
    /// - Returns: A new dictionary of arguments with updated keys, or `nil` if `arguments` was `nil`.
    func makeSensitive(arguments: MessageProperties, sensitiveKeys: [String]) -> MessageProperties
    
    /// Returns a new dictionary of arguments where all keys listed in `sensitiveKeys`
    /// are marked as **private**.
    ///
    /// When a key is found in `privateKeys`, this method prepends `privateArgumentPrefix`
    /// to it, unless it already has a prefix indicating it is private or sensitive.
    ///
    /// - Parameters:
    ///   - arguments: The original dictionary of arguments (or `nil`).
    ///   - privateKeys: A collection of keys in `arguments` that should be marked as private.
    /// - Returns: A new dictionary of arguments with updated keys, or `nil` if `arguments` was `nil`.
    func makePrivate(arguments: MessageProperties, privateKeys: [String]) -> MessageProperties
}

/// A default implementation of `MessageArgumentSensitivityDescribing` providing
/// simple checks for sensitive or private arguments based on string prefixes.
///
/// By default:
/// - **Sensitive** argument keys start with `"?"`.
/// - **Private** argument keys start with `"!"`.
///
/// ## Overview
/// Typically, you assign `DefaultMessageArgumentSensitivityProvider` to a property
/// like:
/// ```swift
///     Message.argumentSensitivityProvider = DefaultMessageArgumentSensitivityProvider()
/// ```
/// Then, when building or transforming your messages, you can call:
/// ```swift
///     let updatedArgs = Message.argumentSensitivityProvider.makeSensitive(
///        arguments: originalArgs,
///        sensitiveKeys: ["token", "password"]
///     )
/// ```
public struct DefaultMessageArgumentSensitivityProvider: MessageArgumentSensitivityDescribing {
    
    /// A prefix used to indicate that a message argument key is sensitive.
    /// Defaults to `"?"`.
    public var sensitivityArgumentPrefix = "?"
    /// A prefix used to indicate that a message argument key is private.
    /// Defaults to `"!"`.
    public var privateArgumentPrefix     = "!"

    /// Creates an instance of `DefaultMessageArgumentSensitivityProvider`.
    /// You can override the prefix values if desired:
    /// ```swift
    ///     let provider = DefaultMessageArgumentSensitivityProvider(
    ///        sensitivityArgumentPrefix: "sensitive:",
    ///        privateArgumentPrefix: "private:"
    ///     )
    /// ```
    public init(sensitivityArgumentPrefix: String = "?", privateArgumentPrefix: String = "!") {
        self.sensitivityArgumentPrefix = sensitivityArgumentPrefix
        self.privateArgumentPrefix     = privateArgumentPrefix
    }
    
    /// Checks if the `argumentKey` starts with `sensitivityArgumentPrefix`.
    ///
    /// - Parameter argumentKey: The argument key to evaluate.
    /// - Returns: `true` if `argumentKey` has the sensitive prefix, `false` otherwise.
    public func isSensitiveArgument(_ argumentKey: String) -> Bool { argumentKey.hasPrefix(sensitivityArgumentPrefix) }
    
    /// Checks if the `argumentKey` starts with `privateArgumentPrefix`.
    ///
    /// - Parameter argumentKey: The argument key to evaluate.
    /// - Returns: `true` if `argumentKey` has the private prefix, `false` otherwise.
    public func isPrivateArgument(_ argumentKey: String)   -> Bool { argumentKey.hasPrefix(privateArgumentPrefix) }

    
    /// Returns a new dictionary of arguments where all `sensitiveKeys` are prefixed
    /// with `sensitivityArgumentPrefix`, unless they are already prefixed with
    /// either `sensitivityArgumentPrefix` or `privateArgumentPrefix`.
    ///
    /// - Parameters:
    ///   - arguments: The original dictionary of arguments (or `nil`).
    ///   - sensitiveKeys: The keys to mark as sensitive.
    /// - Returns: A new dictionary with updated keys (or `nil` if the original was `nil`).
    public func makeSensitive(arguments: MessageProperties, sensitiveKeys: [String]) -> MessageProperties {
        guard let arguments = arguments else { return nil }

        var updated: [String: String] = [:]

        for (key, value) in arguments {
            if sensitiveKeys.contains(key) {
                // If the key is already prefixed with either sensitive or private prefix,
                // do not modify it. Otherwise, apply the sensitive prefix.
                if key.hasPrefix(sensitivityArgumentPrefix) || key.hasPrefix(privateArgumentPrefix) {
                    updated[key]                                = value
                }
                else { updated[sensitivityArgumentPrefix + key] = value }
            }
            // Keep the key unchanged.
            else { updated[key]                                 = value }
        }
        return updated
    }
    
    /// Returns a new dictionary of arguments where all `privateKeys` are prefixed
    /// with `privateArgumentPrefix`, unless they are already prefixed with
    /// either `privateArgumentPrefix` or `sensitivityArgumentPrefix`.
    ///
    /// - Parameters:
    ///   - arguments: The original dictionary of arguments (or `nil`).
    ///   - privateKeys: The keys to mark as private.
    /// - Returns: A new dictionary with updated keys (or `nil` if the original was `nil`).
    public func makePrivate(arguments: MessageProperties, privateKeys: [String]) -> MessageProperties {
        guard let arguments = arguments else { return nil }

        var updated: [String: String] = [:]
        
        for (key, value) in arguments {
            if privateKeys.contains(key) {
                // If the key is already prefixed with either private or sensitive prefix,
                // do not modify it. Otherwise, apply the private prefix.
                if key.hasPrefix(privateArgumentPrefix) || key.hasPrefix(sensitivityArgumentPrefix) {
                    updated[key]                            = value
                }
                else { updated[privateArgumentPrefix + key] = value }
            }
            // Keep the key unchanged.
            else { updated[key]                             = value }
        }
        
        return updated
    }
}
