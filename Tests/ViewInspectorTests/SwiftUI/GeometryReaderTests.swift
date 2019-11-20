import XCTest
import SwiftUI
@testable import ViewInspector

final class GeometryReaderTests: XCTestCase {
    
    func testEnclosedView() throws {
        let sampleView = Text("Test")
        let view = GeometryReader { _ in sampleView }
        let value = try view.inspect().text().string()
        XCTAssertEqual(value, "Test")
    }
    
    func testExtractionFromSingleViewContainer() throws {
        let view = AnyView(GeometryReader { _ in Text("Test") })
        XCTAssertNoThrow(try view.inspect().geometryReader())
    }
    
    func testExtractionFromMultipleViewContainer() throws {
        let view = HStack {
            GeometryReader { _ in Text("Test") }
            GeometryReader { _ in Text("Test") }
        }
        XCTAssertNoThrow(try view.inspect().geometryReader(0))
        XCTAssertNoThrow(try view.inspect().geometryReader(1))
    }
}
