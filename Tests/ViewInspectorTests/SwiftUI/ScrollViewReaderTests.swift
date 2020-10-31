import XCTest
import SwiftUI
@testable import ViewInspector

#if !os(macOS)
@available(iOS 14.0, macOS 11.0, tvOS 14.0, *)
final class ScrollViewReaderTests: XCTestCase {
    
    func testExtractionFromSingleViewContainer() throws {
        let view = AnyView(ScrollViewReader { _ in EmptyView() })
        XCTAssertNoThrow(try view.inspect().anyView().scrollViewReader())
    }
    
    func testExtractionFromMultipleViewContainer() throws {
        let view = HStack {
            Text("")
            ScrollViewReader { _ in EmptyView() }
            Text("")
        }
        XCTAssertNoThrow(try view.inspect().hStack().scrollViewReader(1))
    }
    
    func testEnclosedView() throws {
        let view = ScrollViewReader { _ in Text("abc") }
        let value = try view.inspect().scrollViewReader().text().string()
        XCTAssertEqual(value, "abc")
    }
}
#endif
