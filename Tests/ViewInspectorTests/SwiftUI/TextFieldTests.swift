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
        XCTAssertEqual(sut.content.medium.viewModifiers.count, 0)
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
    
    func testSearch() throws {
        let binding = Binding(wrappedValue: "")
        let view = AnyView(TextField("abc", text: binding))
        XCTAssertEqual(try view.inspect().find(ViewType.TextField.self).pathToRoot,
                       "anyView().textField()")
        XCTAssertEqual(try view.inspect().find(text: "abc").pathToRoot,
                       "anyView().textField().labelView().text()")
    }
    
    func testCallOnEditingChanged() throws {
        let exp = XCTestExpectation(description: #function)
        let binding = Binding(wrappedValue: "")
        let view = TextField("", text: binding, onEditingChanged: { _ in
            exp.fulfill()
        }, onCommit: { })
        try view.inspect().textField().callOnEditingChanged()
        wait(for: [exp], timeout: 0.1)
    }
    
    func testCallOnEditingChangedWhenDisabled() throws {
        let exp = XCTestExpectation(description: #function)
        exp.isInverted = true
        let binding = Binding(wrappedValue: "")
        let view = TextField("", text: binding, onEditingChanged: { _ in
            exp.fulfill()
        }, onCommit: { }).disabled(true)
        XCTAssertThrows(try view.inspect().textField().callOnEditingChanged(),
            "TextField is unresponsive: it is disabled")
        wait(for: [exp], timeout: 0.1)
    }
    
    func testCallOnCommit() throws {
        let exp = XCTestExpectation(description: #function)
        let binding = Binding(wrappedValue: "")
        let view = TextField("", text: binding, onEditingChanged: { _ in }, onCommit: {
            exp.fulfill()
        })
        try view.inspect().textField().callOnCommit()
        wait(for: [exp], timeout: 0.1)
    }
    
    func testCallOnCommitWhenDisabled() throws {
        let exp = XCTestExpectation(description: #function)
        exp.isInverted = true
        let binding = Binding(wrappedValue: "")
        let view = TextField("", text: binding, onEditingChanged: { _ in }, onCommit: {
            exp.fulfill()
        }).disabled(true)
        XCTAssertThrows(try view.inspect().textField().callOnCommit(),
            "TextField is unresponsive: it is disabled")
        wait(for: [exp], timeout: 0.1)
    }
    
    func testInput() throws {
        let binding = Binding(wrappedValue: "123")
        let view = TextField("", text: binding)
        let sut = try view.inspect().textField()
        XCTAssertEqual(try sut.input(), "123")
        try sut.setInput("abc")
        XCTAssertEqual(try sut.input(), "abc")
    }
    
    func testSetInputWhenDisabled() throws {
        let binding = Binding(wrappedValue: "123")
        let view = TextField("", text: binding).disabled(true)
        let sut = try view.inspect().textField()
        XCTAssertThrows(try sut.setInput("abc"),
            "TextField is unresponsive: it is disabled")
        XCTAssertEqual(try sut.input(), "123")
    }
    
    func testPrompt() throws {
        guard #available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
        else { throw XCTSkip() }
        let binding = Binding(wrappedValue: "")
        let view1 = TextField("", text: binding, prompt: Text("test"))
        let sut1 = try view1.inspect().textField().prompt().string()
        XCTAssertEqual(sut1, "test")
        let view2 = TextField("", text: binding)
        XCTAssertThrows(try view2.inspect().textField().prompt(),
                        "View for prompt is absent")
        let view3 = AnyView(TextField("", text: binding, prompt: Text("abc")))
        XCTAssertEqual(try view3.inspect().find(text: "abc").pathToRoot,
                       "anyView().textField().prompt().text()")
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
