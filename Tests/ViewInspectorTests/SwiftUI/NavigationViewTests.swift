import XCTest
import SwiftUI
@testable import ViewInspector

#if !os(watchOS)

final class NavigationViewTests: XCTestCase {
    
    func testEnclosedView() throws {
        let sampleView = Text("Test")
        let view = NavigationView { sampleView }
        let sut = try view.inspect().text().view as? Text
        XCTAssertEqual(sut, sampleView)
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
    
    static var allTests = [
        ("testEnclosedView", testEnclosedView),
        ("testExtractionFromSingleViewContainer", testExtractionFromSingleViewContainer),
        ("testExtractionFromMultipleViewContainer", testExtractionFromMultipleViewContainer),
    ]
}

#endif
