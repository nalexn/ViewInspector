import XCTest
import SwiftUI
@testable import ViewInspector

#if os(iOS)

final class EditButtonTests: XCTestCase {
    
    func testInspect() throws {
        XCTAssertNoThrow(try EditButton().inspect())
    }
    
    func testExtractionFromSingleViewContainer() throws {
        let view = AnyView(EditButton())
        XCTAssertNoThrow(try view.inspect().editButton())
    }
    
    func testExtractionFromMultipleViewContainer() throws {
        let view = HStack { EditButton(); EditButton() }
        XCTAssertNoThrow(try view.inspect().editButton(0))
        XCTAssertNoThrow(try view.inspect().editButton(1))
    }
    
    func testEditMode() throws {
        let view = EditButton()
        XCTAssertNoThrow(try view.inspect().editMode())
    }
}

#endif
