//
//  Message.swift
//  
//
//  Created by Georg Tuparev on 29/08/2020.
//

/// Message (Payload) is a super simple, super minimalistic, and performant way to communicate bits of information within
/// an application or across multiple processes.
/// The creation and the interpretation of a human readable and possibly localisable string is postponed until a message
/// reaches possible interpretation phase (if not discarded). Message interpretation might be implemented in a different
/// process running on a different computer running different operation system.
/// A massage contains either an integer `code`, or message `key` (String). If optional arguments are provided, the
/// message factory should respect user privacy settings. If user privacy is also a consideration, messages containing
/// arguments should not be permanently stored, or if storing is absolutely necessary, the arguments should be either
/// obfuscated or excluded all together.
/// The `MessageInterpreter`'s task is to generate human readable text (message). This text could be also localised.
/// **Note:** Originally arguments were defined as `AnyCodable` (an interface similar to `AnyHashable`), but because of
/// performance considerations, I decided to use only String arguments.

import Foundation


/// `MessagePrivacy` defines the way how message arguments should be handled. The type is int to help compassion
/// operations.
/// * `noPrivacy`       - arguments are visible, but it is strongly recommended, that this setting is used only in
///                       development.
/// * `dataObfuscation` - Arguments should be obfuscated.
/// * `strictlyPrivate` - It is recommended to remove the arguments during message creation or interpretation.
public enum MessagePrivacy: Int, Codable, CustomStringConvertible, CaseIterable {
    case noPrivacy
    case dataObfuscation
    case strictPrivacy

    public var description: String {
        switch self {
            case .noPrivacy:       return "No privacy required"
            case .dataObfuscation: return "Arguments should be obfuscated"
            case .strictPrivacy:   return "Arguments should be discarded"
        }
    }


}

public enum MessagePayload: Codable, CustomStringConvertible {
    case key(String)
    case code(Int)

    public init(from decoder: Decoder) throws {
        if      let value = try? String(from: decoder) { self = .key(value) }
        else if let value = try? Int(from: decoder)    { self = .code(value) }
        else {
            let context = DecodingError.Context(
                codingPath: decoder.codingPath,
                debugDescription: "Cannot decode \(String.self) or \(Int.self)")
            throw DecodingError.dataCorrupted(context)
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        switch self {
            case .key(let key):   try container.encode(String(key))
            case .code(let code): try container.encode(Int(code))
        }
    }

    public var description: String {
        switch self {
            case .key(let key):   return "Key: \(key)"
            case .code(let code): return "Code: \(code)"
        }
    }
}

/// `Messaging` protocol defines a very simple, yet performant and enhanceable way to encapsulate short messages.
///
/// It is strongly advisable to create message with either `code` of `key` equal to nil. If both are not nil, the message
/// interpreter might deliver unpredictable message interpretation. If both are nil, a message should not be created.
//TODO: Use MessagePayloadProtocol
public protocol Messaging: Codable {
    var payload:   MessagePayload     { get }
    var privacy:   MessagePrivacy     { get }
    var arguments: [String : String]? { get }
}


//MARK: - Simple Message Implementation -

/// `MessagePayload` is the simplest possible implementation of the `Messaging` protocol
public struct Message: Messaging {

    public var payload:   MessagePayload
    public let privacy:   MessagePrivacy
    public var arguments: [String : String]?

    public init(payload: MessagePayload, privacy: MessagePrivacy, arguments: [String : String]? = nil) {
        self.payload = payload
        self.privacy = privacy

        switch self.privacy {
            case .noPrivacy:                              self.arguments = arguments
            case .dataObfuscation where arguments != nil: self.arguments = obfuscated(dictionary: arguments!)
            default:                                      self.arguments = nil
        }
    }

    private func obfuscated(dictionary: [String : String]) -> [String : String] {
        var result = [String : String]()

        for (k, v) in dictionary { result[k] = String(repeating: "*", count: v.count) }
        return result
    }
}

