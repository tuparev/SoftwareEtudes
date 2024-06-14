//
//  File.swift
//  
//
//  Created by Karen on 12.06.24.
//

import XCTest
@testable import SoftwareEtudesLogger
@testable import SoftwareEtudesMessages

final class LoggerTests: XCTestCase {
   
    func test_log() {}
    func test_logger() {}
    func test_logger_channel() {}
    
    
    func test_logger_with_channel_interpreter() {
        
        let message     = Message(payload: Message.Payload.code(code: 1),
                                  arguments:      ["password" : "!123456"],
                                  actions:        ["email"    : "test@domain.com"],
                                  formattingInfo: ["color"    : "#FF0000", "fontSize" : "14"])
        let environment = MessageChannelEnvironment()
        let interpreter = AbstractMessageInterpreter.init(environment: MessageInterpretingEnvironment.init())
        let channel     = AbstractMessageChannel.init(environment: environment, interpreter: interpreter)
        
        channel.channel(message: message)
    }
}
