import XCTest

import SoftwareEtudesTests

var tests = [XCTestCaseEntry]()
tests += SemanticVersioningTests.allTests()
//tests += MessageInterpreterTests.allTests()
//tests += MessageTests.allTests()
tests += SimpleNotConfiguredParsingTests.allTests()
tests += TimeIntervalUtilitiesTests.allTests()

XCTMain(tests)
