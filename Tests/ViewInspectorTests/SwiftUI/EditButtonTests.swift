import XCTest
import SwiftUI
@testable import ViewInspector

#if os(iOS)

final class EditButtonTests: XCTestCase {
    
    func testExtractionFromSingleViewContainer() throws {
        let view = AnyView(EditButton())
        XCTAssertNoThrow(try view.inspect().editButton())
    }
    
    func testExtractionFromMultipleViewContainer() throws {
        let view = HStack { EditButton(); EditButton() }
        XCTAssertNoThrow(try view.inspect().editButton(0))
        XCTAssertNoThrow(try view.inspect().editButton(1))
    }
}

#endif
