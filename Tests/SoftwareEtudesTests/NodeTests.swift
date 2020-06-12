//
//  NodeTests.swift
//  
//
//  Created by Georg Tuparev on 29/02/2020.
//  Copyright © 2020 Tuparev Technologies. All rights reserved.
//

import XCTest
@testable import SoftwareEtudes

final class NodeTests: XCTestCase {

    func test_nodeDescription() {
        let sut = Node(with: "Blah", named: "Blah")
        let sutNil = Node<String>()

        //FIXME:
        XCTAssertEqual(sut.name, "Blah")
        XCTAssertNotNil(sutNil)
    }

    func test_nodeIdentity() {
        let sut = Node(with: "Blah", named: nil)

        XCTAssertNotNil(sut)

        //FIXME:
//        XCTAssertEqual(sut, sut)
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
