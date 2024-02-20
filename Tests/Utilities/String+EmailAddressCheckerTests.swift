//
//  String+EmailAddressCheckerTests.swift
//
//
//  Created by Georg Tuparev on 29/01/2022.
//  Copyright © See Framework's LICENSE file
//

import Foundation

import XCTest
@testable import SoftwareEtudesUtilities

final class EmailAddressCheckerTests: XCTestCase {

    func test_correctEmailAddresses() {
        let sut1 = "a@b.co"
        let sut2 = "user@example.org"
        let sut3 = "smart-user-4@physics.university.edu"

        XCTAssertTrue(sut1.isValidEmailAddress())
        XCTAssertTrue(sut2.isValidEmailAddress())
        XCTAssertTrue(sut3.isValidEmailAddress())
    }

    func test_incorrectEmailAddresses() {
        let sut1 = ""
        let sut2 = "🐈@🦮.animals"
        let sut3 = "system/dmin@company.com"
        let sut4 = "a@b.c"

        XCTAssertFalse(sut1.isValidEmailAddress())
        XCTAssertFalse(sut2.isValidEmailAddress())
        XCTAssertFalse(sut3.isValidEmailAddress())
        XCTAssertFalse(sut4.isValidEmailAddress())
    }
    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    static var allTests = [
        ("test_correctEmailAddresses",   test_correctEmailAddresses),
        ("test_incorrectEmailAddresses", test_incorrectEmailAddresses),
    ]

}
