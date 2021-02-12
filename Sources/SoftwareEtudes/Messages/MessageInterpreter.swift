//
//  MessageInterpreter.swift
//  
//
//  Created by Georg Tuparev on 08/09/2020.
//

import Foundation

public protocol MessageInterpreting {
    var privacy: MessagePrivacy { get set }     // Default should be `auto`
    var defaultLanguage: String { get set }     // Default language should be "en"

    func setMessagesForCodes(_ messageDictionary: [Int : String], language: String?)
    func setMessagesForKeys(_ messageDictionary: [String : String], language: String?)

    func stringValue(_ message: Messaging) -> String    // Default language is used
    func localizedStringValue(_ message: Messaging, language: String) -> String
}

//MARK: - Message Interpreter -
public class MessageInterpreter: MessageInterpreting {

    public var privacy = MessagePrivacy.auto

    public var defaultLanguage = "en"         // English is assumed to be the default language

    /// Default message prefix if code is not set
    public var undefinedMessageCodePrefix = "Undefined massage with code: "

    /// Default message prefix if key is not set
    public var undefinedMessageKeyPrefix = "Undefined message with key: "


    public var startAttributeSeparator = "<@"
    public var endAttributeSeparator   = "@>"

    public init(privacy: MessagePrivacy = .auto, defaultLanguage: String = "en") {
        self.privacy = privacy
        self.defaultLanguage = defaultLanguage
    }

    public func setMessagesForCodes(_ messageDictionary: [Int : String], language: String? = nil) {
        let languageKey = language != nil ? language : defaultLanguage
        codeTables[languageKey!] = messageDictionary
    }

    public func setMessagesForKeys(_ messageDictionary: [String : String], language: String?) {
        let languageKey = language != nil ? language : defaultLanguage
        keyTables[languageKey!] = messageDictionary
   }

    public func stringValue(_ message: Messaging) -> String {
        return localizedStringValue(message,language: defaultLanguage)
    }

    public func localizedStringValue(_ message: Messaging, language: String) -> String {
        var rawMessage: String
        let arguments = message.arguments

        switch message.payload {
            case .code(let code):
                let message = codeTables[language]?[code]
                rawMessage = message != nil ? message! : "\(undefinedMessageCodePrefix)\(code)"
            case .key(let key):
                let message = keyTables[language]?[key]
                rawMessage = message != nil ? message! : "\(undefinedMessageKeyPrefix)\(key)"
        }

        if arguments != nil {
            rawMessage = rawMessage.replace(matches: arguments!, startMarker: startAttributeSeparator, endMarker: endAttributeSeparator)
        }

        return rawMessage
    }

    private var codeTables = [String : [Int : String]]()     // e.g. ["en" : [13 : "Blah"]]
    private var keyTables = [String : [String : String]]()   // e.g. ["de" : ["blahKey" : "Blah"]]

}
