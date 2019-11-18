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
    
    func testEditMode() throws {
        let data = ["abc", "123", "xyz"]
        func delete(at offsets: IndexSet) {
            print("!")
        }
        let view = NavigationView {
            List {
                ForEach(data, id: \.self) { Text($0) }
                .onDelete(perform: delete)
            }
            .navigationBarItems(trailing: EditButton())
        }
//        view
    }
    
    static var allTests = [
        ("testExtractionFromSingleViewContainer", testExtractionFromSingleViewContainer),
        ("testExtractionFromMultipleViewContainer", testExtractionFromMultipleViewContainer),
        ("testEditMode", testEditMode),
    ]
}

#endif
