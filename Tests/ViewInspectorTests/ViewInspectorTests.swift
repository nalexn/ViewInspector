import XCTest
@testable import ViewInspector

final class ViewInspectorTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(ViewInspector().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
