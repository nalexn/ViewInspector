import XCTest
import SwiftUI
@testable import ViewInspector

#if !os(macOS) && !targetEnvironment(macCatalyst)
@available(iOS 13.0, macOS 10.15, *)
@available(tvOS, unavailable)
final class TextEditorTests: XCTestCase {
    
    func testExtractionFromSingleViewContainer() throws {
        guard #available(iOS 14, macOS 11.0, *) else { return }
        let binding = Binding(wrappedValue: "")
        let view = AnyView(TextEditor(text: binding))
        XCTAssertNoThrow(try view.inspect().anyView().textEditor())
    }
    
    func testExtractionFromMultipleViewContainer() throws {
        guard #available(iOS 14, macOS 11.0, *) else { return }
        let binding = Binding(wrappedValue: "")
        let view = HStack {
            Text("Test")
            TextEditor(text: binding)
        }
        XCTAssertNoThrow(try view.inspect().hStack().textEditor(1))
    }
}
#endif
