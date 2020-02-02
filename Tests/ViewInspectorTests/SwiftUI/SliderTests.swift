import XCTest
import SwiftUI
@testable import ViewInspector

#if !os(tvOS)

final class SliderTests: XCTestCase {
    
    @State var value1: Float = 0
    @State var value2: Float = 0
    
    func testEnclosedView() throws {
        let view = Slider(value: $value1, label: { Text("Title") })
        let text = try view.inspect().slider().text().string()
        XCTAssertEqual(text, "Title")
    }
    
    func testResetsModifiers() throws {
        let view = Slider(value: $value1, label: { Text("Title") }).padding()
        let sut = try view.inspect().slider().text()
        XCTAssertEqual(sut.content.modifiers.count, 0)
    }
    
    func testExtractionFromSingleViewContainer() throws {
        let view = AnyView(Slider(value: $value1))
        XCTAssertNoThrow(try view.inspect().anyView().slider())
    }
    
    func testExtractionFromMultipleViewContainer() throws {
        let view = HStack { Slider(value: $value1); Slider(value: $value2) }
        XCTAssertNoThrow(try view.inspect().hStack().slider(0))
        XCTAssertNoThrow(try view.inspect().hStack().slider(1))
    }
    
    func testEditingChanged() throws {
        let exp = XCTestExpectation(description: "Callback")
        let view = Slider(value: $value1, in: 0...100, step: 1) { _ in
            exp.fulfill()
        }
        try view.inspect().slider().callOnEditingChanged()
        wait(for: [exp], timeout: 0.5)
    }
}

#endif
