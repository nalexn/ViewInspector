import XCTest
import SwiftUI
@testable import ViewInspector

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
final class ZStackTests: XCTestCase {
    
    func testSingleEnclosedView() throws {
        let sampleView = Text("Test")
        let view = ZStack { sampleView }
        let sut = try view.inspect().zStack().text(0).content.view as? Text
        XCTAssertEqual(sut, sampleView)
    }
    
    func testResetsModifiers() throws {
        let view = ZStack { Text("Test") }.padding()
        let sut = try view.inspect().zStack().text(0)
        XCTAssertEqual(sut.content.modifiers.count, 0)
    }
    
    func testSingleEnclosedViewIndexOutOfBounds() throws {
        let sampleView = Text("Test")
        let view = ZStack { sampleView }
        XCTAssertThrows(
            try view.inspect().zStack().text(1),
            "Enclosed view index '1' is out of bounds: '0 ..< 1'")
    }
    
    func testMultipleEnclosedViews() throws {
        let sampleView1 = Text("Test")
        let sampleView2 = Text("Abc")
        let sampleView3 = Text("XYZ")
        let view = ZStack { sampleView1; sampleView2; sampleView3 }
        let view1 = try view.inspect().zStack().text(0).content.view as? Text
        let view2 = try view.inspect().zStack().text(1).content.view as? Text
        let view3 = try view.inspect().zStack().text(2).content.view as? Text
        XCTAssertEqual(view1, sampleView1)
        XCTAssertEqual(view2, sampleView2)
        XCTAssertEqual(view3, sampleView3)
    }
    
    func testSearch() throws {
        let view = AnyView(ZStack { EmptyView() })
        XCTAssertEqual(try view.inspect().find(ViewType.ZStack.self).pathToRoot,
                       "anyView().zStack()")
        XCTAssertEqual(try view.inspect().find(ViewType.EmptyView.self).pathToRoot,
                       "anyView().zStack().emptyView(0)")
    }
    
    func testMultipleEnclosedViewsIndexOutOfBounds() throws {
        let sampleView1 = Text("Test")
        let sampleView2 = Text("Abc")
        let view = ZStack { sampleView1; sampleView2 }
        XCTAssertThrows(
            try view.inspect().zStack().text(2),
            "Enclosed view index '2' is out of bounds: '0 ..< 2'")
    }
    
    func testExtractionFromSingleViewContainer() throws {
        let view = AnyView(ZStack { Text("Test") })
        XCTAssertNoThrow(try view.inspect().anyView().zStack())
    }
    
    func testExtractionFromMultipleViewContainer() throws {
        let view = ZStack {
            ZStack { Text("Test") }
            ZStack { Text("Test") }
        }
        XCTAssertNoThrow(try view.inspect().zStack().zStack(0))
        XCTAssertNoThrow(try view.inspect().zStack().zStack(1))
    }
}
