//
//  NodeTests.swift
//  
//
//  Created by Georg Tuparev on 29/02/2020.
//

import XCTest
@testable import SoftwareEtudes

final class NodeTests: XCTestCase {

    func test_nodeDescription() {
        let sut = Node("Blah")

        XCTAssertEqual(sut.description, ": Blah")
    }

    func test_nodeIdentity() {
        let sut = Node("Blah")

        XCTAssertEqual(sut, sut)
    }

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    static var allTests = [
        ("test_nodeDescription", test_nodeDescription),
        ("test_nodeIdentity", test_nodeIdentity),
    ]
}
