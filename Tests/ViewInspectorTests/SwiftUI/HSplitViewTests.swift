import XCTest
import SwiftUI
@testable import ViewInspector

#if os(macOS)

@available(macOS 10.15, *)
@available(iOS, unavailable)
@available(tvOS, unavailable)
final class HSplitViewTests: XCTestCase {
    
    func testSingleEnclosedView() throws {
        let sampleView = Text("Test")
        let view = HSplitView { sampleView }
        let sut = try view.inspect().hSplitView().text(0).content.view as? Text
        XCTAssertEqual(sut, sampleView)
    }
    
    func testSingleEnclosedViewIndexOutOfBounds() throws {
        let sampleView = Text("Test")
        let view = HSplitView { sampleView }
        XCTAssertThrows(
            try view.inspect().hSplitView().text(1),
            "Enclosed view index '1' is out of bounds: '0 ..< 1'")
    }
    
    func testMultipleEnclosedViews() throws {
        let sampleView1 = Text("Test")
        let sampleView2 = Text("Abc")
        let sampleView3 = Text("XYZ")
        let view = HSplitView { sampleView1; sampleView2; sampleView3 }
        let view1 = try view.inspect().hSplitView().text(0).content.view as? Text
        let view2 = try view.inspect().hSplitView().text(1).content.view as? Text
        let view3 = try view.inspect().hSplitView().text(2).content.view as? Text
        XCTAssertEqual(view1, sampleView1)
        XCTAssertEqual(view2, sampleView2)
        XCTAssertEqual(view3, sampleView3)
    }
    
    func testSearch() throws {
        let view = AnyView(HSplitView { Text("Test") })
        XCTAssertEqual(try view.inspect().find(ViewType.HSplitView.self).pathToRoot,
                       "anyView().hSplitView()")
        XCTAssertEqual(try view.inspect().find(text: "Test").pathToRoot,
                       "anyView().hSplitView().text(0)")
    }
    
    func testMultipleEnclosedViewsIndexOutOfBounds() throws {
        let sampleView1 = Text("Test")
        let sampleView2 = Text("Abc")
        let view = HSplitView { sampleView1; sampleView2 }
        XCTAssertThrows(
            try view.inspect().hSplitView().text(2),
            "Enclosed view index '2' is out of bounds: '0 ..< 2'")
    }
    
    func testResetsModifiers() throws {
        let view = HSplitView { Text("Test") }.padding()
        let sut = try view.inspect().hSplitView().text(0)
        XCTAssertEqual(sut.content.modifiers.count, 0)
    }
    
    func testExtractionFromSingleViewContainer() throws {
        let view = AnyView(HSplitView { Text("Test") })
        XCTAssertNoThrow(try view.inspect().anyView().hSplitView())
    }
    
    func testExtractionFromMultipleViewContainer() throws {
        let view = HSplitView {
            HSplitView { Text("Test") }
            HSplitView { Text("Test") }
        }
        XCTAssertNoThrow(try view.inspect().hSplitView().hSplitView(0))
        XCTAssertNoThrow(try view.inspect().hSplitView().hSplitView(1))
    }
}

#endif
