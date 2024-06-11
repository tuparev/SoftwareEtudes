//
//  MessageChannel+AdditionsTests.swift
//
//
//  Created by Zhanna Hakobyan on 03.06.24.
//

import Foundation
import XCTest
@testable import SoftwareEtudesMessages

final class MessageChannelAdditionsTests: XCTestCase {
    
    func test_channel_withSensitiveArgument_shouldSucceed() {
        let message     = Message(payload: Message.Payload.code(code: 1),
                                  arguments:      ["password" : "!123456"],
                                  actions:        ["email"    : "test@domain.com"],
                                  formattingInfo: ["color"    : "#FF0000", "fontSize" : "14"])
        let environment = MessageChannelEnvironment()
        let interpreter = AbstractMessageInterpreter.init(environment: MessageInterpretingEnvironment.init())
        let channel     = AbstractMessageChannel.init(environment: environment, interpreter: interpreter)
        
        channel.channel(message: message)
        
        let passwordKey = "password"
        guard let password = message.arguments?.first(where: { $0.key == passwordKey })?.value
        else { return XCTFail() }
        
        let status = channel.privacyStatusFor(argument: password)
        
        XCTAssertEqual(status, MessagePrivacy.sensitive)
    }
    
    static var allTests = [
        ("test_channel_withSensitiveArgument_shouldSucceed", test_channel_withSensitiveArgument_shouldSucceed)
    ]
}
