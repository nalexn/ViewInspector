import XCTest
import SwiftUI
@testable import ViewInspector

final class ZStackTests: XCTestCase {
    
    func testSingleEnclosedView() throws {
        let sampleView = Text("Test")
        let view = ZStack { sampleView }
        let sut = try view.inspect().text(0).view as? Text
        XCTAssertEqual(sut, sampleView)
    }
    
    func testSingleEnclosedViewIndexOutOfBounds() throws {
        let sampleView = Text("Test")
        let view = ZStack { sampleView }
        XCTAssertThrowsError(try view.inspect().text(1))
    }
    
    func testMultipleEnclosedViews() throws {
        let sampleView1 = Text("Test")
        let sampleView2 = Text("Abc")
        let sampleView3 = Text("XYZ")
        let view = ZStack { sampleView1; sampleView2; sampleView3 }
        let view1 = try view.inspect().text(0).view as? Text
        let view2 = try view.inspect().text(1).view as? Text
        let view3 = try view.inspect().text(2).view as? Text
        XCTAssertEqual(view1, sampleView1)
        XCTAssertEqual(view2, sampleView2)
        XCTAssertEqual(view3, sampleView3)
    }
    
    func testMultipleEnclosedViewsIndexOutOfBounds() throws {
        let sampleView1 = Text("Test")
        let sampleView2 = Text("Abc")
        let view = ZStack { sampleView1; sampleView2 }
        XCTAssertThrowsError(try view.inspect().text(2))
    }
    
    func testExtractionFromSingleViewContainer() throws {
        let view = AnyView(ZStack { Text("Test") })
        XCTAssertNoThrow(try view.inspect().zStack())
    }
    
    func testExtractionFromMultipleViewContainer() throws {
        let view = ZStack {
            ZStack { Text("Test") }
            ZStack { Text("Test") }
        }
        XCTAssertNoThrow(try view.inspect().zStack(0))
        XCTAssertNoThrow(try view.inspect().zStack(1))
    }
}
