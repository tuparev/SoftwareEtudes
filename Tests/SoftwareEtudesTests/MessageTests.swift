//
//  MessageTests.swift
//  
//
//  Created by Georg Tuparev on 11/09/2020.
//

import XCTest
@testable import SoftwareEtudes

final class MessageTests: XCTestCase {

    let jsonEncoder = JSONEncoder()
    let jsonDecoder = JSONDecoder()
    var data: Data!
    var string: String!

    func test_messageCreationWithKeyAndCodes() {
        let sut1 = Message(payload: .key("Bla"), privacy: .public, arguments: nil)
        let sut2 = Message(payload: .code(3), privacy: .auto, arguments: nil)

        XCTAssertNotNil(sut1)
        XCTAssertNotNil(sut2)

        XCTAssertTrue(MessageInterpreter().stringValue(sut1).hasSuffix("Bla"))
        XCTAssertTrue(MessageInterpreter().stringValue(sut2).hasSuffix("3"))
    }

    func test_messageCodable() {
        let sut1 = Message(payload: .key("Bla"), privacy: .public, arguments: nil)
        let sut2 = Message(payload: .code(3), privacy: .auto, arguments: nil)

        data = try? jsonEncoder.encode(sut1)
        string = String(data: data!, encoding: .utf8)
        XCTAssertNoThrow(try jsonDecoder.decode(Message.self, from: string!.data(using: .utf8)!))

        data = try? jsonEncoder.encode(sut2)
        string = String(data: data!, encoding: .utf8)
        XCTAssertNoThrow(try jsonDecoder.decode(Message.self, from: string!.data(using: .utf8)!))
    }

    func test_messageComparable() {
        let sut1 = Message(payload: .key("Bla"), privacy: .public, arguments: nil)
        let sut2 = Message(payload: .key("Bla"), privacy: .public, arguments: nil)
        let sut3 = Message(payload: .key("Bla"), privacy: .sensitive, arguments: nil)
        let sut4 = Message(payload: .key("Bla"), privacy: .private, arguments: nil)

        XCTAssertFalse(sut1.privacy < sut2.privacy)
        XCTAssertEqual(sut1.privacy, sut2.privacy)
        XCTAssertTrue(sut1.privacy < sut3.privacy)
        XCTAssertFalse(sut3.privacy > sut4.privacy)
    }

    func test_messageObfuscation() {
        let attributes = ["key" : "blah"]
        let sut1 = Message(payload: .key("Bla"), privacy: .public, arguments: attributes)
        let sut2 = Message(payload: .key("Bla"), privacy: .sensitive, arguments: attributes)
        let sut3 = Message(payload: .key("Bla"), privacy: .private, arguments: attributes)

        XCTAssertEqual(sut1.arguments?.count, 1)
        XCTAssertEqual(sut1.arguments?["key"], "blah")

        XCTAssertEqual(sut2.arguments?.count, 1)
        XCTAssertEqual(sut2.arguments?["key"], "****")

        XCTAssertNil(sut3.arguments)
    }

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
        data = nil
        string = nil
    }

        static var allTests = [
            ("test_messageCreationWithKeyAndCodes", test_messageCreationWithKeyAndCodes),
            ("test_messageCodable", test_messageCodable),
            ("test_messageComparable", test_messageComparable),
            ("test_messageObfuscation", test_messageObfuscation),
        ]
}
