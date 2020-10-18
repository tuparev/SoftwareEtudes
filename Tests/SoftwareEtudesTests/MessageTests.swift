//
//  MessageTests.swift
//  
//
//  Created by Georg Tuparev on 11/09/2020.
//

import XCTest
@testable import SoftwareEtudes

final class MessageTests: XCTestCase {

    func test_messageCreationWithCode() {
        let sut = MessagePayload(key: "blah", code: nil, privacy: .noPrivacy, arguments: nil)

        XCTAssertEqual(sut?.key, "blah")
        XCTAssertNil(sut?.code)
    }

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

        static var allTests = [
            ("test_messageCreationWithCode", test_messageCreationWithCode)
        ]
}
