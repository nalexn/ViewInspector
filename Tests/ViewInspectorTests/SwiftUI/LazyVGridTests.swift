import XCTest
import SwiftUI
@testable import ViewInspector

@available(iOS 14.0, macOS 11.0, tvOS 14.0, *)
final class LazyVGridTests: XCTestCase {
    
    func testInspect() throws {
        let view = LazyVGrid(columns: [], content: { Text("abc") })
        XCTAssertNoThrow(try view.inspect())
    }
    
    func testExtractionFromSingleViewContainer() throws {
        let view = AnyView(LazyVGrid(columns: [], content: { Text("abc") }))
        XCTAssertNoThrow(try view.inspect().anyView().lazyVGrid())
    }
    
    func testExtractionFromMultipleViewContainer() throws {
        let view = HStack {
            Text("")
            LazyVGrid(columns: [], content: { Text("abc") })
            Text("")
        }
        XCTAssertNoThrow(try view.inspect().hStack().lazyVGrid(1))
    }
    
    func testContentViewInspection() throws {
        let view = LazyVGrid(columns: [], content: {
            ForEach((0...10), id: \.self) { Text("\($0)") }
        })
        let sut = try view.inspect().lazyVGrid().contentView().forEach()
        XCTAssertEqual(try sut.text(3).string(), "3")
    }
    
    func testAlignmentInspection() throws {
        let view = LazyVGrid(columns: [], alignment: .leading) { Text("") }
        let sut = try view.inspect().lazyVGrid().alignment()
        XCTAssertEqual(sut, .leading)
    }
    
    func testSpacingInspection() throws {
        let view = LazyVGrid(columns: [], spacing: 5) { Text("") }
        let sut = try view.inspect().lazyVGrid().spacing()
        XCTAssertEqual(sut, 5)
    }
    
    func testPinnedViewsInspection() throws {
        let view = LazyVGrid(columns: [], pinnedViews: .sectionFooters) { Text("") }
        let sut = try view.inspect().lazyVGrid().pinnedViews()
        XCTAssertEqual(sut, .sectionFooters)
    }
    
    func testColumnsInspection() throws {
        let view = LazyVGrid(columns: [GridItem(.fixed(10))]) { Text("") }
        let sut = try view.inspect().lazyVGrid().columns()
        XCTAssertEqual(sut, [GridItem(.fixed(10))])
    }
}
