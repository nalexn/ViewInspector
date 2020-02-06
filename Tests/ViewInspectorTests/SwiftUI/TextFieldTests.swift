import XCTest
import SwiftUI
@testable import ViewInspector

final class TextFieldTests: XCTestCase {
    
    func testEnclosedView() throws {
        let binding = Binding(wrappedValue: "")
        let view = TextField("Title", text: binding)
        let text = try view.inspect().textField().text().string()
        XCTAssertEqual(text, "Title")
    }
    
    func testResetsModifiers() throws {
        let binding = Binding(wrappedValue: "")
        let view = TextField("Title", text: binding).padding()
        let sut = try view.inspect().textField().text()
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
}

// MARK: - View Modifiers

final class GlobalModifiersForTextField: XCTestCase {
    
    func testTextFieldStyle() throws {
        let sut = EmptyView().textFieldStyle(DefaultTextFieldStyle())
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    #if !os(macOS)
    func testTextContentType() throws {
        let sut = EmptyView().textContentType(.emailAddress)
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    #endif
    
    #if os(iOS) || os(tvOS)
    func testKeyboardType() throws {
        let sut = EmptyView().keyboardType(.namePhonePad)
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testAutocapitalization() throws {
        let sut = EmptyView().autocapitalization(.words)
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    #endif
    
    func testDisableAutocorrection() throws {
        let sut = EmptyView().disableAutocorrection(false)
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
}
