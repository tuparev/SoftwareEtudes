//
//  MessageInterpreter.swift
//  
//
//  Created by Georg Tuparev on 08/09/2020.
//

import Foundation

public protocol MessageInterpreting {
    func stringValue(_ message: Messaging) -> String
}

public protocol LocalizedMessageInterpreting {
    func localizedStringValue(_ message: Messaging) -> String
}

//MARK: - Message Interpreter -
public class MessageInterpreter: MessageInterpreting, LocalizedMessageInterpreting {

    /// If `stringValue` cannot be defined  it will be nice to have at least something like "Message with code: 1234"
    private static var  emptyMessageCodePrefix = "Massage with code: "
    public  static func setEmptyMessagePrefix(_ prefix: String) { emptyMessageCodePrefix = prefix }

    /// If `stringValue` cannot be defined it will be nice to have at least something like "Message with key: veryBadError"
    private static var  emptyMessageKeyPrefix = "Message with key: "
    public  static func setEmptyMessageKeywordPrefix(_ prefix: String) { emptyMessageKeyPrefix = prefix }

    public init(bundles: [Bundle]? = nil, definitionFilesNames: [String]? = nil, languageCodes: [String]? = nil ) {
        //TODO: Implement me!
    }

    public func stringValue(_ message: Messaging) -> String {
        switch message.payload {
            case .key(let key):
                if let m = messageKeywords[key] { return m }
                else              { return "\(MessageInterpreter.emptyMessageKeyPrefix)\(key)" }
            case .code(let code):
                if let m = messageCodes[code] { return m }
                else                          { return "\(MessageInterpreter.emptyMessageKeyPrefix)\(code)" }
        }
    }

    public func localizedStringValue(_ message: Messaging) -> String {
        //TODO: Implement me!
        return ""
    }

    // Cached dictionaries
    private var messageCodes    = [Int : String]()
    private var messageKeywords = [String : String]()
}
