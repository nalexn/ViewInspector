import XCTest
import SwiftUI
@testable import ViewInspector

#if !os(macOS) && !targetEnvironment(macCatalyst)
@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
final class LazyVStackTests: XCTestCase {
    
    func testInspect() throws {
        guard #available(iOS 14, macOS 11.0, tvOS 14.0, *) else { return }
        let view = LazyVStack(content: { Text("abc") })
        XCTAssertNoThrow(try view.inspect())
    }
    
    func testExtractionFromSingleViewContainer() throws {
        guard #available(iOS 14, macOS 11.0, tvOS 14.0, *) else { return }
        let view = AnyView(LazyVStack(content: { Text("abc") }))
        XCTAssertNoThrow(try view.inspect().anyView().lazyVStack())
    }
    
    func testExtractionFromMultipleViewContainer() throws {
        guard #available(iOS 14, macOS 11.0, tvOS 14.0, *) else { return }
        let view = HStack {
            Text("")
            LazyVStack(content: { Text("abc") })
            Text("")
        }
        XCTAssertNoThrow(try view.inspect().hStack().lazyVStack(1))
    }
    
    func testContentViewInspection() throws {
        guard #available(iOS 14, macOS 11.0, tvOS 14.0, *) else { return }
        let view = LazyVStack(content: {
            ForEach((0...10), id: \.self) { Text("\($0)") }
        })
        let sut = try view.inspect().lazyVStack().forEach(0)
        XCTAssertEqual(try sut.text(3).string(), "3")
    }
    
    func testAlignmentInspection() throws {
        guard #available(iOS 14, macOS 11.0, tvOS 14.0, *) else { return }
        let view = LazyVStack(alignment: .leading) { Text("") }
        let sut = try view.inspect().lazyVStack().alignment()
        XCTAssertEqual(sut, .leading)
    }
    
    func testSpacingInspection() throws {
        guard #available(iOS 14, macOS 11.0, tvOS 14.0, *) else { return }
        let view = LazyVStack(spacing: 5) { Text("") }
        let sut = try view.inspect().lazyVStack().spacing()
        XCTAssertEqual(sut, 5)
    }
    
    func testPinnedViewsInspection() throws {
        guard #available(iOS 14, macOS 11.0, tvOS 14.0, *) else { return }
        let view = LazyVStack(pinnedViews: .sectionFooters) { Text("") }
        let sut = try view.inspect().lazyVStack().pinnedViews()
        XCTAssertEqual(sut, .sectionFooters)
    }
}
#endif
