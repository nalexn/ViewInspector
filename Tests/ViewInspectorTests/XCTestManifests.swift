import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(AnyViewTests.allTests),
        testCase(HStackTests.allTests),
        testCase(TextTests.allTests),
    ]
}
#endif
