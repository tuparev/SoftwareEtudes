import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(SemanticVersionTests.allTests),
        testCase(StringUtilitiesTests.allTests),
        testCase(NodeTests.allTests),
        XCTestCase(TreeNodeTests.allTests),
        XCTestCase(TypeNameDescribableTests.allTests),
        XCTestCase(MessageTests.allTests),
        XCTestCase(MessageInterpreterTests.allTests),
    ]
}
#endif
