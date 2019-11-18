import XCTest
import SwiftUI
@testable import ViewInspector

final class DividerTests: XCTestCase {
    
    func testInspect() throws {
        XCTAssertNoThrow(try Divider().inspect())
    }
    
    func testExtractionFromSingleViewContainer() throws {
        let view = AnyView(Divider())
        XCTAssertNoThrow(try view.inspect().divider())
    }
    
    func testExtractionFromMultipleViewContainer() throws {
        let view = HStack {
            Text("")
            Divider()
            Text("")
            Divider()
        }
        XCTAssertNoThrow(try view.inspect().divider(1))
        XCTAssertNoThrow(try view.inspect().divider(3))
    }
    
    static var allTests = [
        ("testInspect", testInspect),
        ("testExtractionFromSingleViewContainer", testExtractionFromSingleViewContainer),
        ("testExtractionFromMultipleViewContainer", testExtractionFromMultipleViewContainer),
    ]
}
