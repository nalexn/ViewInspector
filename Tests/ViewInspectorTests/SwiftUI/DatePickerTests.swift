import XCTest
import SwiftUI
@testable import ViewInspector

@available(iOS 13.0, macOS 10.15, *)
@available(tvOS, unavailable)
final class DatePickerTests: XCTestCase {
    
    class StateObject: ObservableObject {
        @Published var selectedDate1 = Date()
        @Published var selectedDate2 = Date()
    }
    @ObservedObject var state = StateObject()
    
    override func setUp() {
        state = StateObject()
    }
    
    func testEnclosedView() throws {
        let sampleView = Text("Test")
        let view = DatePicker(selection: $state.selectedDate1, label: { sampleView })
        let sut = try view.inspect().datePicker().labelView().text().content.view as? Text
        XCTAssertEqual(sut, sampleView)
    }
    
    func testValueSelection() throws {
        let binding = Binding<Date>(wrappedValue: Date())
        let view = DatePicker("Title", selection: binding)
        let expectedDate = Date().advanced(by: 100)
        try view.inspect().datePicker().select(date: expectedDate)
        XCTAssertEqual(binding.wrappedValue, expectedDate)
    }
    
    func testValueSelectionOnDisabledPicker() throws {
        let originalDate = Date()
        let binding = Binding<Date>(wrappedValue: originalDate)
        let view = DatePicker("Title", selection: binding).disabled(true)
        try view.inspect().datePicker().select(date: originalDate.advanced(by: 100))
        XCTAssertEqual(binding.wrappedValue, originalDate)
    }
    
    func testResetsModifiers() throws {
        let view = DatePicker("Test", selection: $state.selectedDate1).padding()
        let sut = try view.inspect().datePicker().labelView().text()
        XCTAssertEqual(sut.content.medium.viewModifiers.count, 0)
    }
    
    func testExtractionFromSingleViewContainer() throws {
        let view = AnyView(DatePicker("Test", selection: $state.selectedDate1))
        XCTAssertNoThrow(try view.inspect().anyView().datePicker())
    }
    
    func testExtractionFromMultipleViewContainer() throws {
        let view = HStack {
            DatePicker("Test", selection: $state.selectedDate1)
            DatePicker("Test", selection: $state.selectedDate2)
        }
        XCTAssertNoThrow(try view.inspect().hStack().datePicker(0))
        XCTAssertNoThrow(try view.inspect().hStack().datePicker(1))
    }
    
    func testSearch() throws {
        let view = AnyView(DatePicker("Test", selection: $state.selectedDate1))
        XCTAssertEqual(try view.inspect().find(ViewType.DatePicker.self).pathToRoot,
                       "anyView().datePicker()")
        XCTAssertEqual(try view.inspect().find(text: "Test").pathToRoot,
                       "anyView().datePicker().labelView().text()")
    }
}

// MARK: - View Modifiers

@available(iOS 13.0, macOS 10.15, *)
@available(tvOS, unavailable)
final class GlobalModifiersForDatePicker: XCTestCase {
    
    func testDatePickerStyle() throws {
        let sut = EmptyView().datePickerStyle(DefaultDatePickerStyle())
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testDatePickerStyleInspection() throws {
        let sut = EmptyView().datePickerStyle(DefaultDatePickerStyle())
        XCTAssertTrue(try sut.inspect().datePickerStyle() is DefaultDatePickerStyle)
    }
}
