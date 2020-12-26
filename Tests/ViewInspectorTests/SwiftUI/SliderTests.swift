import XCTest
import SwiftUI
@testable import ViewInspector

@available(iOS 13.0, macOS 10.15, *)
@available(tvOS, unavailable)
final class SliderTests: XCTestCase {
    
    func testEnclosedView() throws {
        let binding = Binding<Float>(wrappedValue: 0)
        let view = Slider(value: binding, label: { Text("Title") })
        let text = try view.inspect().slider().labelView().text().string()
        XCTAssertEqual(text, "Title")
    }
    
    func testResetsModifiers() throws {
        let binding = Binding<Float>(wrappedValue: 0)
        let view = Slider(value: binding, label: { Text("Title") }).padding()
        let sut = try view.inspect().slider().labelView().text()
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
    
    func testSearch() throws {
        let binding = Binding<Float>(wrappedValue: 0)
        let view = AnyView(Slider(value: binding, label: { AnyView(Text("abc")) }))
        XCTAssertEqual(try view.inspect().find(ViewType.Slider.self).pathToRoot,
                       "anyView().slider()")
        XCTAssertEqual(try view.inspect().find(ViewType.Slider.self, containing: "abc").pathToRoot,
                       "anyView().slider()")
        XCTAssertEqual(try view.inspect().find(text: "abc").pathToRoot,
                       "anyView().slider().labelView().anyView().text()")
    }
    
    func testValue() throws {
        let binding = Binding<CGFloat>(wrappedValue: 0.4)
        let view = Slider(value: binding, label: { Text("") })
        let sut = try view.inspect().slider()
        XCTAssertEqual(try sut.value(), 0.4, accuracy: 0.0001)
        try sut.setValue(0.7)
        XCTAssertEqual(try sut.value(), 0.7, accuracy: 0.0001)
        XCTAssertEqual(binding.wrappedValue, 0.7, accuracy: 0.0001)
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
