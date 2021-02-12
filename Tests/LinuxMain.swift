import XCTest

import SoftwareEtudesTests

var tests = [XCTestCaseEntry]()
tests += SemanticVersioningTests.allTests()
tests += MessageInterpreterTests.allTests()
tests += MessageTests.allTests()

XCTMain(tests)
