import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(AnyViewTests.allTests),
        testCase(BaseTypesTests.allTests),
        testCase(ButtonTests.allTests),
        testCase(CustomViewTests.allTests),
        testCase(DatePickerTests.allTests),
        testCase(FormTests.allTests),
        testCase(ForEach.allTests),
        testCase(GroupTests.allTests),
        testCase(HStackTests.allTests),
        testCase(ImageTests.allTests),
        testCase(InspectorTests.allTests),
        testCase(ScrollViewTests.allTests),
        testCase(SectionTests.allTests),
        testCase(TextTests.allTests),
        testCase(VStackTests.allTests),
        testCase(ZStackTests.allTests),
    ]
}
#endif
