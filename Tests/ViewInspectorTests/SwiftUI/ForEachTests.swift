import XCTest
import SwiftUI
@testable import ViewInspector

final class ForEachTests: XCTestCase {
    
    func testSingleEnclosedView() throws {
        let data = [TestStruct(id: "0")]
        let view = ForEach(data) { Text($0.id) }
        let value = try view.inspect().text(0).string()
        XCTAssertEqual(value, "0")
    }
    
    func testSingleEnclosedViewIndexOutOfBounds() throws {
        let data = [TestStruct(id: "0")]
        let view = ForEach(data) { Text($0.id) }
        XCTAssertThrowsError(try view.inspect().text(1))
    }
    
    func testMultipleEnclosedViews() throws {
        let data = ["0", "1", "2"].map { TestStruct(id: $0) }
        let view = ForEach(data) { Text($0.id) }
        let value1 = try view.inspect().text(0).string()
        let value2 = try view.inspect().text(1).string()
        let value3 = try view.inspect().text(2).string()
        XCTAssertEqual(value1, "0")
        XCTAssertEqual(value2, "1")
        XCTAssertEqual(value3, "2")
    }
    
    func testMultipleEnclosedViewsIndexOutOfBounds() throws {
        let data = ["0", "1"].map { TestStruct(id: $0) }
        let view = ForEach(data) { Text($0.id) }
        XCTAssertThrowsError(try view.inspect().text(2))
    }
    
    func testExtractionFromSingleViewContainer() throws {
        let data = ["0", "1"].map { TestStruct(id: $0) }
        let view = AnyView(ForEach(data) { Text($0.id) })
        XCTAssertNoThrow(try view.inspect().forEach([TestStruct].self, Text.self))
    }
    
    func testExtractionFromMultipleViewContainer() throws {
        let data = ["0", "1"].map { TestStruct(id: $0) }
        let forEach = ForEach(data) { Text($0.id) }
        let view = Group { forEach; forEach }
        XCTAssertNoThrow(try view.inspect().forEach([TestStruct].self, Text.self, 0))
        XCTAssertNoThrow(try view.inspect().forEach([TestStruct].self, Text.self, 1))
    }
    
    static var allTests = [
        ("testSingleEnclosedView", testSingleEnclosedView),
        ("testSingleEnclosedViewIndexOutOfBounds", testSingleEnclosedViewIndexOutOfBounds),
        ("testMultipleEnclosedViews", testMultipleEnclosedViews),
        ("testMultipleEnclosedViewsIndexOutOfBounds", testMultipleEnclosedViewsIndexOutOfBounds),
        ("testExtractionFromSingleViewContainer", testExtractionFromSingleViewContainer),
        ("testExtractionFromMultipleViewContainer", testExtractionFromMultipleViewContainer),
    ]
}

struct TestStruct: Identifiable {
    var id: String
}
