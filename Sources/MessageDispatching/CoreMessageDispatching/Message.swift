//===----------------------------------------------------------------------===//
//  Message.swift
//===----------------------------------------------------------------------===//
//
// This source file is part of the SoftwareEtudes open source project
//
// Copyright (c) 2020-2026 Tuparev Technologies and Friends
// Licensed under MIT License Modern Variant
//
// See LICENSE for license information
// See CONTRIBUTORS.md for the list of SoftwareEtudes contributors
//
// SPDX-License-Identifier: MIT-Modern-Variant
//
//===----------------------------------------------------------------------===//
//
//  Created by Georg Tuparev on 29/08/2020.
//

import Foundation

/// More "Swifty" implementation would use generics, but taking into account that messages could be send to remote processes, not implemented in Swift it was
/// decided to use a `String` dictionary for compatibility with other systems.
public typealias MessageProperties = [String : String]?


/// `MessageDescribing` defines the structure of an abstract message
///
/// This protocol fulfils following goals:
/// - allows messages to be sent to remote processes implemented in a different programming language;
/// - encourages message privacy;
/// - allows messages to be interpreted in a different ways (e.g. depending on the recipient, to be displayed in different languages);
/// - allows message receivers to format the message in different ways (e.g. to display errors in red);
/// - allows messages to carry information for further actions to be undertaken by the receiver (e.g. ring the alarm);
///
/// The messaging infrastructure built on this protocol could be flexible enough to be the core for different implementations: distributed logging, process monitoring
/// and analysis, messaging between IoT devices, and many others.
public protocol MessageDescribing: Codable, Sendable, Equatable, CustomStringConvertible {

    /// External provider of information about message argument privacy
    static var argumentSensitivityProvider: any MessageArgumentSensitivityDescribing { get }

    /// The main message payload - either a code (integer) or a key (string)
    ///
    /// This allows for maximum flexibility of  how the message will be interpreted and processed by the receiver and limits the size of the message.
    var payload: MessagePayload           { get }

    /// Used by the message dispatching system
    var priority: MessagePriority         { get }

    /// `arguments` carry the dynamic content of the message
    var arguments: MessageProperties      { get }

    /// Actions to be executed by the receiver
    var actions: MessageProperties        { get }

    /// Possible formatting hints
    var formattingInfo: MessageProperties { get }

    /// Designated initialiser
    init(payload: MessagePayload, priority: MessagePriority, arguments: MessageProperties, actions: MessageProperties, formattingInfo: MessageProperties)

    /// With the help of `argumentSensitivityProvider` these two methods decide if an argument is sensitive or private. It is recommended that sensitive
    /// arguments are obfuscated in production and private arguments are deleted.
    func isSensitiveArgument(_ argumentKey: String) -> Bool
    func isPrivateArgument(_ argumentKey: String) -> Bool
}

/// `MessageHandling` id used in a deferent way at different stations of the message workflow
///
/// - When used withe dispatching, `handle()` will try to despatch the message after consulting the delegate;
/// - When used withe interpreting, `handle()` will try to interpret the massage (format it, or perform actions etc.);
public protocol MessageHandling {
    func handle(_ message: Message) async throws
}

/// `MessagePayload` encapsulate the actual body of the message.
///
/// `MessagePayload` is either a code (Int value) or a key (String value). It is used by a type conforming to the  ``MessageInterpreting`` protocol  to
/// produce a human readable message, possibly using the arguments. `MessagePayload` could be also used to generate complex structures like XML or
/// JSON by the message receiver..
public enum MessagePayload: Codable, Sendable, Comparable {
    case key(key: String)
    case code(code: Int)
}

/// `MessagePriority` encapsulates the priority of the message
///
///  `MessagePriority` is an int, so that it allows comparison operations.. `info` has the lowest  (0) priority and  `critical` - the highest (99). This could
///  be used e.g. for dispatching (do not despatch all messages with priority lower than `high`).
public enum MessagePriority: Int, Codable, Sendable, CustomStringConvertible, Comparable {
    case info       = 0
    case debug      = 10
    case background = 20
    case normal     = 30
    case low        = 50
    case high       = 80
    case critical   = 90

    public var description: String {
        switch self {
            case .info:       return "INFO"
            case .debug:      return "DEBUG"
            case .background: return "BACKGROUND"
            case .low:        return "LOW"
            case .normal:     return "NORMAL"
            case .high:       return "HIGH"
            case .critical:   return "CRITICAL"
        }
    }
    
    // MARK: Comparable
    public static func < (lhs: MessagePriority, rhs: MessagePriority) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

//MARK: - Simple Message Implementation -

/// `Message` is  simple and compact envelope to transfer information between sender and receiver through a channel in a efficient way
public final class Message: MessageDescribing {
    public static var argumentSensitivityProvider: any MessageArgumentSensitivityDescribing = DefaultMessageArgumentSensitivityProvider()

    /// `payload` is the actual body of the message
    public let payload: MessagePayload

    /// The dispatch priority of the message
    public let priority: MessagePriority

    ///  A key with `sensitivityArgumentPrefix` prefix indicates an explicit declaration os sensitive data, and with `privacyArgumentPrefix` - private
    ///  data (like credit card number).  The MessageChannel might implement its own lists of sensitive and private data in addition to the explicitly defined in
    ///  the message.
    public let arguments: MessageProperties

    ///  The Message Interpreter is free to implement the handling of list of actions. Examples for actions could be sending an email, ringing an alarm bell,
    ///  performing database backup, ...
    public let actions: MessageProperties

    /// `formattingInfo` could be used by the Message Interpreter to format text values or configure different display options and be used to configure
    /// accessibility settings.
    public let formattingInfo: MessageProperties

    public init(payload: MessagePayload, priority: MessagePriority = .debug, arguments: MessageProperties = nil, actions: MessageProperties = nil, formattingInfo: MessageProperties = nil) {
        self.payload        = payload
        self.priority       = priority
        self.arguments      = arguments
        self.actions        = actions
        self.formattingInfo = formattingInfo
    }

    public func isSensitiveArgument(_ argumentKey: String) -> Bool { Message.argumentSensitivityProvider.isSensitiveArgument(argumentKey) }
    public func isPrivateArgument(_ argumentKey: String)   -> Bool { Message.argumentSensitivityProvider.isPrivateArgument(argumentKey) }
}

//MARK: - Extensions -

extension Message {
    // Required for Equatable
    public static func == (lhs: Message, rhs: Message) -> Bool {
        lhs.payload == rhs.payload && lhs.arguments == rhs.arguments && lhs.actions == rhs.actions && lhs.formattingInfo == rhs.formattingInfo
    }
}

extension Message {
    // Implementation of CustomStringConvertible
    //TODO: Needs proper testing
   public var description: String {
        let payloadStr        = payload.description
        let priorityStr       = priority
        let actionsStr        = actions?       .description ?? "<nil>"
        let argumentsStr      = arguments?     .description ?? "<nil>"
        let formattingInfoStr = formattingInfo?.description ?? "<nil>"
        
        return "Payload: \(payloadStr)\nPriority: \(priorityStr)\nArguments: \(argumentsStr)\nActions: \(actionsStr)\nFormattingInfo: \(formattingInfoStr)\n"
    }
}

extension MessagePayload: CustomStringConvertible {
    public var description: String {
        switch self {
            case .key(let key):   return "Key: \(key)"
            case .code(let code): return "Code: \(code)"
        }
    }
}

