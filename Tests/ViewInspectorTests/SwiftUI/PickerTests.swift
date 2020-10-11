import XCTest
import SwiftUI
@testable import ViewInspector

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
final class PickerTests: XCTestCase {
    
    func testEnclosedView() throws {
        let binding = Binding<Int?>(wrappedValue: nil)
        let view = Picker(selection: binding, label: Text("Title")) {
            Text("First Option").tag(0)
            Text("Second Option").tag(1)
        }
        let text = try view.inspect().picker().text(0).string()
        XCTAssertEqual(text, "First Option")
    }
    
    func testLabelView() throws {
        let binding = Binding<Int?>(wrappedValue: nil)
        let view = Picker(selection: binding, label: Text("Title")) {
            Text("First Option").tag(0)
            Text("Second Option").tag(1)
        }
        let text = try view.inspect().picker().label().text().string()
        XCTAssertEqual(text, "Title")
    }
    
    func testResetsModifiers() throws {
        let binding = Binding<Int?>(wrappedValue: nil)
        let view = Picker(selection: binding, label: Text("Title")) {
            Text("First Option").tag(0)
            Text("Second Option").tag(1)
        }.padding().padding()
        let sut = try view.inspect().picker().text(0)
        XCTAssertEqual(sut.content.modifiers.count, 1)
    }
    
    func testExtractionFromSingleViewContainer() throws {
        let binding = Binding<Int?>(wrappedValue: nil)
        let picker = Picker(selection: binding, label: Text("Title")) {
            Text("First Option").tag(0)
            Text("Second Option").tag(1)
        }
        let view = AnyView(picker)
        XCTAssertNoThrow(try view.inspect().anyView().picker())
    }
    
    func testExtractionFromMultipleViewContainer() throws {
        let binding = Binding<Int?>(wrappedValue: nil)
        let picker = Picker(selection: binding, label: Text("Title")) {
            Text("First Option").tag(0)
            Text("Second Option").tag(1)
        }
        let view = HStack { picker; picker }
        XCTAssertNoThrow(try view.inspect().hStack().picker(0))
        XCTAssertNoThrow(try view.inspect().hStack().picker(1))
    }
}

// MARK: - View Modifiers

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
final class GlobalModifiersForPicker: XCTestCase {
    
    func testPickerStyle() throws {
        let sut = EmptyView().pickerStyle(DefaultPickerStyle())
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testPickerStyleInspection() throws {
        let sut = EmptyView().pickerStyle(DefaultPickerStyle())
        XCTAssertTrue(try sut.inspect().pickerStyle() is DefaultPickerStyle)
    }
}
