import XCTest
import SwiftUI
@testable import ViewInspector

#if os(iOS) || os(macOS)

final class StepperTests: XCTestCase {
    
    @State var counter1: Int = 0
    @State var counter2: Int = 0
    
    func testEnclosedView() throws {
        let view1 = Stepper("Title1", value: $counter1)
        let view2 = Stepper(value: $counter1, label: { Text("Title2") })
        let text1 = try view1.inspect().text().string()
        let text2 = try view2.inspect().text().string()
        XCTAssertEqual(text1, "Title1")
        XCTAssertEqual(text2, "Title2")
    }
    
    func testResetsModifiers() throws {
        let view = Stepper("Title1", value: $counter1).padding()
        let sut = try view.inspect().stepper().text()
        XCTAssertEqual(sut.content.modifiers.count, 0)
    }
    
    func testExtractionFromSingleViewContainer() throws {
        let view = AnyView(Stepper("Test", value: $counter1))
        XCTAssertNoThrow(try view.inspect().stepper())
    }
    
    func testExtractionFromMultipleViewContainer() throws {
        let view = HStack {
            Stepper("Test", value: $counter1)
            Stepper("Test", value: $counter2)
        }
        XCTAssertNoThrow(try view.inspect().stepper(0))
        XCTAssertNoThrow(try view.inspect().stepper(1))
    }
    
    func testIncrement() throws {
        let exp = XCTestExpectation(description: "Callback")
        let view = Stepper("", onIncrement: {
            exp.fulfill()
        }, onDecrement: nil, onEditingChanged: { _ in })
        try view.inspect().increment()
        wait(for: [exp], timeout: 0.5)
    }
    
    func testDecrement() throws {
        let exp = XCTestExpectation(description: "Callback")
        let view = Stepper("", onIncrement: nil, onDecrement: {
            exp.fulfill()
        }, onEditingChanged: { _ in })
        try view.inspect().decrement()
        wait(for: [exp], timeout: 0.5)
    }
    
    func testEditingChanged() throws {
        let exp = XCTestExpectation(description: "Callback")
        let view = Stepper("", onIncrement: nil, onDecrement: nil,
                           onEditingChanged: { _ in
            exp.fulfill()
        })
        try view.inspect().callOnEditingChanged()
        wait(for: [exp], timeout: 0.5)
    }
}

#endif
