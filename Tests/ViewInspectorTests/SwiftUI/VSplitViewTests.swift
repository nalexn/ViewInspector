import XCTest
import SwiftUI
@testable import ViewInspector

#if os(macOS)

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
final class VSplitViewTests: XCTestCase {
    
    func testSingleEnclosedView() throws {
        let sampleView = Text("Test")
        let view = VSplitView { sampleView }
        let sut = try view.inspect().vSplitView().text(0).content.view as? Text
        XCTAssertEqual(sut, sampleView)
    }
    
    func testResetsModifiers() throws {
        let view = VSplitView { Text("Test") }.padding()
        let sut = try view.inspect().vSplitView().text(0)
        XCTAssertEqual(sut.content.modifiers.count, 0)
    }
    
    func testSingleEnclosedViewIndexOutOfBounds() throws {
        let sampleView = Text("Test")
        let view = VSplitView { sampleView }
        XCTAssertThrows(
            try view.inspect().vSplitView().text(1),
            "Enclosed view index '1' is out of bounds: '0 ..< 1'")
    }
    
    func testMultipleEnclosedViews() throws {
        let sampleView1 = Text("Test")
        let sampleView2 = Text("Abc")
        let sampleView3 = Text("XYZ")
        let view = VSplitView { sampleView1; sampleView2; sampleView3 }
        let view1 = try view.inspect().vSplitView().text(0).content.view as? Text
        let view2 = try view.inspect().vSplitView().text(1).content.view as? Text
        let view3 = try view.inspect().vSplitView().text(2).content.view as? Text
        XCTAssertEqual(view1, sampleView1)
        XCTAssertEqual(view2, sampleView2)
        XCTAssertEqual(view3, sampleView3)
    }
    
    func testSearch() throws {
        let view = AnyView(VSplitView { Text("abc") })
        XCTAssertEqual(try view.inspect().find(ViewType.VSplitView.self).pathToRoot,
                       "anyView().vSplitView()")
        XCTAssertEqual(try view.inspect().find(text: "abc").pathToRoot,
                       "anyView().vSplitView().text(0)")
    }
    
    func testMultipleEnclosedViewsIndexOutOfBounds() throws {
        let sampleView1 = Text("Test")
        let sampleView2 = Text("Abc")
        let view = VSplitView { sampleView1; sampleView2 }
        XCTAssertThrows(
            try view.inspect().vSplitView().text(2),
            "Enclosed view index '2' is out of bounds: '0 ..< 2'")
    }
    
    func testExtractionFromSingleViewContainer() throws {
        let view = AnyView(VSplitView { Text("Test") })
        XCTAssertNoThrow(try view.inspect().anyView().vSplitView())
    }
    
    func testExtractionFromMultipleViewContainer() throws {
        let view = VSplitView {
            VSplitView { Text("Test") }
            VSplitView { Text("Test") }
        }
        XCTAssertNoThrow(try view.inspect().vSplitView().vSplitView(0))
        XCTAssertNoThrow(try view.inspect().vSplitView().vSplitView(1))
    }
}

#endif
