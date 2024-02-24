//
//  SimpleNotConfiguredParsingTests.swift
//  
//
//  Created by Georg Tuparev on 03/02/2022.
//

import XCTest
import SoftwareEtudesExecutableConfiguration

class SimpleNotConfiguredParsingTests: XCTestCase {

    let noArguments       = ["my_utility"]
    let onlyOneOption     = ["my_utility", "-h"]
    let optionAndArgument = ["my_utility", "-h", "-o", "output.txt"]

    func test_withNoArguments() throws {
        let sut = CommandLineParser(arguments: noArguments)

        XCTAssertNotNil(sut)
        XCTAssertEqual(sut?.arguments(), noArguments)
        XCTAssertTrue(sut!.containsRaw(argument: "my_utility"))
    }

    func test_withOnlyOneOption() throws {
        let sut = CommandLineParser(arguments: onlyOneOption)

        XCTAssertNotNil(sut)
        XCTAssertEqual(sut?.arguments(), onlyOneOption)
        XCTAssertTrue(sut!.containsRaw(argument: "-h"))
        XCTAssertFalse(sut!.containsRaw(argument: "--help"))
    }

    func test_withOptionAndArgument() throws {
        let sut = CommandLineParser(arguments: optionAndArgument)

        XCTAssertNotNil(sut)
        XCTAssertEqual(sut?.arguments(), optionAndArgument)
        XCTAssertTrue(sut!.containsRaw(argument: "-o"))
        XCTAssertEqual(sut?.firstRawArgument(after: "-o"), "output.txt")
   }

    func test_withOptionAndArgumentAndUtilityName() throws {
        let sut = CommandLineParser(arguments: optionAndArgument)

        XCTAssertNotNil(sut)
        XCTAssertEqual(sut?.arguments(), optionAndArgument)
        XCTAssertEqual(sut?.utilityName, "my_utility")
        XCTAssertNil(sut!.shortDescription)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

    override func setUpWithError() throws {
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }


    static var allTests = [
        ("test_withNoArguments",                     test_withNoArguments),
        ("test_withOnlyOneOption",                   test_withOnlyOneOption),
        ("test_withOptionAndArgument",               test_withOptionAndArgument),
        ("test_withOptionAndArgumentAndUtilityName", test_withOptionAndArgumentAndUtilityName),
    ]

}
