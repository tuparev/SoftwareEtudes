//
//  TimeIntervalUtilitiesTests.swift
//  
//
//  Created by Georg Tuparev on 28/03/2022.
//  Copyright © See Framework's LICENSE file
//

import XCTest
@testable import SoftwareEtudesUtilities

//TODO: Refactor test names
class TimeIntervalUtilitiesTests: XCTestCase {

    func test_timeIntervalsFromString() {
        let sut1 = Int(time: "12s")
        let sut2 = Int(time: "2m")
        let sut3 = Int(time: "2h")
        let sut4 = Int(time: "3d")

        XCTAssertEqual(sut1, 12)
        XCTAssertEqual(sut2, 2 * 60)
        XCTAssertEqual(sut3, 2 * 60 * 60 )
        XCTAssertEqual(sut4, 3 * 60 * 60 * 24)
    }

    func test_timeIntervalFunctions() {
        let sut1 = Int(time: "121s")
        let sut2 = Int(time: "2m")
        let sut3 = Int(time: "2h")
        let sut4 = Int(time: "3d")

        XCTAssertEqual(sut1!.s, 121)
        XCTAssertEqual(sut1!.m, 2)
        XCTAssertEqual(sut1!.h, 0)
        XCTAssertEqual(sut1!.d, 0)

        XCTAssertEqual(sut2!.s, 120)
        XCTAssertEqual(sut2!.m, 2)
        XCTAssertEqual(sut2!.h, 0)
        XCTAssertEqual(sut2!.d, 0)

        XCTAssertEqual(sut3!.s, 7200)
        XCTAssertEqual(sut3!.m, 120)
        XCTAssertEqual(sut3!.h, 2)
        XCTAssertEqual(sut3!.d, 0)

        XCTAssertEqual(sut4!.s, 3 * 24 * 3600)
        XCTAssertEqual(sut4!.m, 3 * 24 * 60)
        XCTAssertEqual(sut4!.h, 3 * 24)
        XCTAssertEqual(sut4!.d, 3)

    }

    func test_Int_timeInterval_shouldSucceed() throws {
        // Given
        let seconds = 3 * 24 * 3600 + 5 * 3600 + 17 * 60 + 11 // 3d 5h 17m 11s

        // When
        let testing = Int(time: "\(seconds)s")
        let sut = testing!.timeInterval()

        // Then
        XCTAssertEqual(sut.days, 3)
        XCTAssertEqual(sut.hours, 5)
        XCTAssertEqual(sut.minutes, 17)
        XCTAssertEqual(sut.seconds, 11)

    }

    override func setUp() {
       super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        super.tearDown()
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    static var allTests = [
        ("test_timeIntervalsFromString",        test_timeIntervalsFromString),
        ("test_timeIntervalFunctions",          test_timeIntervalFunctions),
        ("test_Int_timeInterval_shouldSucceed", test_Int_timeInterval_shouldSucceed),
    ]
}
