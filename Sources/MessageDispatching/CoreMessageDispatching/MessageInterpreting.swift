//
//  MessageInterpreting.swift
//  
//
//  Created by Georg Tuparev on 8.03.23.
//  Copyright © See Framework's LICENSE file
//

import Foundation

/// Defines an object capable of interpreting (cleaning, masking, formatting) messages.
///
/// Conformers receive raw `Message` instances, apply argument‑level rules such as
/// obfuscation or dropping private fields, and then perform final handling (e.g. logging,
/// UI display).
public protocol MessageInterpreting: MessageHandling {
    /// Character used to mask sensitive argument values. Default is `"*"`.
    var obfuscationCharacter: String            { get set }
    /// When `true`, `?`‑prefixed keys will be obfuscated; when `false`, their raw values are preserved. Default is `true`.
    var shouldObfuscateSensitiveArguments: Bool { get set }
    /// Initializer requiring an environment that provides configuration and utilities.
    ///
    /// - Parameter environment: Supplies language preferences, template mappings, and key‑cleanup logic.
    init(environment: MessageInterpretingEnvironmentProviding)
}

/// Base implementation of `MessageInterpreting`, applying standard masking and cleaning logic.
open class AbstractMessageInterpreter: MessageInterpreting {

    // MARK: Properties
    
    /// Character used to mask sensitive argument values. Defaults to `"*"`.
    public var obfuscationCharacter              = "*"
    /// Controls whether sensitive arguments are obfuscated (`true`) or left intact (`false`). Defaults to `true`.
    public var shouldObfuscateSensitiveArguments = true
    
    // MARK: Initialization
    
    /// Creates a new interpreter with the given environment.
    ///
    /// - Parameter environment: Supplies configuration and cleaning utilities.
    required public init(environment: MessageInterpretingEnvironmentProviding) {
        self.environment              = environment
    }

    // MARK: MessageHandling
    
    /// Cleans and masks message arguments according to prefix rules, then performs final handling.
    ///
    /// - Parameter message: The raw message to interpret.
    /// - Throws: Passes through any errors encountered during cleanup.
    public func handle(_ message: Message) async throws {
        // If there are no arguments, just forward
        guard let args                = message.arguments else { return print(message) }
        
        var newArgs: [String: String] = [:]
        for (rawKey, value) in args {
            let key                   = environment.cleanedArgumentKey(rawKey)
            if rawKey.hasPrefix(environment.privateArgumentPrefix) {
                // Drop private arguments
                continue
            }
            // Handle sensitive arguments
            if rawKey.hasPrefix(environment.sensitivityArgumentPrefix) {
                newArgs[key]          = shouldObfuscateSensitiveArguments
                ? String(repeating: obfuscationCharacter, count: value.count)
                : value
            }
            // All others pass through
            else {
                newArgs[key]          = value
            }
        }
        let cleaned                   = Message(
            payload: message.payload,
            priority: message.priority,
            arguments: newArgs,
            actions: message.actions,
            formattingInfo: message.formattingInfo
        )
        // default behavior: print the cleaned message
        print(cleaned)
    }
    
    //MARK: Miscellaneous APIs
    let environment: MessageInterpretingEnvironmentProviding
}
