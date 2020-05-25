import XCTest
import SwiftUI
@testable import ViewInspector

#if os(iOS) || os(macOS)

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
final class StepperTests: XCTestCase {
    
    func testEnclosedView() throws {
        let binding = Binding<Int>(wrappedValue: 0)
        let view1 = Stepper("Title1", value: binding)
        let view2 = Stepper(value: binding, label: { Text("Title2") })
        let text1 = try view1.inspect().stepper().text().string()
        let text2 = try view2.inspect().stepper().text().string()
        XCTAssertEqual(text1, "Title1")
        XCTAssertEqual(text2, "Title2")
    }
    
    func testResetsModifiers() throws {
        let binding = Binding<Int>(wrappedValue: 0)
        let view = Stepper("Title1", value: binding).padding()
        let sut = try view.inspect().stepper().text()
        XCTAssertEqual(sut.content.modifiers.count, 0)
    }
    
    func testExtractionFromSingleViewContainer() throws {
        let binding = Binding<Int>(wrappedValue: 0)
        let view = AnyView(Stepper("Test", value: binding))
        XCTAssertNoThrow(try view.inspect().anyView().stepper())
    }
    
    func testExtractionFromMultipleViewContainer() throws {
        let binding = Binding<Int>(wrappedValue: 0)
        let view = HStack {
            Stepper("Test", value: binding)
            Stepper("Test", value: binding)
        }
        XCTAssertNoThrow(try view.inspect().hStack().stepper(0))
        XCTAssertNoThrow(try view.inspect().hStack().stepper(1))
    }
    
    func testIncrement() throws {
        let exp = XCTestExpectation(description: "Callback")
        let view = Stepper("", onIncrement: {
            exp.fulfill()
        }, onDecrement: nil, onEditingChanged: { _ in })
        try view.inspect().stepper().increment()
        wait(for: [exp], timeout: 0.5)
    }
    
    func testDecrement() throws {
        let exp = XCTestExpectation(description: "Callback")
        let view = Stepper("", onIncrement: nil, onDecrement: {
            exp.fulfill()
        }, onEditingChanged: { _ in })
        try view.inspect().stepper().decrement()
        wait(for: [exp], timeout: 0.5)
    }
    
    func testEditingChanged() throws {
        let exp = XCTestExpectation(description: "Callback")
        let view = Stepper("", onIncrement: nil, onDecrement: nil,
                           onEditingChanged: { _ in
            exp.fulfill()
        })
        try view.inspect().stepper().callOnEditingChanged()
        wait(for: [exp], timeout: 0.5)
    }
}

#endif
