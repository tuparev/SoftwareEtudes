//
//  Message.swift
//  
//
//  Created by Georg Tuparev on 29/08/2020.
//  Copyright © See Framework's LICENSE file
//

import Foundation


//MARK: - Simple Message Implementation -

/// `Message` is  simple and compact envelope to transfer information between sender and receiver through a channel in a efficient way
public struct Message: Codable, Sendable {

    public static let sensitivityArgumentPrefix = "!"
    public static let privacyArgumentPrefix     = "!!"

    /// `MessagePayload` encapsulate the actual body of the message.
    ///
    /// `MessagePayload` is either a code (Int value) or a key (String value). It is used by a type conforming to the  ``MessageInterpreting`` protocol  to  produce a human readable
    ///  message, possibly using the arguments. But `MessagePayload` could be also used to generate complex structures like XML or JSON by the message receiver..
    public enum Payload: Codable, Sendable, Comparable {
        case key(key: String)
        case code(code: Int)
    }

    /// `payload` is the actual body of the message
    public let payload: Payload

    ///  A key with `sensitivityArgumentPrefix` prefix indicates an explicit declaration os sensitive data, and with `privacyArgumentPrefix` - private data (like credit card number).
    ///  The MessageChannel might implement its own lists of sensitive and private data in addition to the explicitly defined in the message.
    public let arguments: [String : String]?

    ///  The Message Interpreter is free to implement the handling of list of actions. Examples for actions could be sending an email, ringing an alarm bell, performing database backup, ...
    public let actions: [String : String]?

    /// `formattingInfo` could be used by the Message Interpreter to format text values or configure different display options and be used to configure accessibility settings.
    public let formattingInfo: [String : String]?

    public init(payload: Payload, arguments: [String : String]? = nil, actions: [String : String]? = nil, formattingInfo: [String : String]? = nil) {
        self.payload        = payload
        self.arguments      = arguments
        self.actions        = actions
        self.formattingInfo = formattingInfo
    }
}

//MARK: - Extensions -

extension Message.Payload: CustomStringConvertible {
    public var description: String {
        switch self {
            case .key(let key):   return "Key: \(key)"
            case .code(let code): return "Code: \(code)"
        }
    }
}

extension Message: CustomStringConvertible {
    public var description: String {
        let payloadStr        = payload        .description
        let actionsStr        = actions?       .description ?? "<nil>"
        let argumentsStr      = arguments?     .description ?? "<nil>"
        let formattingInfoStr = formattingInfo?.description ?? "<nil>"

        return "Payload: \(payloadStr)\nArguments: \(argumentsStr)\nActions: \(actionsStr)\nFormattingInfo: \(formattingInfoStr)\n"
    }
}
