import XCTest
import SwiftUI
@testable import ViewInspector

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
final class LazyVStackTests: XCTestCase {
    
    func testInspect() throws {
        guard #available(iOS 14, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
        else { throw XCTSkip() }
        let view = LazyVStack(content: { Text("abc") })
        XCTAssertNoThrow(try view.inspect())
    }
    
    func testExtractionFromSingleViewContainer() throws {
        guard #available(iOS 14, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
        else { throw XCTSkip() }
        let view = AnyView(LazyVStack(content: { Text("abc") }))
        XCTAssertNoThrow(try view.inspect().anyView().lazyVStack())
    }
    
    func testExtractionFromMultipleViewContainer() throws {
        guard #available(iOS 14, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
        else { throw XCTSkip() }
        let view = HStack {
            Text("")
            LazyVStack(content: { Text("abc") })
            Text("")
        }
        XCTAssertNoThrow(try view.inspect().hStack().lazyVStack(1))
    }
    
    func testSearch() throws {
        guard #available(iOS 14, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
        else { throw XCTSkip() }
        let view = HStack { LazyVStack(content: { Text("abc") }) }
        XCTAssertEqual(try view.inspect().find(ViewType.LazyVStack.self).pathToRoot,
                       "hStack().lazyVStack(0)")
        XCTAssertEqual(try view.inspect().find(text: "abc").pathToRoot,
                       "hStack().lazyVStack(0).text(0)")
    }
    
    func testContentViewInspection() throws {
        guard #available(iOS 14, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
        else { throw XCTSkip() }
        let view = LazyVStack(content: {
            ForEach((0...10), id: \.self) { Text("\($0)") }
        })
        let sut = try view.inspect().lazyVStack().forEach(0)
        XCTAssertEqual(try sut.text(3).string(), "3")
    }
    
    func testAlignmentInspection() throws {
        guard #available(iOS 14, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
        else { throw XCTSkip() }
        let view = LazyVStack(alignment: .leading) { Text("") }
        let sut = try view.inspect().lazyVStack().alignment()
        XCTAssertEqual(sut, .leading)
    }
    
    func testSpacingInspection() throws {
        guard #available(iOS 14, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
        else { throw XCTSkip() }
        let view = LazyVStack(spacing: 5) { Text("") }
        let sut = try view.inspect().lazyVStack().spacing()
        XCTAssertEqual(sut, 5)
    }
    
    func testPinnedViewsInspection() throws {
        guard #available(iOS 14, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
        else { throw XCTSkip() }
        let view = LazyVStack(pinnedViews: .sectionFooters) { Text("") }
        let sut = try view.inspect().lazyVStack().pinnedViews()
        XCTAssertEqual(sut, .sectionFooters)
    }
}
