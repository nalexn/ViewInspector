import XCTest
import SwiftUI
@testable import ViewInspector

final class PickerTests: XCTestCase {
    
    @State private var selection: Int?
    
    func testEnclosedView() throws {
        let view = Picker(selection: $selection, label: Text("Title")) {
            Text("First Option").tag(0)
            Text("Second Option").tag(1)
        }
        let text = try view.inspect().picker().text(0).string()
        XCTAssertEqual(text, "First Option")
    }
    
    func testLabelView() throws {
        let view = Picker(selection: $selection, label: Text("Title")) {
            Text("First Option").tag(0)
            Text("Second Option").tag(1)
        }
        let text = try view.inspect().picker().label().text().string()
        XCTAssertEqual(text, "Title")
    }
    
    func testResetsModifiers() throws {
        let view = Picker(selection: $selection, label: Text("Title")) {
            Text("First Option").tag(0)
            Text("Second Option").tag(1)
        }.padding().padding()
        let sut = try view.inspect().picker().text(0)
        XCTAssertEqual(sut.content.modifiers.count, 1)
    }
    
    func testExtractionFromSingleViewContainer() throws {
        let picker = Picker(selection: $selection, label: Text("Title")) {
            Text("First Option").tag(0)
            Text("Second Option").tag(1)
        }
        let view = AnyView(picker)
        XCTAssertNoThrow(try view.inspect().anyView().picker())
    }
    
    func testExtractionFromMultipleViewContainer() throws {
        let picker = Picker(selection: $selection, label: Text("Title")) {
            Text("First Option").tag(0)
            Text("Second Option").tag(1)
        }
        let view = HStack { picker; picker }
        XCTAssertNoThrow(try view.inspect().hStack().picker(0))
        XCTAssertNoThrow(try view.inspect().hStack().picker(1))
    }
}

// MARK: - View Modifiers

final class GlobalModifiersForPicker: XCTestCase {
    
    func testPickerStyle() throws {
        let sut = EmptyView().pickerStyle(DefaultPickerStyle())
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
}
