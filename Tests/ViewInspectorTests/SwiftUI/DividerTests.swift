import XCTest
import SwiftUI
@testable import ViewInspector

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
final class DividerTests: XCTestCase {
    
    func testInspect() throws {
        XCTAssertNoThrow(try Divider().inspect())
    }
    
    func testExtractionFromSingleViewContainer() throws {
        let view = AnyView(Divider())
        XCTAssertNoThrow(try view.inspect().anyView().divider())
    }
    
    func testExtractionFromMultipleViewContainer() throws {
        let view = HStack {
            Text("")
            Divider()
            Text("")
            Divider()
        }
        XCTAssertNoThrow(try view.inspect().hStack().divider(1))
        XCTAssertNoThrow(try view.inspect().hStack().divider(3))
    }
}
