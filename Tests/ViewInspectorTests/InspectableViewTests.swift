import XCTest
import SwiftUI
@testable import ViewInspector

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
final class InspectableViewTestsAccessTests: XCTestCase {
    
    func testSequence() throws {
        let view = HStack { Text("Test") }
        var sut = try view.inspect().hStack().makeIterator()
        XCTAssertNotNil(sut.next())
        XCTAssertNil(sut.next())
    }
    
    func testRandomAccessCollection() throws {
        let view = HStack {
            Text("1").padding(); Text("2"); Text("3")
        }
        let sut = try view.inspect().hStack()
        let array = try sut.map { try $0.text().string() }
        XCTAssertEqual(array, ["1", "2", "3"])
        var iterator = sut.makeIterator()
        for _ in 0 ..< 3 {
            XCTAssertNotNil(iterator.next())
        }
        XCTAssertNil(iterator.next())
        XCTAssertEqual(sut.underestimatedCount, 3)
    }
}
