import XCTest
import SwiftUI
@testable import ViewInspector

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
final class LazyHGridTests: XCTestCase {
    
    func testInspect() throws {
        guard #available(iOS 14, macOS 11.0, tvOS 14.0, *) else { return }
        let view = LazyHGrid(rows: [], content: { Text("abc") })
        XCTAssertNoThrow(try view.inspect())
    }
    
    func testExtractionFromSingleViewContainer() throws {
        guard #available(iOS 14, macOS 11.0, tvOS 14.0, *) else { return }
        let view = AnyView(LazyHGrid(rows: [], content: { Text("abc") }))
        XCTAssertNoThrow(try view.inspect().anyView().lazyHGrid())
    }
    
    func testExtractionFromMultipleViewContainer() throws {
        guard #available(iOS 14, macOS 11.0, tvOS 14.0, *) else { return }
        let view = HStack {
            Text("")
            LazyHGrid(rows: [], content: { Text("abc") })
            Text("")
        }
        XCTAssertNoThrow(try view.inspect().hStack().lazyHGrid(1))
    }
    
    func testSearch() throws {
        guard #available(iOS 14, macOS 11.0, tvOS 14.0, *) else { return }
        let view = HStack { LazyHGrid(rows: [], content: { Text("abc") }) }
        XCTAssertEqual(try view.inspect().find(ViewType.LazyHGrid.self).pathToRoot,
                       "hStack().lazyHGrid(0)")
        XCTAssertEqual(try view.inspect().find(text: "abc").pathToRoot,
                       "hStack().lazyHGrid(0).text(0)")
    }
    
    func testContentViewInspection() throws {
        guard #available(iOS 14, macOS 11.0, tvOS 14.0, *) else { return }
        let view = LazyHGrid(rows: [], content: {
            ForEach((0...10), id: \.self) { Text("\($0)") }
        })
        let sut = try view.inspect().lazyHGrid().forEach(0)
        XCTAssertEqual(try sut.text(3).string(), "3")
    }
    
    func testAlignmentInspection() throws {
        guard #available(iOS 14, macOS 11.0, tvOS 14.0, *) else { return }
        let view = LazyHGrid(rows: [], alignment: .top) { Text("") }
        let sut = try view.inspect().lazyHGrid().alignment()
        XCTAssertEqual(sut, .top)
    }
    
    func testSpacingInspection() throws {
        guard #available(iOS 14, macOS 11.0, tvOS 14.0, *) else { return }
        let view = LazyHGrid(rows: [], spacing: 5) { Text("") }
        let sut = try view.inspect().lazyHGrid().spacing()
        XCTAssertEqual(sut, 5)
    }
    
    func testPinnedViewsInspection() throws {
        guard #available(iOS 14, macOS 11.0, tvOS 14.0, *) else { return }
        let view = LazyHGrid(rows: [], pinnedViews: .sectionFooters) { Text("") }
        let sut = try view.inspect().lazyHGrid().pinnedViews()
        XCTAssertEqual(sut, .sectionFooters)
    }
    
    func testRowsInspection() throws {
        guard #available(iOS 14, macOS 11.0, tvOS 14.0, *) else { return }
        let view = LazyHGrid(rows: [GridItem(.fixed(10))]) { Text("") }
        let sut = try view.inspect().lazyHGrid().rows()
        XCTAssertEqual(sut, [GridItem(.fixed(10))])
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
final class GridItemTests: XCTestCase {
    func testEquatable() throws {
        guard #available(iOS 14, macOS 11.0, tvOS 14.0, *) else { return }
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
