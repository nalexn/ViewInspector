import XCTest
import SwiftUI
@testable import ViewInspector

final class SecureFieldTests: XCTestCase {
    
    @State var text1 = ""
    @State var text2 = ""
    
    override func setUp() {
        text1 = ""
        text2 = ""
    }
    
    func testEnclosedView() throws {
        let view = SecureField("Title", text: $text1)
        let text = try view.inspect().text().string()
        XCTAssertEqual(text, "Title")
    }
    
    func testResetsModifiers() throws {
        let view = SecureField("Title", text: $text1).padding()
        let sut = try view.inspect().secureField().text()
        XCTAssertEqual(sut.content.modifiers.count, 0)
    }
    
    func testExtractionFromSingleViewContainer() throws {
        let view = AnyView(SecureField("Test", text: $text1))
        XCTAssertNoThrow(try view.inspect().secureField())
    }
    
    func testExtractionFromMultipleViewContainer() throws {
        let view = HStack {
            SecureField("Test", text: $text1)
            SecureField("Test", text: $text2)
        }
        XCTAssertNoThrow(try view.inspect().secureField(0))
        XCTAssertNoThrow(try view.inspect().secureField(1))
    }
    
    func testCallOnCommit() throws {
        let exp = XCTestExpectation(description: "Callback")
        let view = SecureField("", text: $text1, onCommit: {
            exp.fulfill()
        })
        try view.inspect().callOnCommit()
        wait(for: [exp], timeout: 0.5)
    }
}
