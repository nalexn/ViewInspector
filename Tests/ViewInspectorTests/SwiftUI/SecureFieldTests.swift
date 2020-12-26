import XCTest
import SwiftUI
@testable import ViewInspector

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
final class SecureFieldTests: XCTestCase {
    
    func testEnclosedView() throws {
        let binding = Binding(wrappedValue: "")
        let view = SecureField("Title", text: binding)
        let text = try view.inspect().secureField().labelView().text().string()
        XCTAssertEqual(text, "Title")
    }
    
    func testResetsModifiers() throws {
        let binding = Binding(wrappedValue: "")
        let view = SecureField("Title", text: binding).padding()
        let sut = try view.inspect().secureField().labelView().text()
        XCTAssertEqual(sut.content.modifiers.count, 0)
    }
    
    func testExtractionFromSingleViewContainer() throws {
        let binding = Binding(wrappedValue: "")
        let view = AnyView(SecureField("Test", text: binding))
        XCTAssertNoThrow(try view.inspect().anyView().secureField())
    }
    
    func testExtractionFromMultipleViewContainer() throws {
        let binding = Binding(wrappedValue: "")
        let view = HStack {
            SecureField("Test", text: binding)
            SecureField("Test", text: binding)
        }
        XCTAssertNoThrow(try view.inspect().hStack().secureField(0))
        XCTAssertNoThrow(try view.inspect().hStack().secureField(1))
    }
    
    func testSearch() throws {
        let binding = Binding(wrappedValue: "")
        let view = AnyView(SecureField("abc", text: binding))
        XCTAssertEqual(try view.inspect().find(ViewType.SecureField.self).pathToRoot,
                       "anyView().secureField()")
        XCTAssertEqual(try view.inspect().find(text: "abc").pathToRoot,
                       "anyView().secureField().labelView().text()")
    }
    
    func testInput() throws {
        let binding = Binding(wrappedValue: "123")
        let view = SecureField("", text: binding)
        let sut = try view.inspect().secureField()
        XCTAssertEqual(try sut.input(), "123")
        try sut.setInput("abc")
        XCTAssertEqual(try sut.input(), "abc")
    }
    
    func testCallOnCommit() throws {
        let exp = XCTestExpectation(description: "Callback")
        let binding = Binding(wrappedValue: "")
        let view = SecureField("", text: binding, onCommit: {
            exp.fulfill()
        })
        try view.inspect().secureField().callOnCommit()
        wait(for: [exp], timeout: 0.5)
    }
}
