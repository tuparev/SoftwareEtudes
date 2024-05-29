//
//  MessageInterpretingEnvironment.swift
//  
//
//  Created by Georg Tuparev on 9.11.22.
//  Copyright © See Framework's LICENSE file
//

import Foundation

//
//TODO: Extract a protocol and make the Interpreter's environment to be of type of this protocol!
//

public class MessageInterpretingEnvironment {


    public struct CodedMessageTemplate: Codable {
        public let code: UInt
        public let messageTemplates: [String : String]   // Language code : Message text
    }

    public struct KeyedMessageTemplate: Codable {
        public let key: String
        public let messageTemplates: [String : String]   // Language code : Message text
    }

    public var shouldRejectCreatingMessageWithUnknownCodeOrKey = false
    public var defaultUnknownCode                              = UInt.max
    public var defaultUnknownKey                               = "<unknown>"

    public let defaultLanguageCode: String  // Default is "en"
    public var languagePreferences: [String]
    
    public private(set) var codedMessageTemplates = [CodedMessageTemplate]()
    public private(set) var keyedMessageTemplates = [KeyedMessageTemplate]()

    public var ignoreMessagesWithoutTemplate = true
    public var defaultMassageWithoutTemplate = "Message without templates with arguments: " // List of arguments will be appended

    public var ignoreUnmatchedAttributes         = true
    public var defaultUnmatchedAttributesMessage = " Unmatched attributes: "               // In case the template does not have markers for all attributes
    
    public init() {
        self.defaultLanguageCode = "en"
        self.languagePreferences = [defaultLanguageCode]
    }

    public func addCodedMessage(template: CodedMessageTemplate) { codedMessageTemplates.append(template) }
    public func addKeyedMessage(template: KeyedMessageTemplate) { keyedMessageTemplates.append(template) }

    public func emptyCodedMessageTemplates() { codedMessageTemplates.removeAll() }
    public func emptyKeyedMessageTemplates() { keyedMessageTemplates.removeAll() }

//    public func codedMessageTemplatesFrom(jsonString: String) throws {
//        let jsonDecoder = JSONDecoder() //TODO: Make it iVar
//
//        codedMessageTemplates = try jsonDecoder.decode([CodedMessageTemplate].self, from: jsonString.data(using: .utf8)!)
//    }
//
//    public func keyedMessageTemplatesFrom(jsonString: String) throws {
//        let jsonDecoder = JSONDecoder() //TODO: Make it iVar
//
//        keyedMessageTemplates = try jsonDecoder.decode([KeyedMessageTemplate].self, from: jsonString.data(using: .utf8)!)
//    }
}



