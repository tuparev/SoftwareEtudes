//
//  MessageInterpreting.swift
//  
//
//  Created by Georg Tuparev on 8.03.23.
//  Copyright © See Framework's LICENSE file
//

import Foundation

public protocol MessageInterpreting {
    init(environment: MessageInterpretingEnvironment)

    func interpret(_ message: Message)
}

public class AbstractMessageInterpreter: MessageInterpreting {

    public let environment: MessageInterpretingEnvironment


    required public init(environment: MessageInterpretingEnvironment) {
        self.environment = environment
    }

    public func interpret(_ message: Message) {
        print(message)
    }

}
