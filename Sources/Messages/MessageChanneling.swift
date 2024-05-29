//
//  MessageChanneling.swift
//  
//
//  Created by Georg Tuparev on 07.03.2023.
//  Copyright © See Framework's LICENSE file
//

import Foundation

/// `MessagePrivacy` defines message argument's privacy level
///
/// Message arguments might contain sensitive information, and therefore should be handled with care. It is recommended
/// that sensitive information should not be visible for unauthorised people, and should not be made persistent. If
/// needed `public` and in some cases `auto` arguments could be stored permanently for later processing but `sensitive`
/// and `private` arguments should never be stored permanently or passed to external processes. 
///
/// The privacy considerations are valid only for arguments with a key starting with `Message.sensitivityArgumentPrefix` or
/// `Message.privacyArgumentPrefix`.
///
/// The enum is `Int` to allow comparison operations. The vocabulary of `OSLogPrivacy` struct (part of `OSLog` is used
/// whenever possible.
public enum MessagePrivacy: Int, Codable, Comparable, CaseIterable {
    /// `public` arguments are not redacted, but it is strongly recommended, that this option is used only during
    /// development and testing.
    case `public`  = 0

    /// `sensitive` arguments should be obfuscated and never stored permanently.
    case sensitive = 1

    /// `private` arguments should be deleted, never stored permanently, and never leave the initiating process.
    case `private` = 2
}

//
//TODO: Chain channels in a channel tree!
//

public protocol MessageChanneling {

    func channel(message: Message)
    func shouldChannel(message: Message) -> Bool
    func privacyStatusFor(argument: String) -> MessagePrivacy
}

public extension MessageChanneling {
    func shouldChannel(message: Message) -> Bool { true }
    func privacyStatusFor(argument: String) -> MessagePrivacy { .private } //TODO: Make proper implementation!
}

open class AbstractMessageChannel: MessageChanneling {

    public let environment: MessageChannelEnvironment
    public let interpreter: MessageInterpreting?

    public init(environment: MessageChannelEnvironment, interpreter: MessageInterpreting? = nil) {
        self.environment = environment
        self.interpreter = interpreter
    }

    public func channel(message: Message) {
        if shouldChannel(message: message) {
            var newArguments: [String : String]?

            if (message.arguments != nil) && (message.arguments!.count > 0) {
                newArguments = [String : String]()

                for anArgument in message.arguments! {
                    let privacyStatus    = privacyStatusFor(argument: anArgument.key)
                    let cleanArgumentKey = cleanup(argument: anArgument.key)

                    switch privacyStatus {
                        case .public:    newArguments![cleanArgumentKey] = anArgument.value
                        case .sensitive: newArguments![cleanArgumentKey] = String(repeating: environment.obfuscationCharacter, count: anArgument.value.count)
                        case .private:   if environment.shouldChannelPrivateArguments { newArguments![cleanArgumentKey] = anArgument.value }
                    }
                }
                if newArguments!.count == 0 { newArguments = nil }

                if interpreter != nil {
                    let newMessage = Message(payload: message.payload, arguments: newArguments, actions: message.actions, formattingInfo: message.formattingInfo)

                    interpreter!.interpret(newMessage)
                }
            }
        }
    }

    public func privacyStatusFor(argument: String) -> MessagePrivacy {
        if      argument.hasPrefix(Message.privacyArgumentPrefix)     { return .private }
        else if argument.hasPrefix(Message.sensitivityArgumentPrefix) { return .sensitive }
        else {
            let cleanArgument = cleanup(argument: argument)

            if environment.knownPublicArgumentKeys.contains(cleanArgument)         { return .public }
            else if environment.knownSensitiveArgumentKeys.contains(cleanArgument) { return .sensitive }
            else if environment.knownPrivateArgumentKeys.contains(cleanArgument)   { return .private }
            else                                                                   { return environment.assumeUnknownArgumentKeysAs }
        }
    }


    private func cleanup(argument: String) -> String {
        if      argument.hasPrefix(Message.privacyArgumentPrefix)     { return String(argument.dropFirst(2)) }
        else if argument.hasPrefix(Message.sensitivityArgumentPrefix) { return String(argument.dropFirst(1)) }
        else                                                          { return argument }
    }
}

//MARK: - MessagePrivacy extensions
extension MessagePrivacy:  CustomStringConvertible {
    public var description: String {
        switch self {
            case .`public`:  return "public"
            case .sensitive: return "sensitive"
            case .`private`: return "private"
        }
    }
}

extension MessagePrivacy: Equatable {
    public static func < (left: MessagePrivacy, right: MessagePrivacy) -> Bool { left.rawValue < right.rawValue }

}
