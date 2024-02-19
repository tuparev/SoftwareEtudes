//
//  SemanticVersionTests.swift
//  
//
//  Created by Georg Tuparev on 29/01/2020.
//  Copyright © See Framework's LICENSE file
//

import XCTest
@testable import SoftwareEtudesUtilities

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
        let sut1 = SemanticVersion(majorNumber: 1, minorNumber: 0, patchNumber: 17)
        let sut2 = SemanticVersion(majorNumber: 2)
        let sut3 = SemanticVersion(majorNumber: 3, minorNumber: 999999)
        let sut4 = SemanticVersion(with: "111.0.99-alpha.1")
        let sut5 = SemanticVersion(with: "111.0.99-alpha.1+1234.beta")

        XCTAssertEqual(sut1.description,  "1.0.17")
        XCTAssertEqual(sut2.description,  "2.0.0")
        XCTAssertEqual(sut3.description,  "3.999999.0")
        XCTAssertEqual(sut4?.description, "111.0.99-alpha.1")
        XCTAssertEqual(sut5?.description, "111.0.99-alpha.1+1234.beta")
    }

    func test_init_withCorrectVersionFromString_shouldReturnTrue() {
        let sut_major      = SemanticVersion(with: "1")
        let sut_minor      = SemanticVersion(with: "1.17")
        let sut_bug        = SemanticVersion(with: "111.0.99")
        let sut_preRelease = SemanticVersion(with: "111.0.99-alpha.1")
        let sut_buildMeta  = SemanticVersion(with: "111.0.99-alpha.1+1234.beta")

        XCTAssertNotNil(sut_major)
        XCTAssertEqual(sut_major?.majorNumber, 1)
        XCTAssertEqual(sut_major?.minorNumber, 0)
        XCTAssertEqual(sut_major?.patchNumber, 0)

        XCTAssertNotNil(sut_minor)
        XCTAssertEqual(sut_minor?.majorNumber, 1)
        XCTAssertEqual(sut_minor?.minorNumber, 17)
        XCTAssertEqual(sut_minor?.patchNumber, 0)

        XCTAssertNotNil(sut_bug)
        XCTAssertEqual(sut_bug?.majorNumber, 111)
        XCTAssertEqual(sut_bug?.minorNumber, 0)
        XCTAssertEqual(sut_bug?.patchNumber, 99)

        XCTAssertEqual(sut_preRelease?.preRelease, "alpha.1")
        XCTAssertEqual(sut_buildMeta?.preRelease, "alpha.1")
        XCTAssertEqual(sut_buildMeta?.buildMetadata, "1234.beta")

    }

    func test_init_withIncorrectVersionFromString_shouldReturnNil() {
        let sut_empty   = SemanticVersion(with: "")
        let sut_char    = SemanticVersion(with: "1.a.1b2")
        let sut_big_int = SemanticVersion(with: "999999999999999999999999999999999999999999999.0.0")

        XCTAssertNil(sut_empty)
        XCTAssertNil(sut_char)
        XCTAssertNil(sut_big_int)
    }

    func test_equatable_withEqualVersions_shouldReturnTrue() {
        let sut_equal_1 = SemanticVersion(majorNumber: 1, minorNumber: 0, patchNumber: 17)
        let sut_equal_2 = SemanticVersion(majorNumber: 1, minorNumber: 0, patchNumber: 17)

        XCTAssertEqual(sut_equal_1, sut_equal_2)
    }

    func test_equatable_withNotEqualVersions_shouldReturnTrue() {
        let sut_equal     = SemanticVersion(majorNumber: 1, minorNumber: 0, patchNumber: 17)
        let sut_not_equal = SemanticVersion(majorNumber: 3, minorNumber: 999999)

        XCTAssertNotEqual(sut_equal, sut_not_equal)
        XCTAssertTrue(sut_equal < sut_not_equal)
        XCTAssertTrue(sut_not_equal > sut_equal)
    }


    func test_comparable() {
        let sut_small            = SemanticVersion(majorNumber: 3, minorNumber: 3, patchNumber:3)
        let sut_large            = SemanticVersion(majorNumber: 99, minorNumber: 99, patchNumber:99)
        let sut_larger           = SemanticVersion(majorNumber: 99, minorNumber: 99, patchNumber:999)
        let sut_preRelease       = SemanticVersion(with: "99.99.999-alpha.1")
        let sut_largerPreRelease = SemanticVersion(with: "99.99.999-alpha.2")
        let sut_buildMeta        = SemanticVersion(with: "99.99.999+1234.beta")

        XCTAssertLessThan(sut_small, sut_large)
        XCTAssertGreaterThan(sut_large, sut_small)
        XCTAssertLessThanOrEqual(sut_small, sut_large)
        XCTAssertGreaterThanOrEqual(sut_large, sut_small)
        XCTAssertLessThanOrEqual(sut_small,sut_small)
        XCTAssertGreaterThanOrEqual(sut_large, sut_large)
        XCTAssertLessThan(sut_large, sut_larger)
        XCTAssertGreaterThanOrEqual(sut_larger, sut_preRelease!)
        XCTAssertLessThanOrEqual(sut_larger, sut_preRelease!)
        XCTAssertLessThanOrEqual(sut_preRelease!, sut_largerPreRelease!)
        XCTAssertLessThanOrEqual(sut_larger, sut_buildMeta!)
        XCTAssertGreaterThanOrEqual(sut_larger, sut_buildMeta!)
    }

    func test_convenienceMethods() {
        let sut_major         = SemanticVersion(majorNumber: 2, minorNumber: 1, patchNumber: 17)
        let next_major        = sut_major.nextMajorVersion()
        let sut_minor         = SemanticVersion(majorNumber: 11, minorNumber: 2, patchNumber: 17)
        let sut_another_minor = SemanticVersion(with: "11.2.17-alpha.1")
        let next_minor        = sut_minor.nextMinorVersion()
        let sut_patchNumber   = SemanticVersion(majorNumber: 1, minorNumber: 11, patchNumber: 111)
        let next_patchNumber  = sut_patchNumber.nextPatchVersion()

        XCTAssertEqual(next_major.majorNumber, 3)
        XCTAssertEqual(next_major.minorNumber, 0)
        XCTAssertEqual(next_major.patchNumber, 0)

        XCTAssertEqual(next_minor.majorNumber, 11)
        XCTAssertEqual(next_minor.minorNumber, 3)
        XCTAssertEqual(next_minor.patchNumber, 0)

        XCTAssertEqual(next_patchNumber.majorNumber, 1)
        XCTAssertEqual(next_patchNumber.minorNumber, 11)
        XCTAssertEqual(next_patchNumber.patchNumber, 112)

        XCTAssertEqual(sut_minor.minorNumber, sut_another_minor?.minorNumber)
    }

    func test_isValidVersionString() {
        // Valid
        XCTAssertTrue(SemanticVersion.isValid(version: "1.1.1"))
        XCTAssertTrue(SemanticVersion.isValid(version: "1.1.1-alpha.1"))
        XCTAssertTrue(SemanticVersion.isValid(version: "1.0.0-beta+exp.sha.5114f85"))

        // Invalide
        XCTAssertFalse(SemanticVersion.isValid(version: "1"))
        XCTAssertFalse(SemanticVersion.isValid(version: "1.1.1-alpha.%"))
    }

    func test_withPreReleaseVersion() {
        let sut_alpha         = SemanticVersion(with: "1.0.0-alpha.1")
        let sut_another_alpha = SemanticVersion(with: "1-alpha.1")
        let sut_beta          = SemanticVersion(with: "1.0.0-beta.1")
        let sut_another_beta  = SemanticVersion(majorNumber: 1, minorNumber: 0, patchNumber: 0, preReleaseVersion: "beta.1")

        XCTAssertNotNil(sut_alpha)
        XCTAssertNotNil(sut_beta)

        XCTAssertEqual(sut_alpha?.majorNumber, 1)
        XCTAssertEqual(sut_alpha?.minorNumber, 0)
        XCTAssertEqual(sut_alpha?.patchNumber, 0)

        XCTAssertEqual(sut_alpha, sut_another_alpha)

        XCTAssertEqual(sut_alpha?.preRelease, "alpha.1")
        XCTAssertEqual(sut_beta?.preRelease, "beta.1")
        XCTAssertEqual(sut_another_beta.preRelease, "beta.1")

        XCTAssertEqual(sut_beta!,sut_another_beta)
        XCTAssertLessThanOrEqual(sut_alpha!,sut_beta!)
        XCTAssertGreaterThanOrEqual(sut_another_beta, sut_alpha!)
    }

    func test_CodableCompliance() {
        let jsonEncoder = JSONEncoder()
        let jsonDecoder = JSONDecoder()
        var data: Data!
        var string: String!

        let sut_standard   = SemanticVersion(with: "1.17.2")
        let sut_preRelease = SemanticVersion(with: "111.0.99-alpha.1")
        let sut_buildMeta  = SemanticVersion(with: "111.0.99-alpha.1+1234.beta")

        data = try? jsonEncoder.encode(sut_standard)
        string = String(data: data!, encoding: .utf8)
        XCTAssertNoThrow(try jsonDecoder.decode(SemanticVersion.self, from: string!.data(using: .utf8)!))

        data = try? jsonEncoder.encode(sut_preRelease)
        string = String(data: data!, encoding: .utf8)
        XCTAssertNoThrow(try jsonDecoder.decode(SemanticVersion.self, from: string!.data(using: .utf8)!))

        data = try? jsonEncoder.encode(sut_buildMeta)
        string = String(data: data!, encoding: .utf8)
        XCTAssertNoThrow(try jsonDecoder.decode(SemanticVersion.self, from: string!.data(using: .utf8)!))
    }

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }


    static var allTests = [
        ("test_init_withoutDefaultValues_shouldReturnOneZeroZero",       test_init_withoutDefaultValues_shouldReturnOneZeroZero),
        ("test_init_withMajorVersion_shouldReturnTwoZeroZero",           test_init_withMajorVersion_shouldReturnTwoZeroZero),
        ("test_init_withMajorAndMinorVersions_shouldReturnThreeOneZero", test_init_withMajorAndMinorVersions_shouldReturnThreeOneZero),
        ("test_description_variousNumbers_shouldReturnTrue",             test_description_variousNumbers_shouldReturnTrue),
        ("test_init_withCorrectVersionFromString_shouldReturnTrue",      test_init_withCorrectVersionFromString_shouldReturnTrue),
        ("test_init_withIncorrectVersionFromString_shouldReturnNil",     test_init_withIncorrectVersionFromString_shouldReturnNil),
        ("test_equatable_withEqualVersions_shouldReturnTrue",            test_equatable_withEqualVersions_shouldReturnTrue),
        ("test_equatable_withNotEqualVersions_shouldReturnTrue",         test_equatable_withNotEqualVersions_shouldReturnTrue),
        ("test_comparable",                                              test_comparable),
        ("test_convenienceMethods",                                      test_convenienceMethods),
        ("test_isValidVersionString",                                    test_isValidVersionString),
        ("test_withPreReleaseVersion",                                   test_withPreReleaseVersion),
        ("test_CodableCompliance",                                       test_CodableCompliance),
    ]
}
