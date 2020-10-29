import XCTest
import SwiftUI
@testable import ViewInspector

#if !os(macOS)
@available(iOS 14.0, macOS 11.0, tvOS 14.0, *)
final class LazyHGridTests: XCTestCase {
    
    func testInspect() throws {
        let view = LazyHGrid(rows: [], content: { Text("abc") })
        XCTAssertNoThrow(try view.inspect())
    }
    
    func testExtractionFromSingleViewContainer() throws {
        let view = AnyView(LazyHGrid(rows: [], content: { Text("abc") }))
        XCTAssertNoThrow(try view.inspect().anyView().lazyHGrid())
    }
    
    func testExtractionFromMultipleViewContainer() throws {
        let view = HStack {
            Text("")
            LazyHGrid(rows: [], content: { Text("abc") })
            Text("")
        }
        XCTAssertNoThrow(try view.inspect().hStack().lazyHGrid(1))
    }
    
    func testContentViewInspection() throws {
        let view = LazyHGrid(rows: [], content: {
            ForEach((0...10), id: \.self) { Text("\($0)") }
        })
        let sut = try view.inspect().lazyHGrid().contentView().forEach()
        XCTAssertEqual(try sut.text(3).string(), "3")
    }
    
    func testAlignmentInspection() throws {
        let view = LazyHGrid(rows: [], alignment: .top) { Text("") }
        let sut = try view.inspect().lazyHGrid().alignment()
        XCTAssertEqual(sut, .top)
    }
    
    func testSpacingInspection() throws {
        let view = LazyHGrid(rows: [], spacing: 5) { Text("") }
        let sut = try view.inspect().lazyHGrid().spacing()
        XCTAssertEqual(sut, 5)
    }
    
    func testPinnedViewsInspection() throws {
        let view = LazyHGrid(rows: [], pinnedViews: .sectionFooters) { Text("") }
        let sut = try view.inspect().lazyHGrid().pinnedViews()
        XCTAssertEqual(sut, .sectionFooters)
    }
    
    func testRowsInspection() throws {
        let view = LazyHGrid(rows: [GridItem(.fixed(10))]) { Text("") }
        let sut = try view.inspect().lazyHGrid().rows()
        XCTAssertEqual(sut, [GridItem(.fixed(10))])
    }
}

@available(iOS 14.0, macOS 11.0, tvOS 14.0, *)
final class GridItemTests: XCTestCase {
    func testEquatable() throws {
        let items = [
            GridItem(.fixed(5), spacing: 40, alignment: .bottomLeading),
            GridItem(.adaptive(minimum: 10, maximum: 20)),
            GridItem(.flexible(minimum: 10, maximum: 20))
        ]
        XCTAssertEqual(items[0], items[0])
        XCTAssertEqual(items[1], items[1])
        XCTAssertEqual(items[2], items[2])
        XCTAssertNotEqual(items[1], items[2])
    }
}
#endif
