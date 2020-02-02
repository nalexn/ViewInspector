import XCTest
import SwiftUI
@testable import ViewInspector

#if os(macOS)

final class PasteButtonTests: XCTestCase {
    
    func testExtractionFromSingleViewContainer() throws {
        let view = AnyView(PasteButton(supportedTypes: [], payloadAction: { _ in }))
        XCTAssertNoThrow(try view.inspect().anyView().pasteButton())
    }
    
    func testExtractionFromMultipleViewContainer() throws {
        let view = HStack {
            PasteButton(supportedTypes: [], payloadAction: { _ in })
            PasteButton(supportedTypes: [], payloadAction: { _ in })
        }
        XCTAssertNoThrow(try view.inspect().hStack().pasteButton(0))
        XCTAssertNoThrow(try view.inspect().hStack().pasteButton(1))
    }
    
    func testSupportedTypes() throws {
        let types = ["abc", "def"]
        let view = PasteButton(supportedTypes: types, payloadAction: { _ in })
        let sut = try view.inspect().pasteButton().supportedTypes()
        XCTAssertEqual(sut, types)
    }
}

#endif
