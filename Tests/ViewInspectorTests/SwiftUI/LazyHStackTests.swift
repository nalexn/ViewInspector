import XCTest
import SwiftUI
@testable import ViewInspector

#if !os(macOS)
@available(iOS 14.0, macOS 11.0, tvOS 14.0, *)
final class LazyHStackTests: XCTestCase {
    
    func testInspect() throws {
        let view = LazyHStack(content: { Text("abc") })
        XCTAssertNoThrow(try view.inspect())
    }
    
    func testExtractionFromSingleViewContainer() throws {
        let view = AnyView(LazyHStack(content: { Text("abc") }))
        XCTAssertNoThrow(try view.inspect().anyView().lazyHStack())
    }
    
    func testExtractionFromMultipleViewContainer() throws {
        let view = HStack {
            Text("")
            LazyHStack(content: { Text("abc") })
            Text("")
        }
        XCTAssertNoThrow(try view.inspect().hStack().lazyHStack(1))
    }
    
    func testContentViewInspection() throws {
        let view = LazyHStack(content: {
            ForEach((0...10), id: \.self) { Text("\($0)") }
        })
        let sut = try view.inspect().lazyHStack().forEach(0)
        XCTAssertEqual(try sut.text(3).string(), "3")
    }
    
    func testAlignmentInspection() throws {
        let view = LazyHStack(alignment: .top) { Text("") }
        let sut = try view.inspect().lazyHStack().alignment()
        XCTAssertEqual(sut, .top)
    }
    
    func testSpacingInspection() throws {
        let view = LazyHStack(spacing: 5) { Text("") }
        let sut = try view.inspect().lazyHStack().spacing()
        XCTAssertEqual(sut, 5)
    }
    
    func testPinnedViewsInspection() throws {
        let view = LazyHStack(pinnedViews: .sectionFooters) { Text("") }
        let sut = try view.inspect().lazyHStack().pinnedViews()
        XCTAssertEqual(sut, .sectionFooters)
    }
}
#endif
