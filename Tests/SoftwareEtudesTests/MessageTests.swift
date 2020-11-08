//
//  MessageTests.swift
//  
//
//  Created by Georg Tuparev on 11/09/2020.
//

import XCTest
@testable import SoftwareEtudes

final class MessageTests: XCTestCase {

    func test_messageCreationWithKey() {
        let sut = Message(payload: .key("Bla"), privacy: .noPrivacy, arguments: nil)

        XCTAssertTrue(MessageInterpreter().stringValue(sut).hasSuffix("Bla"))
    }

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

        static var allTests = [
            ("test_messageCreationWithKey", test_messageCreationWithKey)
        ]
}
