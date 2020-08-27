import XCTest
import SwiftUI
@testable import ViewInspector

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
final class ForEachTests: XCTestCase {
    
    func testSingleEnclosedView() throws {
        let data = [TestStruct(id: "0")]
        let view = ForEach(data) { Text($0.id) }
        let value = try view.inspect().forEach().text(0).string()
        XCTAssertEqual(value, "0")
    }
    
    func testSingleEnclosedViewIndexOutOfBounds() throws {
        let data = [TestStruct(id: "0")]
        let view = ForEach(data) { Text($0.id) }
        XCTAssertThrows(
            try view.inspect().forEach().text(1),
            "Enclosed view index '1' is out of bounds: '0 ..< 1'")
    }
    
    func testMultipleIdentifiableEnclosedViews() throws {
        let data = ["0", "1", "2"].map { TestStruct(id: $0) }
        let view = ForEach(data) { Text($0.id) }
        let value1 = try view.inspect().forEach().text(0).string()
        let value2 = try view.inspect().forEach().text(1).string()
        let value3 = try view.inspect().forEach().text(2).string()
        XCTAssertEqual(value1, "0")
        XCTAssertEqual(value2, "1")
        XCTAssertEqual(value3, "2")
    }
    
    func testMultipleNonIdentifiableEnclosedViews() throws {
        let data = ["0", "1", "2"].map { NonIdentifiable(id: $0) }
        let view = ForEach(data, id: \.id) { Text($0.id) }
        let value1 = try view.inspect().forEach().text(0).string()
        let value2 = try view.inspect().forEach().text(1).string()
        let value3 = try view.inspect().forEach().text(2).string()
        XCTAssertEqual(value1, "0")
        XCTAssertEqual(value2, "1")
        XCTAssertEqual(value3, "2")
    }
    
    func testMultipleEnclosedViewsIndexOutOfBounds() throws {
        let data = ["0", "1"].map { TestStruct(id: $0) }
        let view = ForEach(data) { Text($0.id) }
        XCTAssertThrows(
            try view.inspect().forEach().text(2),
            "Enclosed view index '2' is out of bounds: '0 ..< 2'")
    }
    
    func testResetsModifiers() throws {
        let view = ForEach(Array(0 ... 10), id: \.self) { Text("\($0)") }
            .padding()
        let sut = try view.inspect().forEach().text(5)
        XCTAssertEqual(sut.content.modifiers.count, 0)
    }
    
    func testExtractionFromSingleViewContainer() throws {
        let data = ["0", "1"].map { TestStruct(id: $0) }
        let view = AnyView(ForEach(data) { Text($0.id) })
        XCTAssertNoThrow(try view.inspect().anyView().forEach())
    }
    
    func testExtractionFromMultipleViewContainer() throws {
        let data = ["0", "1"].map { TestStruct(id: $0) }
        let forEach = ForEach(data) { Text($0.id) }
        let view = Group { forEach; forEach }
        XCTAssertNoThrow(try view.inspect().group().forEach(0).text(1))
        XCTAssertNoThrow(try view.inspect().group().forEach(1).text(0))
    }

    func testRangeBased() throws {
        let range = 0..<5
        let view = ForEach(range) { Text(verbatim: "\($0)") }

        let sut = try view.inspect().forEach()
        XCTAssertEqual(sut.count, 5)
        XCTAssertEqual(try sut.text(4).string(), "\(range.upperBound - 1)")
        XCTAssertThrows(
            try sut.text(range.upperBound),
            "Enclosed view index '5' is out of bounds: '0 ..< 5'")
    }
    
    func testForEachIteration() throws {
        let view = ForEach([0, 1, 3], id: \.self) { id in
            Text("\(id)")
        }
        let sut = try view.inspect().forEach()
        var counter = 0
        try sut.forEach { view in
            XCTAssertNoThrow(try view.text())
            counter += 1
        }
        XCTAssertEqual(counter, 3)
    }
}

private struct TestStruct: Identifiable {
    var id: String
}

private struct NonIdentifiable {
    var id: String
}
