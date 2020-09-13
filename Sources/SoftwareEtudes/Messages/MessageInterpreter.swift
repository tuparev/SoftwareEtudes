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

public protocol LocalisedMessageInterpreting {

}

//MARK: - Message Interpreter -
public class MessageInterpreter: MessageInterpreting, LocalisedMessageInterpreting {

    public init?(bundles: [Bundle]? = nil, definitionFilesNames: [String]? = nil, languageCodes: [String]? = nil ) {

    }

    public func stringValue(_ message: Messaging) -> String {
        //TODO: Implement me!
        return ""
    }
}
