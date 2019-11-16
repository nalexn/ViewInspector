import XCTest
import SwiftUI
@testable import ViewInspector

final class HStackTests: XCTestCase {
    
    func testSingleEnclosedView() throws {
        let sampleView = Text("Test")
        let view = HStack { sampleView }
        let sut = try view.inspect().text(index: 0).view as? Text
        XCTAssertEqual(sut, sampleView)
    }
    
    func testSingleEnclosedViewIndexOutOfBounds() throws {
        let sampleView = Text("Test")
        let view = HStack { sampleView }
        XCTAssertThrowsError(try view.inspect().text(index: 1))
    }
    
    func testMultipleEnclosedViews() throws {
        let sampleView1 = Text("Test")
        let sampleView2 = Text("Abc")
        let sampleView3 = Text("XYZ")
        let view = HStack { sampleView1; sampleView2; sampleView3 }
        let view1 = try view.inspect().text(index: 0).view as? Text
        let view2 = try view.inspect().text(index: 1).view as? Text
        let view3 = try view.inspect().text(index: 2).view as? Text
        XCTAssertEqual(view1, sampleView1)
        XCTAssertEqual(view2, sampleView2)
        XCTAssertEqual(view3, sampleView3)
    }
    
    func testMultipleEnclosedViewsIndexOutOfBounds() throws {
        let sampleView1 = Text("Test")
        let sampleView2 = Text("Abc")
        let view = HStack { sampleView1; sampleView2 }
        XCTAssertThrowsError(try view.inspect().text(index: 2))
    }
}
