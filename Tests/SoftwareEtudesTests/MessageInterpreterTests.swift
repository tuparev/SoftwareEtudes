//
//  MessageInterpreterTests.swift
//  
//
//  Created by Georg Tuparev on 06/02/2021.
//

import XCTest
@testable import SoftwareEtudes

final class MessageInterpreterTests: XCTestCase {

    func test_InterpreterCreation() {
        let sut = MessageInterpreter(privacy: .auto, defaultLanguage: "de")

        XCTAssertNotNil(sut)
        XCTAssertEqual(sut.defaultLanguage, "de")
        XCTAssertEqual(sut.privacy, .auto)
    }

    func test_UndefinedMessages() {
        let sut = MessageInterpreter(privacy: .auto)
        let m1  = Message(payload: .code(1), privacy: .auto)
        let m2  = Message(payload: .key("key"), privacy: .auto)

        XCTAssertEqual(sut.localizedStringValue(m1, language: "en"), "\(sut.undefinedMessageCodePrefix)1")
        XCTAssertEqual(sut.stringValue(m2), "\(sut.undefinedMessageKeyPrefix)key")
    }

    func test_attributeMatching() {
        let sut1 = MessageInterpreter(privacy: .auto, defaultLanguage: "en")
        let sut2 = MessageInterpreter(privacy: .auto, defaultLanguage: "de")

        let atr1 = ["bla" : "Blah is <@bla@>"]
        let atr2 = [42 : "no luck is <@42@>", 666 : "fatal error"]

        let msg1 = Message(payload: .key("bla"), privacy: .public, arguments: ["bla" : "really a very big bla"])
        let msg2 = Message(payload: .code(42), privacy: .auto, arguments: ["42" : "the meaning of life"])

        sut1.setMessagesForKeys(atr1, language: "en")
        sut2.setMessagesForCodes(atr2, language: "de")

        XCTAssertEqual(sut1.localizedStringValue(msg1, language: "en"), "Blah is really a very big bla")
        XCTAssertEqual(sut2.localizedStringValue(msg2, language: "de"), "no luck is the meaning of life")
    }
    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    static var allTests = [
        ("test_InterpreterCreation", test_InterpreterCreation)
    ]
}
