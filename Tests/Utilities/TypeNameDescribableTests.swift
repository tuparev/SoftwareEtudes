//
//  TypeNameDescribableTests.swift
//
//
//  Created by Georg Tuparev on 31/03/2020.
//  Copyright © See Framework's LICENSE file
//

import Foundation

import XCTest
@testable import SoftwareEtudesUtilities

final class TypeNameDescribableTests: XCTestCase, TypeNameDescribable {

    struct StrangeStruct: TypeNameDescribable {
        let blah: String?
    }

    func test_instance() {
        XCTAssertEqual("TypeNameDescribableTests", typeName)
    }

    func test_struct() {
        let sut = StrangeStruct(blah: "buzz")

        XCTAssertEqual("StrangeStruct", sut.typeName)
    }

    func test_class() {
        XCTAssertEqual("TypeNameDescribableTests", TypeNameDescribableTests.typeName)
    }

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    static var allTests = [
        ("test_instance", test_instance),
        ("test_struct", test_struct),
        ("test_zero", test_class),
    ]
}
