import XCTest
import SwiftUI
@testable import ViewInspector

final class ListTests: XCTestCase {
    
    func testSingleEnclosedView() throws {
        let sampleView = Text("Test")
        let view = List { sampleView }
        let sut = try view.inspect().list().text(0).content.view as? Text
        XCTAssertEqual(sut, sampleView)
    }
    
    func testSingleEnclosedViewIndexOutOfBounds() throws {
        let sampleView = Text("Test")
        let view = List { sampleView }
        XCTAssertThrows(
            try view.inspect().list().text(1),
            "Enclosed view index '1' is out of bounds: '0 ..< 1'")
    }
    
    func testMultipleEnclosedViews() throws {
        let sampleView1 = Text("Test")
        let sampleView2 = Text("Abc")
        let sampleView3 = Text("XYZ")
        let view = List { sampleView1; sampleView2; sampleView3 }
        let view1 = try view.inspect().list().text(0).content.view as? Text
        let view2 = try view.inspect().list().text(1).content.view as? Text
        let view3 = try view.inspect().list().text(2).content.view as? Text
        XCTAssertEqual(view1, sampleView1)
        XCTAssertEqual(view2, sampleView2)
        XCTAssertEqual(view3, sampleView3)
    }
    
    func testMultipleEnclosedViewsIndexOutOfBounds() throws {
        let sampleView1 = Text("Test")
        let sampleView2 = Text("Abc")
        let view = List { sampleView1; sampleView2 }
        XCTAssertThrows(
            try view.inspect().list().text(2),
            "Enclosed view index '2' is out of bounds: '0 ..< 2'")
    }
    
    func testResetsModifiers() throws {
        let view = List { Text("Test") }.padding()
        let sut = try view.inspect().list().text(0)
        XCTAssertEqual(sut.content.modifiers.count, 0)
    }
    
    func testExtractionFromSingleViewContainer() throws {
        let view = AnyView(List { Text("Test") })
        XCTAssertNoThrow(try view.inspect().anyView().list())
    }
    
    func testExtractionFromMultipleViewContainer() throws {
        let view = List {
            List { Text("Test") }
            List { Text("Test") }
        }
        XCTAssertNoThrow(try view.inspect().list().list(0))
        XCTAssertNoThrow(try view.inspect().list().list(1))
    }
}

// MARK: - View Modifiers

final class GlobalModifiersForList: XCTestCase {
    
    func testListRowInsets() throws {
        let sut = EmptyView().listRowInsets(EdgeInsets())
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testListRowBackground() throws {
        let sut = EmptyView().listRowBackground(Text(""))
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    #if os(watchOS)
    func testListRowPlatterColor() throws {
        let sut = EmptyView().listRowPlatterColor(.red)
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    #endif
}
