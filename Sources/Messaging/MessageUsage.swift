//
//  MessageUsage.swift
//
//
//  Created by Zhanna Hakobyan on 05.06.24.
//

import Foundation
import SoftwareEtudesMessages
import SoftwareEtudesLogger

@main
struct Main {
    static func main() async throws {
//        let obj = MessageUsage()
//        obj.createChannel()
        
        let logger = Logger(label: "")
        
        logger.log(level: .trace,    "test")
        logger.log(level: .debug,    "test")
        logger.log(level: .info,     "test")
        logger.log(level: .notice,   "test")
        logger.log(level: .warning,  "test")
        logger.log(level: .error,    "test")
        logger.log(level: .critical, "test")
    }
}

struct MessageUsage {
    func createChannel() {
        let environment = MessageChannelEnvironment()
        let interpreter = AbstractMessageInterpreter.init(environment: MessageInterpretingEnvironment.init())
        let channel     = AbstractMessageChannel.init(environment: environment, interpreter: interpreter)
        let message     = Message(
                            payload:        Message.Payload.code(code: 1),
                            arguments:      ["password" : "!123456"],
                            actions:        ["email"    : "test@domain.com"],
                            formattingInfo: ["color"    : "#FF0000", "fontSize" : "14"])
        
        channel.channel(message: message)
        
        print("Channel created.\n\(message.description)")
    }
}
