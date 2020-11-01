import XCTest
import SwiftUI
@testable import ViewInspector

#if !os(macOS)
@available(iOS 14.0, macOS 11.0, *)
@available(tvOS, unavailable)
final class TextEditorTests: XCTestCase {
    
    func testExtractionFromSingleViewContainer() throws {
        let binding = Binding(wrappedValue: "")
        let view = AnyView(TextEditor(text: binding))
        XCTAssertNoThrow(try view.inspect().anyView().textEditor())
    }
    
    func testExtractionFromMultipleViewContainer() throws {
        let binding = Binding(wrappedValue: "")
        let view = HStack {
            Text("Test")
            TextEditor(text: binding)
        }
        XCTAssertNoThrow(try view.inspect().hStack().textEditor(1))
    }
}
#endif
