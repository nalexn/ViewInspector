import XCTest
import SwiftUI
@testable import ViewInspector

final class SliderTests: XCTestCase {
    
    @State var value1: Float = 0
    @State var value2: Float = 0
    
    func testEnclosedView() throws {
        let view = Slider(value: $value1, label: { Text("Title") })
        let text = try view.inspect().text().string()
        XCTAssertEqual(text, "Title")
    }
    
    func testExtractionFromSingleViewContainer() throws {
        let view = AnyView(Slider(value: $value1))
        XCTAssertNoThrow(try view.inspect().slider())
    }
    
    func testExtractionFromMultipleViewContainer() throws {
        let view = HStack { Slider(value: $value1); Slider(value: $value2) }
        XCTAssertNoThrow(try view.inspect().slider(0))
        XCTAssertNoThrow(try view.inspect().slider(1))
    }
    
    func testEditingChanged() throws {
        let exp = XCTestExpectation(description: "Callback")
        let view = Slider(value: $value1, in: 0...100, step: 1) { _ in
            exp.fulfill()
        }
        try view.inspect().callOnEditingChanged()
        wait(for: [exp], timeout: 0.5)
    }
}
