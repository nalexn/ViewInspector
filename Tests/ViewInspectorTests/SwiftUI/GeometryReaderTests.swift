import XCTest
import SwiftUI
@testable import ViewInspector

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
final class GeometryReaderTests: XCTestCase {
    
    func testEnclosedView() throws {
        let sampleView = Text("Test")
        let view = GeometryReader { _ in sampleView }
        let value = try view.inspect().geometryReader().text().string()
        XCTAssertEqual(value, "Test")
    }
    
    func testResetsModifiers() throws {
        let view = GeometryReader { _ in Text("Test") }.padding()
        let sut = try view.inspect().geometryReader().text()
        XCTAssertEqual(sut.content.medium.viewModifiers.count, 0)
    }
    
    func testExtractionFromSingleViewContainer() throws {
        let view = AnyView(GeometryReader { _ in EmptyView() })
        XCTAssertNoThrow(try view.inspect().anyView().geometryReader())
    }
    
    func testExtractionFromMultipleViewContainer() throws {
        let view = HStack {
            GeometryReader { _ in EmptyView() }
            GeometryReader { _ in EmptyView() }
        }
        XCTAssertNoThrow(try view.inspect().hStack().geometryReader(0))
        XCTAssertNoThrow(try view.inspect().hStack().geometryReader(1))
    }
    
    func testSearch() throws {
        let view = HStack { GeometryReader { _ in EmptyView() } }
        XCTAssertEqual(try view.inspect().find(ViewType.GeometryReader.self).pathToRoot,
                       "hStack().geometryReader(0)")
        XCTAssertEqual(try view.inspect().find(ViewType.EmptyView.self).pathToRoot,
                       "hStack().geometryReader(0).emptyView()")
    }
}
