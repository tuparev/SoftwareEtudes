//
//  JSONCodingTests.swift
//  
//
//  Created by Georg Tuparev on 09/03/2021.
//

import Foundation

import XCTest
@testable import SoftwareEtudes

final class JSONCodingTests: XCTestCase {

    class TestDecoder: JSONDecoder {

    }

    func test_DecoderSubclass() {
        let sut = JSONCoderWell.default

        sut.decoder = TestDecoder()

//        XCTFail()
    }

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    static var allTests = [
        ("test_DecoderSubclass", test_DecoderSubclass)
    ]
}
