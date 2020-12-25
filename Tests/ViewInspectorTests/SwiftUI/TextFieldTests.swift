import XCTest
import SwiftUI
@testable import ViewInspector

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
final class TextFieldTests: XCTestCase {
    
    func testEnclosedView() throws {
        let binding = Binding(wrappedValue: "")
        let view = TextField("Title", text: binding)
        let text = try view.inspect().textField().labelView().text().string()
        XCTAssertEqual(text, "Title")
    }
    
    func testResetsModifiers() throws {
        let binding = Binding(wrappedValue: "")
        let view = TextField("Title", text: binding).padding()
        let sut = try view.inspect().textField().labelView().text()
        XCTAssertEqual(sut.content.modifiers.count, 0)
    }
    
    func testExtractionFromSingleViewContainer() throws {
        let binding = Binding(wrappedValue: "")
        let view = AnyView(TextField("Test", text: binding))
        XCTAssertNoThrow(try view.inspect().anyView().textField())
    }
    
    func testExtractionFromMultipleViewContainer() throws {
        let binding = Binding(wrappedValue: "")
        let view = HStack {
            TextField("Test", text: binding)
            TextField("Test", text: binding)
        }
        XCTAssertNoThrow(try view.inspect().hStack().textField(0))
        XCTAssertNoThrow(try view.inspect().hStack().textField(1))
    }
    
    func testCallOnEditingChanged() throws {
        let exp = XCTestExpectation(description: "Callback")
        let binding = Binding(wrappedValue: "")
        let view = TextField("", text: binding, onEditingChanged: { _ in
            exp.fulfill()
        }, onCommit: { })
        try view.inspect().textField().callOnEditingChanged()
        wait(for: [exp], timeout: 0.5)
    }
    
    func testCallOnCommit() throws {
        let exp = XCTestExpectation(description: "Callback")
        let binding = Binding(wrappedValue: "")
        let view = TextField("", text: binding, onEditingChanged: { _ in }, onCommit: {
            exp.fulfill()
        })
        try view.inspect().textField().callOnCommit()
        wait(for: [exp], timeout: 0.5)
    }
    
    func testInput() throws {
        let binding = Binding(wrappedValue: "123")
        let view = TextField("", text: binding)
        let sut = try view.inspect().textField()
        XCTAssertEqual(try sut.input(), "123")
        try sut.setInput("abc")
        XCTAssertEqual(try sut.input(), "abc")
    }
}

// MARK: - View Modifiers

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
final class GlobalModifiersForTextField: XCTestCase {
    
    func testTextFieldStyle() throws {
        let sut = EmptyView().textFieldStyle(DefaultTextFieldStyle())
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testTextFieldStyleInspection() throws {
        let sut = EmptyView().textFieldStyle(DefaultTextFieldStyle())
        XCTAssertTrue(try sut.inspect().textFieldStyle() is DefaultTextFieldStyle)
    }
}
