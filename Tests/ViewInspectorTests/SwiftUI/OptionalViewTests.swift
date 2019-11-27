import XCTest
import SwiftUI
@testable import ViewInspector

final class OptionalViewTests: XCTestCase {
    
    func testOptionalViewWhenExists() throws {
        let view = TestView(flag: true)
        let string = try view.inspect().hStack().text(0).string()
        XCTAssertEqual(string, "ABC")
    }
    
    func testOptionalViewWhenIsAbsent() throws {
        let view = TestView(flag: false)
        XCTAssertThrowsError(try view.inspect().hStack().text(0))
    }
}

private struct TestView: View, Inspectable {
    
    let flag: Bool
    var body: some View {
        HStack {
            if flag { Text("ABC") }
        }
    }
}
