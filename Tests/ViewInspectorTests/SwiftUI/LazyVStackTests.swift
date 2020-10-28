import XCTest
import SwiftUI
@testable import ViewInspector

@available(iOS 14.0, macOS 11.0, tvOS 14.0, *)
final class LazyVStackTests: XCTestCase {
    
    func testInspect() throws {
        let view = LazyVStack(content: { Text("abc") })
        XCTAssertNoThrow(try view.inspect())
    }
    
    func testExtractionFromSingleViewContainer() throws {
        let view = AnyView(LazyVStack(content: { Text("abc") }))
        XCTAssertNoThrow(try view.inspect().anyView().lazyVStack())
    }
    
    func testExtractionFromMultipleViewContainer() throws {
        let view = HStack {
            Text("")
            LazyVStack(content: { Text("abc") })
            Text("")
        }
        XCTAssertNoThrow(try view.inspect().hStack().lazyVStack(1))
    }
    
    func testContentViewInspection() throws {
        let view = LazyVStack(content: {
            ForEach((0...10), id: \.self) { Text("\($0)") }
        })
        let sut = try view.inspect().lazyVStack().contentView().forEach()
        XCTAssertEqual(try sut.text(3).string(), "3")
    }
    
    func testAlignmentInspection() throws {
        let view = LazyVStack(alignment: .leading) { Text("") }
        let sut = try view.inspect().lazyVStack().alignment()
        XCTAssertEqual(sut, .leading)
    }
    
    func testSpacingInspection() throws {
        let view = LazyVStack(spacing: 5) { Text("") }
        let sut = try view.inspect().lazyVStack().spacing()
        XCTAssertEqual(sut, 5)
    }
    
    func testPinnedViewsInspection() throws {
        let view = LazyVStack(pinnedViews: .sectionFooters) { Text("") }
        let sut = try view.inspect().lazyVStack().pinnedViews()
        XCTAssertEqual(sut, .sectionFooters)
    }
}
