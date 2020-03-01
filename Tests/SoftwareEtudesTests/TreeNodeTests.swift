//
//  TreeNodeTests.swift
//  
//
//  Created by Georg Tuparev on 01/03/2020.
//  Copyright © 2020 Tuparev Technologies. All rights reserved.
//

import Foundation

import XCTest
@testable import SoftwareEtudes

final class TreeNodeTests: XCTestCase {

    func test_nodeDescription() {
        let sut = TreeNode("Blah")

        XCTAssertEqual(sut.description, ": Blah")
    }

    func test_nodeIdentity() {
        let sut = TreeNode("Blah")

        XCTAssertEqual(sut, sut)
    }

    func test_ifSingleNodeIsRoot_shouldSucceed() {
        let sut = TreeNode("Blah")

        XCTAssertEqual(sut, sut.root())
    }

    func test_twoLevelTreeRoot_shouldSucceed() {
        let sutRoot = TreeNode("Blah")
        let sutChild = TreeNode("Child of Blah")

        sutRoot.children.append(sutChild)
        sutChild.parent = sutRoot

        XCTAssertEqual(sutRoot, sutChild.root())
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
        ("test_ifSingleNodeIsRoot_shouldSucceed", test_ifSingleNodeIsRoot_shouldSucceed),
        ("test_twoLevelTreeRoot_shouldSucceed", test_twoLevelTreeRoot_shouldSucceed),
    ]
}
