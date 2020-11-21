import XCTest
import SwiftUI
@testable import ViewInspector

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
final class ScrollViewTests: XCTestCase {
    
    func testEnclosedView() throws {
        let sampleView = Text("Test")
        let view = ScrollView { sampleView }
        let sut = try view.inspect().scrollView().text().content.view as? Text
        XCTAssertEqual(sut, sampleView)
    }
    
    func testResetsModifiers() throws {
        let view = ScrollView { Text("Test") }.padding()
        let sut = try view.inspect().scrollView().text()
        XCTAssertEqual(sut.content.modifiers.count, 0)
    }
    
    func testExtractionFromSingleViewContainer() throws {
        let view = AnyView(ScrollView { Text("") })
        XCTAssertNoThrow(try view.inspect().anyView().scrollView())
    }
    
    func testExtractionFromMultipleViewContainer() throws {
        let view = HStack {
            ScrollView { Text("") }
            ScrollView { Text("") }
        }
        XCTAssertNoThrow(try view.inspect().hStack().scrollView(0))
        XCTAssertNoThrow(try view.inspect().hStack().scrollView(1))
    }
    
    func testContentInsets() throws {
        guard #available(iOS 13.1, macOS 10.16, tvOS 13.1, *) else { return }
        let sut = ScrollView { Text("") }
        let contentInsets = try sut.inspect().scrollView().contentInsets()
        XCTAssertEqual(contentInsets, EdgeInsets())
    }
}
