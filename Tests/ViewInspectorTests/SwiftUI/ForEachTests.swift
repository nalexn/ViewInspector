import XCTest
import SwiftUI
import UniformTypeIdentifiers.UTType
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
    
    func testSearch() throws {
        let data = ["0", "1", "2"].map { TestStruct(id: $0) }
        let view = AnyView(ForEach(data) { Text($0.id) })
        XCTAssertEqual(try view.inspect().find(ViewType.ForEach.self).pathToRoot,
                       "anyView().forEach()")
        XCTAssertEqual(try view.inspect().find(text: "2").pathToRoot,
                       "anyView().forEach().text(2)")
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
        XCTAssertEqual(sut.content.medium.viewModifiers.count, 0)
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
    
    func testOnDelete() throws {
        let exp = XCTestExpectation(description: #function)
        let set = IndexSet(0...1)
        let sut = ForEach([0, 1, 3], id: \.self) { id in Text("\(id)") }
            .onDelete { value in
                XCTAssertEqual(value, set)
                exp.fulfill()
            }
        try sut.inspect().forEach().callOnDelete(set)
        wait(for: [exp], timeout: 0.1)
    }
    
    func testOnMove() throws {
        let exp = XCTestExpectation(description: #function)
        let set = IndexSet(0...1)
        let index = 2
        let sut = ForEach([0, 1, 3], id: \.self) { id in Text("\(id)") }
            .onMove { value1, value2 in
                XCTAssertEqual(value1, set)
                XCTAssertEqual(value2, index)
                exp.fulfill()
            }
        try sut.inspect().forEach().callOnMove(set, index)
        wait(for: [exp], timeout: 0.1)
    }
    
    #if os(macOS)
    func testOnInsert() throws {
        guard #available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
        else { return }
        let exp = XCTestExpectation(description: #function)
        let sut = ForEach([0, 1, 3], id: \.self) { id in Text("\(id)") }
            .onInsert(of: [UTType.pdf]) { (index, providers) in
                exp.fulfill()
            }
        XCTAssertThrows(try sut.inspect().forEach().callOnInsert(of: [UTType.jpeg], 0, []),
        "ForEach<Array<Int>, Int, Text> does not have 'onInsert(of: [\"public.jpeg\"], perform:)' modifier")
        try sut.inspect().forEach().callOnInsert(of: [UTType.pdf], 0, [])
        wait(for: [exp], timeout: 0.1)
    }
    #endif
}

private struct TestStruct: Identifiable {
    var id: String
}

private struct NonIdentifiable {
    var id: String
}
