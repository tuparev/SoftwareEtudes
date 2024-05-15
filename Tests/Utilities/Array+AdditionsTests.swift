//
//  Array+AdditionsTests.swift
//
//
//  Created by Georg Tuparev on 15/05/2024.
//  Copyright © See Framework's LICENSE file
//
//  Thanks for contributions, suggestions, ideas by:
//      1. Zhanna Hakobyan - see CONTRIBUTORS
//

import Foundation

import XCTest

@testable import SoftwareEtudesUtilities

final class ArrayAdditionsTests: XCTestCase {
    //MARK: - Setup & Teardown -

    override class func setUp() {
        print("In class setUp.")
    }

    override class func tearDown() {
        print("In class tearDown.")
    }

    override func setUpWithError() throws {
        try super.setUpWithError()

        print("In setUp.")
    }

    override func tearDownWithError() throws {
        print("In tearDown.")

        try super.tearDownWithError()
    }

    //MARK: - Tests -
    func test_Array_removeMultipleElements_shouldSucceed() throws {
        // Given
        var sut = [1, 2, 3, 4, 5, 6, 7, 8]

        // When
        let removedElements = sut.removeElements(at: [1,3,5]).sorted(by: <)

        // Then
        XCTAssertEqual(sut, [1, 3, 5, 7, 8])
        XCTAssertEqual(removedElements.sorted(by: <), [2, 4, 6])
    }


    static var allTests = [
        ("test_Array_removeMultipleElements_shouldSucceed", test_Array_removeMultipleElements_shouldSucceed),
    ]

}

