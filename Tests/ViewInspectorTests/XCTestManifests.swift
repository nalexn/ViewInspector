import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(AnyViewTests.allTests),
        testCase(BaseTypesTests.allTests),
        testCase(ButtonTests.allTests),
        testCase(CustomViewTests.allTests),
        testCase(InspectorTests.allTests),
        testCase(HStackTests.allTests),
        testCase(TextTests.allTests),
    ]
}
#endif
