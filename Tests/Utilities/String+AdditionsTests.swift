//
//  StringUtilitiesTests.swift
//  
//
//  Created by Georg Tuparev on 29/01/2020.
//  Copyright © See Framework's LICENSE file
//

import XCTest
@testable import SoftwareEtudesUtilities

final class StringUtilitiesTests: XCTestCase {

    func test_substring() {
        XCTAssertEqual(str.substring(from: -15, to: 234), str)
        XCTAssertEqual(str.substring(from: 15, to: -234), "")
        XCTAssertEqual(str.substring(to: 234), str)
        XCTAssertEqual(str.substring(to: 2), "01")
        XCTAssertEqual(str.substring(from: 2), "23456789")
        XCTAssertEqual(str.substring(from: 2, to: 9), "2345678")
        XCTAssertEqual(str.substring(from: 2, to: 3), "2")
        XCTAssertEqual(str.substring(from: 2, to: 2), "")
    }

    func test_substringFromLength() {
        XCTAssertEqual(str.substring(from: -15, length: 100), str)
        XCTAssertEqual(str.substring(length: 100), str)
        XCTAssertEqual(str.substring(length: 3), "012")
        XCTAssertEqual(str.substring(from: 1, length: 3), "123")
    }

    func test_substringLengthTo() {
        XCTAssertEqual(str.substring(length: 100, to: nil), str)
        XCTAssertEqual(str.substring(length: 100, to: 7), "0123456")
        XCTAssertEqual(str.substring(length: 3, to: 8), "567")
    }

    func test_containsOnly() {
        XCTAssertFalse("".containsOnly(character: "a"))
        XCTAssertTrue("a".containsOnly(character: "a"))
        XCTAssertTrue("bb".containsOnly(character: "b"))
        XCTAssertFalse("aaa".containsOnly(character: "b"))
  }

    func test_replaceMatchesFromDictionary() {
        let sut1 = "This string needs to replace <@bla@> with Tralala"
        let sut2 = "This string needs to replace <@bla@> with Tralala and <@noMatch@>"
        let dict = ["bla" : "Tralala"]

        XCTAssertEqual(sut1.replace(matches: dict), "This string needs to replace Tralala with Tralala")
        XCTAssertEqual(sut2.replace(matches: dict), "This string needs to replace Tralala with Tralala and NO MATCH")
    }

    func test_PrefixAndPostfix() {
        let str1 = "this is a string ..."
        let str2 = "... this is a string"

        XCTAssertEqual(str1.withoutSuffix(" ..."), "this is a string")
        XCTAssertEqual(str1.withoutSuffix(" ...").withoutSuffix(" ..."), "this is a string")

        XCTAssertEqual(str2.withoutPrefix("... "), "this is a string")
        XCTAssertEqual(str2.withoutPrefix("... ").withoutPrefix("... "), "this is a string")

        XCTAssertEqual(str1.withoutSuffix(" ...").appendingSuffixIfNeeded(" ..."), str1)
        XCTAssertEqual(str1.withoutSuffix(" ...").appendingSuffixIfNeeded(" ...").appendingSuffixIfNeeded(" ..."), str1)

        XCTAssertEqual(str2.withoutPrefix("... ").appendingPrefixIfNeeded("... "), str2)
        XCTAssertEqual(str2.withoutPrefix("... ").appendingPrefixIfNeeded("... ").appendingPrefixIfNeeded("... "), str2)
    }

    func test_StringUtilities_mustStartWithAtSignExtension_shouldSucceed() throws {
        XCTAssertEqual("@bla", "bla".mustStartWithAtSign())
        XCTAssertEqual("@bla", "@bla".mustStartWithAtSign())
    }

    func test_FilesAndPaths_normalisedPath_shouldSucceed() throws {
        XCTAssertEqual("/a/b/c/", "/a/b/c".normalisedFolderPath())
        XCTAssertEqual("/a/b/c/", "/a/b/c/".normalisedFolderPath())
    }

    var str = ""

    override func setUp() {
        super.setUp()
        str = "0123456789"
    }

    override func tearDown() {
        super.tearDown()
    }


    static var allTests = [
        ("test_substring",                                                  test_substring),
        ("test_substringFromLength",                                        test_substringFromLength),
        ("test_substringLengthTo",                                          test_substringLengthTo),
        ("test_containsOnly",                                               test_containsOnly),
        ("test_replaceMatchesFromDictionary",                               test_replaceMatchesFromDictionary),
        ("test_PrefixAndPostfix",                                           test_PrefixAndPostfix),
        ("test_StringUtilities_mustStartWithAtSignExtension_shouldSucceed", test_StringUtilities_mustStartWithAtSignExtension_shouldSucceed),
        ("test_FilesAndPaths_normalisedPath_shouldSucceed",                 test_FilesAndPaths_normalisedPath_shouldSucceed),
    ]

}
