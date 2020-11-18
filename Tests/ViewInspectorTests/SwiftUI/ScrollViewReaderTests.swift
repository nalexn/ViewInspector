import XCTest
import SwiftUI
@testable import ViewInspector

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
final class ScrollViewReaderTests: XCTestCase {
    
    func testExtractionFromSingleViewContainer() throws {
        guard #available(iOS 14, macOS 11.0, tvOS 14.0, *) else { return }
        let view = AnyView(ScrollViewReader { _ in EmptyView() })
        XCTAssertNoThrow(try view.inspect().anyView().scrollViewReader())
    }
    
    func testExtractionFromMultipleViewContainer() throws {
        guard #available(iOS 14, macOS 11.0, tvOS 14.0, *) else { return }
        let view = HStack {
            Text("")
            ScrollViewReader { _ in EmptyView() }
            Text("")
        }
        XCTAssertNoThrow(try view.inspect().hStack().scrollViewReader(1))
    }
    
    func testEnclosedView() throws {
        guard #available(iOS 14, macOS 11.0, tvOS 14.0, *) else { return }
        let view = ScrollViewReader { _ in Text("abc") }
        let value = try view.inspect().scrollViewReader().text().string()
        XCTAssertEqual(value, "abc")
    }
}
