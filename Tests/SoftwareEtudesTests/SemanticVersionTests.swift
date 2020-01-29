//
//  SemanticVersionTests.swift
//  
//
//  Created by Georg Tuparev on 29/01/2020.
//

import XCTest
@testable import SoftwareEtudes

final class SemanticVersionTests: XCTestCase {

    func test_init_withoutDefaultValues_shouldReturnOneZeroZero() {
        let sut = SemanticVersion(majorNumber: 1, minorNumber: 0, patchNumber:0)

        XCTAssertEqual(sut.majorNumber, 1)
        XCTAssertEqual(sut.minorNumber, 0)
        XCTAssertEqual(sut.patchNumber, 0)
    }

    func test_init_withMajorVersion_shouldReturnTwoZeroZero() {
        let sut = SemanticVersion(majorNumber: 2)

        XCTAssertEqual(sut.majorNumber, 2)
        XCTAssertEqual(sut.minorNumber, 0)
        XCTAssertEqual(sut.patchNumber, 0)
    }


    func test_init_withMajorAndMinorVersions_shouldReturnThreeOneZero() {
        let sut = SemanticVersion(majorNumber: 3, minorNumber: 1)

        XCTAssertEqual(sut.majorNumber, 3)
        XCTAssertEqual(sut.minorNumber, 1)
        XCTAssertEqual(sut.patchNumber, 0)
    }

    func test_description_variousNumbers_shouldReturnTrue() {
        let sud1 = SemanticVersion(majorNumber: 1, minorNumber: 0, patchNumber: 17)
        let sud2 = SemanticVersion(majorNumber: 2)
        let sud3 = SemanticVersion(majorNumber: 3, minorNumber: 999999)

        XCTAssertEqual(sud1.description, "1.0.17")
        XCTAssertEqual(sud2.description, "2.0.0")
        XCTAssertEqual(sud3.description, "3.999999.0")
    }

    func test_init_withCorrectVersionFromString_shouldReturnTrue() {
        let sud_major = SemanticVersion(with: "1")
        let sud_minor = SemanticVersion(with: "1.17")
        let sud_bug = SemanticVersion(with: "111.0.99")

        XCTAssertNotNil(sud_major)
        XCTAssertEqual(sud_major?.majorNumber, 1)
        XCTAssertEqual(sud_major?.minorNumber, 0)
        XCTAssertEqual(sud_major?.patchNumber, 0)

        XCTAssertNotNil(sud_minor)
        XCTAssertEqual(sud_minor?.majorNumber, 1)
        XCTAssertEqual(sud_minor?.minorNumber, 17)
        XCTAssertEqual(sud_minor?.patchNumber, 0)

        XCTAssertNotNil(sud_bug)
        XCTAssertEqual(sud_bug?.majorNumber, 111)
        XCTAssertEqual(sud_bug?.minorNumber, 0)
        XCTAssertEqual(sud_bug?.patchNumber, 99)
    }

    func test_init_winIncorrectVersionFromString_shouldReturnNil() {
        let sud_empty = SemanticVersion(with: "")
        let sud_char = SemanticVersion(with: "1.a.1b2")
        let sud_big_int = SemanticVersion(with: "999999999999999999999999999999999999999999999.0.0")

        XCTAssertNil(sud_empty)
        XCTAssertNil(sud_char)
        XCTAssertNil(sud_big_int)
    }

    func test_equatable_withEqualVersions_shouldReturnTrue() {
        let sud_equal_1 = SemanticVersion(majorNumber: 1, minorNumber: 0, patchNumber: 17)
        let sud_equal_2 = SemanticVersion(majorNumber: 1, minorNumber: 0, patchNumber: 17)

        XCTAssertEqual(sud_equal_1, sud_equal_2)
    }

    func test_equatable_withNotEqualVersions_shouldReturnTrue() {
        let sud_equal = SemanticVersion(majorNumber: 1, minorNumber: 0, patchNumber: 17)
        let sud_not_equal = SemanticVersion(majorNumber: 3, minorNumber: 999999)

        XCTAssertNotEqual(sud_equal, sud_not_equal)
    }


    func test_comparable() {
        let sud_small = SemanticVersion(majorNumber: 3, minorNumber: 3, patchNumber:3)
        let sud_large = SemanticVersion(majorNumber: 99, minorNumber: 99, patchNumber:99)
        let sud_larger = SemanticVersion(majorNumber: 99, minorNumber: 99, patchNumber:999)

        XCTAssertLessThan(sud_small, sud_large)
        XCTAssertGreaterThan(sud_large, sud_small)
        XCTAssertLessThanOrEqual(sud_small, sud_large)
        XCTAssertGreaterThanOrEqual(sud_large, sud_small)
        XCTAssertLessThanOrEqual(sud_small,sud_small)
        XCTAssertGreaterThanOrEqual(sud_large, sud_large)
        XCTAssertLessThan(sud_large, sud_larger)
    }

    func test_convenienceMethods() {
        let sud_major = SemanticVersion(majorNumber: 2, minorNumber: 1, patchNumber: 17)
        let next_major = sud_major.nextMajorVersion()
        let sud_minor = SemanticVersion(majorNumber: 11, minorNumber: 2, patchNumber: 17)
        let next_minor = sud_minor.nextMinorVersion()
        let sud_patchNumber = SemanticVersion(majorNumber: 1, minorNumber: 11, patchNumber: 111)
        let next_patchNumber = sud_patchNumber.nextPatchVersion()

        XCTAssertEqual(next_major.majorNumber, 3)
        XCTAssertEqual(next_major.minorNumber, 0)
        XCTAssertEqual(next_major.patchNumber, 0)

        XCTAssertEqual(next_minor.majorNumber, 11)
        XCTAssertEqual(next_minor.minorNumber, 3)
        XCTAssertEqual(next_minor.patchNumber, 0)

        XCTAssertEqual(next_patchNumber.majorNumber, 1)
        XCTAssertEqual(next_patchNumber.minorNumber, 11)
        XCTAssertEqual(next_patchNumber.patchNumber, 112)
    }

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }


    static var allTests = [
        ("test_init_withoutDefaultValues_shouldReturnOneZeroZero", test_init_withoutDefaultValues_shouldReturnOneZeroZero),
        ("test_init_withMajorVersion_shouldReturnTwoZeroZero", test_init_withMajorVersion_shouldReturnTwoZeroZero),
        ("test_init_withMajorAndMinorVersions_shouldReturnThreeOneZero", test_init_withMajorAndMinorVersions_shouldReturnThreeOneZero),
        ("test_description_variousNumbers_shouldReturnTrue", test_description_variousNumbers_shouldReturnTrue),
        ("test_init_withCorrectVersionFromString_shouldReturnTrue", test_init_withCorrectVersionFromString_shouldReturnTrue),
        ("test_init_winIncorrectVersionFromString_shouldReturnNil", test_init_winIncorrectVersionFromString_shouldReturnNil),
        ("test_equatable_withEqualVersions_shouldReturnTrue", test_equatable_withEqualVersions_shouldReturnTrue),
        ("test_equatable_withNotEqualVersions_shouldReturnTrue", test_equatable_withNotEqualVersions_shouldReturnTrue),
        ("test_comparable", test_comparable),
        ("test_convenienceMethods", test_convenienceMethods)
    ]
}
