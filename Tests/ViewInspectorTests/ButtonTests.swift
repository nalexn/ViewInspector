import XCTest
import SwiftUI
@testable import ViewInspector

final class ButtonTests: XCTestCase {
    
    func testEnclosedView() throws {
        let button = Button(action: { }, label: { Text("Test") })
        let text = try button.inspect().text().string()
        XCTAssertEqual(text, "Test")
    }
    
    func testCallback() throws {
        let exp = XCTestExpectation(description: "Callback")
        let button = Button(action: {
            exp.fulfill()
        }, label: { Text("Test") })
        try button.inspect().tap()
        wait(for: [exp], timeout: 0.5)
    }
    
    static var allTests = [
        ("testEnclosedView", testEnclosedView),
        ("testCallback", testCallback),
    ]
}
