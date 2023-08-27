import XCTest
import SwiftUI
@testable import ViewInspector

@available(iOS 13.0, *)
@available(macOS, unavailable)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
final class MultiDatePickerTests: XCTestCase {

    func testExtractionFromSingleViewContainer() throws {
        guard #available(iOS 16.0, *) else { throw XCTSkip() }
        let binding = Binding(wrappedValue: Set<DateComponents>())
        let view = AnyView(MultiDatePicker("Title", selection: binding))
        XCTAssertNoThrow(try view.inspect().anyView().multiDatePicker())
    }

    func testExtractionFromMultipleViewContainer() throws {
        guard #available(iOS 16.0, *) else { throw XCTSkip() }
        let binding = Binding(wrappedValue: Set<DateComponents>())
        let view = HStack {
            MultiDatePicker("1", selection: binding)
            MultiDatePicker("2", selection: binding)
        }
        XCTAssertNoThrow(try view.inspect().hStack().multiDatePicker(0))
        XCTAssertNoThrow(try view.inspect().hStack().multiDatePicker(1))
    }
    
    func testResetsModifiers() throws {
        guard #available(iOS 16.0, *) else { throw XCTSkip() }
        let binding = Binding(wrappedValue: Set<DateComponents>())
        let view = MultiDatePicker("Title", selection: binding)
        let sut = try view.inspect().multiDatePicker().labelView().text()
        XCTAssertEqual(sut.content.medium.viewModifiers.count, 0)
    }
    
    func testLabelView() throws {
        guard #available(iOS 16.0, *) else { throw XCTSkip() }
        let binding = Binding(wrappedValue: Set<DateComponents>())
        let view = MultiDatePicker(selection: binding) {
            HStack { Text("Title") }
        }
        let sut = try view.inspect().multiDatePicker().labelView().hStack().text(0).string()
        XCTAssertEqual(sut, "Title")
    }
    
    func testSearch() throws {
        guard #available(iOS 16.0, *) else { throw XCTSkip() }
        let binding = Binding(wrappedValue: Set<DateComponents>())
        let view = AnyView(MultiDatePicker("Title", selection: binding))
        XCTAssertEqual(try view.inspect().find(ViewType.MultiDatePicker.self).pathToRoot,
                       "anyView().multiDatePicker()")
        XCTAssertEqual(try view.inspect().find(text: "Title").pathToRoot,
                       "anyView().multiDatePicker().labelView().text()")
    }
    
    func testValueSelection() throws {
        guard #available(iOS 16.0, *) else { throw XCTSkip() }
        let binding = Binding(wrappedValue: Set<DateComponents>())
        let view = MultiDatePicker("Title", selection: binding)
        let selection = Set(
            [Date().advanced(by: 100), Date().advanced(by: 200)]
            .map { Calendar.current.dateComponents([.day], from: $0) })
        try view.inspect().multiDatePicker().select(dateComponents: selection)
        XCTAssertEqual(binding.wrappedValue, selection)
    }

    func testValueSelectionWhenDisabled() throws {
        guard #available(iOS 16.0, *) else { throw XCTSkip() }
        let original = Set<DateComponents>()
        let binding = Binding(wrappedValue: original)
        let view = MultiDatePicker("Title", selection: binding).disabled(true)
        let selection = Set(
            [Date().advanced(by: 100), Date().advanced(by: 200)]
            .map { Calendar.current.dateComponents([.day], from: $0) })
        XCTAssertThrows(try view.inspect().multiDatePicker().select(dateComponents: selection),
            "MultiDatePicker is unresponsive: it is disabled")
        XCTAssertEqual(binding.wrappedValue, original)
    }
    
    func testMinimumDate() throws {
        guard #available(iOS 16.0, *) else { throw XCTSkip() }
        let binding = Binding(wrappedValue: Set<DateComponents>())
        let minDate = Date()
        let view = MultiDatePicker("Title", selection: binding, in: minDate...)
        let sut = try view.inspect().multiDatePicker().minimumDate()
        XCTAssertEqual(sut, minDate)
    }
    
    func testMaximumDate() throws {
        guard #available(iOS 16.0, *) else { throw XCTSkip() }
        let binding = Binding(wrappedValue: Set<DateComponents>())
        let maxDate = Date()
        let view = MultiDatePicker("Title", selection: binding, in: ..<maxDate)
        let sut = try view.inspect().multiDatePicker().maximumDate()
        XCTAssertEqual(sut, maxDate)
    }
}
