import XCTest
import SwiftUI
@testable import ViewInspector

final class VStackTests: XCTestCase {
    
    func testSingleEnclosedView() throws {
        let sampleView = Text("Test")
        let view = VStack { sampleView }
        let sut = try view.inspect().text(0).view as? Text
        XCTAssertEqual(sut, sampleView)
    }
    
    func testSingleEnclosedViewIndexOutOfBounds() throws {
        let sampleView = Text("Test")
        let view = VStack { sampleView }
        XCTAssertThrowsError(try view.inspect().text(1))
    }
    
    func testMultipleEnclosedViews() throws {
        let sampleView1 = Text("Test")
        let sampleView2 = Text("Abc")
        let sampleView3 = Text("XYZ")
        let view = VStack { sampleView1; sampleView2; sampleView3 }
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
        let view = VStack { sampleView1; sampleView2 }
        XCTAssertThrowsError(try view.inspect().text(2))
    }
    
    func testExtractionFromSingleViewContainer() throws {
        let view = AnyView(VStack { Text("Test") })
        XCTAssertNoThrow(try view.inspect().vStack())
    }
    
    func testExtractionFromMultipleViewContainer() throws {
        let view = VStack {
            VStack { Text("Test") }
            VStack { Text("Test") }
        }
        XCTAssertNoThrow(try view.inspect().vStack(0))
        XCTAssertNoThrow(try view.inspect().vStack(1))
    }
    
    static var allTests = [
        ("testSingleEnclosedView", testSingleEnclosedView),
        ("testSingleEnclosedViewIndexOutOfBounds", testSingleEnclosedViewIndexOutOfBounds),
        ("testMultipleEnclosedViews", testMultipleEnclosedViews),
        ("testMultipleEnclosedViewsIndexOutOfBounds", testMultipleEnclosedViewsIndexOutOfBounds),
        ("testExtractionFromSingleViewContainer", testExtractionFromSingleViewContainer),
        ("testExtractionFromMultipleViewContainer", testExtractionFromMultipleViewContainer),
    ]
}
