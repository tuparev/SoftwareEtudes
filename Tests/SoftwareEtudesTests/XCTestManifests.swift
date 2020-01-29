import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(SemanticVersionTests.allTests),
        testCase(StringUtilitiesTests.allTests)
    ]
}
#endif
