import XCTest
import SwiftUI
@testable import ViewInspector

final class SecureFieldTests: XCTestCase {
    
    func testEnclosedView() throws {
        let binding = Binding(wrappedValue: "")
        let view = SecureField("Title", text: binding)
        let text = try view.inspect().secureField().text().string()
        XCTAssertEqual(text, "Title")
    }
    
    func testResetsModifiers() throws {
        let binding = Binding(wrappedValue: "")
        let view = SecureField("Title", text: binding).padding()
        let sut = try view.inspect().secureField().text()
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
