import XCTest
import SwiftUI
@testable import ViewInspector

final class AnyViewTests: XCTestCase {
    
    func testEnclosedView() throws {
        let sampleView = Text("Test")
        let view = AnyView(sampleView)
        let sut = try view.inspect().text().view as? Text
        XCTAssertEqual(sut, sampleView)
    }
    
    func testExtractionFromSingleViewContainer() throws {
        let view = Button(action: { }, label: { AnyView(Text("")) })
        XCTAssertNoThrow(try view.inspect().anyView())
    }
    
    func testExtractionFromMultipleViewContainer() throws {
        let view = HStack {
            AnyView(Text(""))
            AnyView(Text(""))
        }
        XCTAssertNoThrow(try view.inspect().anyView(0))
        XCTAssertNoThrow(try view.inspect().anyView(1))
    }
    
    static var allTests = [
        ("testEnclosedView", testEnclosedView),
        ("testExtractionFromSingleViewContainer", testExtractionFromSingleViewContainer),
        ("testExtractionFromMultipleViewContainer", testExtractionFromMultipleViewContainer),
    ]
}
