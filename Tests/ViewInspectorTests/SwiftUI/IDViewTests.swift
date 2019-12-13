import XCTest
import SwiftUI
@testable import ViewInspector

final class IDViewTests: XCTestCase {
    
    func testEnclosedView() throws {
        let sampleView = Text("Test")
        let view = sampleView.id(0)
        let sut = try view.inspect().text().view as? Text
        XCTAssertEqual(sut, sampleView)
    }
    
    func testExtractionFromSingleViewContainer() throws {
        let view = AnyView(Text("").id(""))
        XCTAssertNoThrow(try view.inspect().text())
    }
    
    func testExtractionFromMultipleViewContainer() throws {
        let view = HStack {
            Text("").id(5)
            Text("").id("test")
        }
        XCTAssertNoThrow(try view.inspect().text(0))
        XCTAssertNoThrow(try view.inspect().text(1))
    }
}
