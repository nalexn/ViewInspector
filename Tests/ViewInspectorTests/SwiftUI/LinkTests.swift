import XCTest
import SwiftUI
@testable import ViewInspector

#if !os(macOS)
@available(iOS 14.0, macOS 11.0, tvOS 14.0, *)
final class LinkTests: XCTestCase {
    
    let url = URL(fileURLWithPath: "test")
    
    func testExtractionFromSingleViewContainer() throws {
        let view = AnyView(Link("abc", destination: url))
        XCTAssertNoThrow(try view.inspect().anyView().link())
    }
    
    func testExtractionFromMultipleViewContainer() throws {
        let view = HStack {
            Text("")
            Link("abc", destination: url)
            Text("")
        }
        XCTAssertNoThrow(try view.inspect().hStack().link(1))
    }
    
    func testURLInspection() throws {
        let view = Link("abc", destination: url)
        XCTAssertEqual(try view.inspect().link().url(), url)
    }
    
    func testLabelInspection() throws {
        let view = Link(destination: url, label: {
            HStack { Text("xyz") }
        })
        let sut = try view.inspect().link().label().hStack().text(0).string()
        XCTAssertEqual(sut, "xyz")
    }
}
#endif
