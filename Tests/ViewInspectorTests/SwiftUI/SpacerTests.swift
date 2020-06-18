import XCTest
import SwiftUI
@testable import ViewInspector

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
final class SpacerTests: XCTestCase {
    
    func testExtractionFromSingleViewContainer() throws {
        let view = AnyView(Spacer())
        XCTAssertNoThrow(try view.inspect().anyView().spacer())
    }
    
    func testExtractionFromMultipleViewContainer() throws {
        let view = HStack {
            Text("")
            Spacer()
            Text("")
            Spacer()
        }
        XCTAssertNoThrow(try view.inspect().hStack().spacer(1))
        XCTAssertNoThrow(try view.inspect().hStack().spacer(3))
    }
    
    func testMinLength() throws {
        let sut1 = try Spacer().inspect().spacer().minLength()
        let sut2 = try Spacer(minLength: 30).inspect().spacer().minLength()
        XCTAssertNil(sut1)
        XCTAssertEqual(sut2, 30)
    }
}
