import XCTest
import SwiftUI
@testable import ViewInspector

final class TextTests: XCTestCase {
    
    func testLocalizableStringNoParams() throws {
        let view = Text("Test")
        let sut = try view.inspect().string()
        XCTAssertEqual(sut, "Test")
    }

    static var allTests = [
        ("testLocalizableStringNoParams", testLocalizableStringNoParams),
    ]
}
