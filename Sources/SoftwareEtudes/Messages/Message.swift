//
//  Message.swift
//  
//
//  Created by Georg Tuparev on 29/08/2020.
//

/// Message (Payload) is a super simple, super minimalistic, and performant way to communicate bits of information within
/// an application or across multiple processes.
/// The creation and the interpretation of a human readable and possibly localisable string is postponed until a message
/// reaches possible interpretation phase or it is discarded. Message interpretation might be implemented in a different
/// process running on a different computer running different operation system.
/// A massage contains either an integer `code`, or message `key` (String) or both (not advisable). If optional arguments
/// are provided, the message factory should respect user privacy settings. If user privacy s also a consideration,
/// messages containing arguments should not be permanently stored, or if storing is absolutely necessary, the arguments
/// should be either obfuscated or excluded all together.
/// The `MessageInterpreter`'s task is to generate human readable text (message). This text could be also localises.
/// **Note:** Originally arguments were defined as `AnyCodable` (an interface similar to `AnyHashable`), but because of
/// performance considerations, it was decided to use only String arguments.


import Foundation


/// `MessagePrivacy` defines the way how message arguments should be handled.
/// * `noPrivacy`       - arguments are visible, but it is strongly recommended, that this setting is used only in
///                       development. Such messages should never be permanently stored or sent to external message
///                       interpreter!
/// * `dataObfuscation` - Arguments should be replaced by string with equal length, but containing only `*` characters.
/// * `strictlyPrivate` - It is recommended to assign the arguments array to nil during message creation.
public enum MessagePrivacy: Int, Codable, CustomStringConvertible, CaseIterable {
    case noPrivacy
    case dataObfuscation
    case strictlyPrivate

    public var description: String {
        switch self {
            case .noPrivacy:       return "No privacy required"
            case .dataObfuscation: return "Arguments should be obfuscated"
            case .strictlyPrivate: return "Arguments should be discarded"
        }
    }
}

/// `Messaging` protocol defines a very simple, yet performant and enhanceable way to encapsulate short messages.
///
/// It is strongly advisable to create message with either `code` of `key` equal to nil. If both are not nil, the message
/// interpreter might deliver unpredictable message interpretation. If both are nil, a message should not be created.
public protocol Messaging: Codable {
    var key:       String?        { get }
    var code:      Int?           { get }
    var privacy:   MessagePrivacy { get }
    var arguments: [String]?      { get }
}


//MARK: - Simple Message Implementation -

/// `MessagePayload` is the simplest possible implementation of the `Messaging` protocol
public struct MessagePayload: Messaging {

    public var key: String?
    public var code: Int?
    public let privacy:   MessagePrivacy
    public var arguments: [String]?

    public init?(key: String? = nil, code: Int? = nil, privacy: MessagePrivacy, arguments: [String]? = nil) {
        guard (key == nil) && (code == nil)  else { return nil }

        self.key = key
        self.code = code
        self.privacy = privacy

        switch self.privacy {
            case .noPrivacy:                              self.arguments = arguments
            case .strictlyPrivate where arguments != nil: self.arguments = Array(repeating: "***", count: arguments!.count)
            default:                                      self.arguments = nil
        }
    }
}


