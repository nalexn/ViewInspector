import XCTest
import SwiftUI
@testable import ViewInspector

final class TextFieldTests: XCTestCase {
    
    @State var text1 = ""
    @State var text2 = ""
    
    override func setUp() {
        text1 = ""
        text2 = ""
    }
    
    func testEnclosedView() throws {
        let view = TextField("Title", text: $text1)
        let text = try view.inspect().text().string()
        XCTAssertEqual(text, "Title")
    }
    
    func testExtractionFromSingleViewContainer() throws {
        let view = AnyView(TextField("Test", text: $text1))
        XCTAssertNoThrow(try view.inspect().textField())
    }
    
    func testExtractionFromMultipleViewContainer() throws {
        let view = HStack {
            TextField("Test", text: $text1)
            TextField("Test", text: $text2)
        }
        XCTAssertNoThrow(try view.inspect().textField(0))
        XCTAssertNoThrow(try view.inspect().textField(1))
    }
    
    func testCallOnEditingChanged() throws {
        let exp = XCTestExpectation(description: "Callback")
        let view = TextField("", text: $text1, onEditingChanged: { _ in
            exp.fulfill()
        }, onCommit: { })
        try view.inspect().callOnEditingChanged()
        wait(for: [exp], timeout: 0.5)
    }
    
    func testCallOnCommit() throws {
        let exp = XCTestExpectation(description: "Callback")
        let view = TextField("", text: $text1, onEditingChanged: { _ in }, onCommit: {
            exp.fulfill()
        })
        try view.inspect().callOnCommit()
        wait(for: [exp], timeout: 0.5)
    }
}
