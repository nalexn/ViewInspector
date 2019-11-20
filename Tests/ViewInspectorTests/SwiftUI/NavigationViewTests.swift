import XCTest
import SwiftUI
@testable import ViewInspector

#if !os(watchOS)

final class NavigationViewTests: XCTestCase {
    
    func testSingleEnclosedView() throws {
        let sampleView = Text("Test")
        let view = NavigationView { sampleView }
        let sut = try view.inspect().text(0).view as? Text
        XCTAssertEqual(sut, sampleView)
    }
    
    func testMultipleEnclosedViews() throws {
        let sampleView1 = Text("Test")
        let sampleView2 = Text("Abc")
        let sampleView3 = Text("XYZ")
        let view = Group { sampleView1; sampleView2; sampleView3 }
        let view1 = try view.inspect().text(0).view as? Text
        let view2 = try view.inspect().text(1).view as? Text
        let view3 = try view.inspect().text(2).view as? Text
        XCTAssertEqual(view1, sampleView1)
        XCTAssertEqual(view2, sampleView2)
        XCTAssertEqual(view3, sampleView3)
    }
    
    func testExtractionFromSingleViewContainer() throws {
        let view = AnyView(NavigationView { Text("") })
        XCTAssertNoThrow(try view.inspect().navigationView())
    }
    
    func testExtractionFromMultipleViewContainer() throws {
        let view = HStack {
            NavigationView { Text("") }
            NavigationView { Text("") }
        }
        XCTAssertNoThrow(try view.inspect().navigationView(0))
        XCTAssertNoThrow(try view.inspect().navigationView(1))
    }
}

#endif
