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
    
    static var allTests = [
        ("testEnclosedView", testEnclosedView),
    ]
}
