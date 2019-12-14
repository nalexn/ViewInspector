import XCTest
import SwiftUI
@testable import ViewInspector

final class ScrollViewTests: XCTestCase {
    
    func testEnclosedView() throws {
        let sampleView = Text("Test")
        let view = ScrollView { sampleView }
        let sut = try view.inspect().text().content.view as? Text
        XCTAssertEqual(sut, sampleView)
    }
    
    func testResetsModifiers() throws {
        let view = ScrollView { Text("Test") }.padding()
        let sut = try view.inspect().scrollView().text()
        XCTAssertEqual(sut.content.modifiers.count, 0)
    }
    
    func testExtractionFromSingleViewContainer() throws {
        let view = AnyView(ScrollView { Text("") })
        XCTAssertNoThrow(try view.inspect().scrollView())
    }
    
    func testExtractionFromMultipleViewContainer() throws {
        let view = HStack {
            ScrollView { Text("") }
            ScrollView { Text("") }
        }
        XCTAssertNoThrow(try view.inspect().scrollView(0))
        XCTAssertNoThrow(try view.inspect().scrollView(1))
    }
    
    func testContentInsets() throws {
        let sut = ScrollView { Text("") }
        let contentInsets = try sut.inspect().contentInsets()
        XCTAssertEqual(contentInsets, EdgeInsets())
    }
}
