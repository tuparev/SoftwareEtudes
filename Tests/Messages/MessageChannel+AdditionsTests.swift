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
    var channel: AbstractMessageChannel!
    
    override func setUp() {
        super.setUp()
        channel = getChannel()
    }
    
    override func tearDown() {
        channel = nil
        super.tearDown()
    }
    
    fileprivate func getChannel() -> AbstractMessageChannel {
        let environment = MessageChannelEnvironment()
        let interpreter = AbstractMessageInterpreter.init(environment: MessageInterpretingEnvironment.init())
        let channel     = AbstractMessageChannel.init(environment: environment, interpreter: interpreter)
        let message     = Message(
            payload:        Message.Payload.code(code: 1),
            arguments:      ["password" : "!123456"],
            actions:        ["email"    : "test@tuparev.com"],
            formattingInfo: ["color"    : "#FF0000", "fontSize" : "14"])
        
        channel.channel(message: message)
        
        return channel
    }
    
    func test_channel_withSensitiveArgument_shouldSucceed() {
        let status = channel.privacyStatusFor(argument: "!123456")
        XCTAssertEqual(status, MessagePrivacy.sensitive)
    }
    
    static var allTests = [
        ("test_channel_withSensitiveArgument_shouldSucceed", test_channel_withSensitiveArgument_shouldSucceed)
    ]
}
