import XCTest
import SwiftUI
@testable import ViewInspector

final class ButtonTests: XCTestCase {
    
    func testEnclosedView() throws {
        let button = Button(action: { }, label: { Text("Test") })
        let text = try button.inspect().text().string()
        XCTAssertEqual(text, "Test")
    }
    
    func testExtractionFromSingleViewContainer() throws {
        let view = AnyView(Button(action: {}, label: { Text("") }))
        XCTAssertNoThrow(try view.inspect().button())
    }
    
    func testExtractionFromMultipleViewContainer() throws {
        let view = HStack {
            Button(action: {}, label: { Text("") })
            Button(action: {}, label: { Text("") })
        }
        XCTAssertNoThrow(try view.inspect().button(0))
        XCTAssertNoThrow(try view.inspect().button(1))
    }
    
    func testCallback() throws {
        let exp = XCTestExpectation(description: "Callback")
        let button = Button(action: {
            exp.fulfill()
        }, label: { Text("Test") })
        try button.inspect().tap()
        wait(for: [exp], timeout: 0.5)
    }
}
