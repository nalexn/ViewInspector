import XCTest
import SwiftUI
@testable import ViewInspector

#if !os(tvOS)

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
final class SliderTests: XCTestCase {
    
    func testEnclosedView() throws {
        let binding = Binding<Float>(wrappedValue: 0)
        let view = Slider(value: binding, label: { Text("Title") })
        let text = try view.inspect().slider().text().string()
        XCTAssertEqual(text, "Title")
    }
    
    func testResetsModifiers() throws {
        let binding = Binding<Float>(wrappedValue: 0)
        let view = Slider(value: binding, label: { Text("Title") }).padding()
        let sut = try view.inspect().slider().text()
        XCTAssertEqual(sut.content.modifiers.count, 0)
    }
    
    func testExtractionFromSingleViewContainer() throws {
        let binding = Binding<Float>(wrappedValue: 0)
        let view = AnyView(Slider(value: binding))
        XCTAssertNoThrow(try view.inspect().anyView().slider())
    }
    
    func testExtractionFromMultipleViewContainer() throws {
        let binding = Binding<Float>(wrappedValue: 0)
        let view = HStack { Slider(value: binding); Slider(value: binding) }
        XCTAssertNoThrow(try view.inspect().hStack().slider(0))
        XCTAssertNoThrow(try view.inspect().hStack().slider(1))
    }
    
    func testEditingChanged() throws {
        let exp = XCTestExpectation(description: "Callback")
        let binding = Binding<Float>(wrappedValue: 0)
        let view = Slider(value: binding, in: 0...100, step: 1) { _ in
            exp.fulfill()
        }
        try view.inspect().slider().callOnEditingChanged()
        wait(for: [exp], timeout: 0.5)
    }
}

#endif
