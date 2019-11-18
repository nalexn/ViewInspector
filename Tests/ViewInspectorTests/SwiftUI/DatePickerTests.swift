import XCTest
import SwiftUI
@testable import ViewInspector

final class DatePickerTests: XCTestCase {
    
    class StateObject: ObservableObject {
        @Published var selectedDate1 = Date()
        @Published var selectedDate2 = Date()
    }
    @ObservedObject var state = StateObject()
    
    override func setUp() {
        state = StateObject()
    }
    
    func testBindingValue() throws {
        let view = DatePicker("Test", selection: $state.selectedDate1)
        let binding = try view.inspect().date()
        let selectDate = Date(timeIntervalSinceNow: 1000)
        binding.wrappedValue = selectDate
        XCTAssertEqual(state.selectedDate1, selectDate)
    }
    
    func testEnclosedView() throws {
        let sampleView = Text("Test")
        let view = DatePicker(selection: $state.selectedDate1, label: { sampleView })
        let sut = try view.inspect().text().view as? Text
        XCTAssertEqual(sut, sampleView)
    }
    
    func testDatePickerExtractionFromSingleViewContainer() throws {
        let view = AnyView(DatePicker("Test", selection: $state.selectedDate1))
        XCTAssertNoThrow(try view.inspect().datePicker())
    }
    
    func testDatePickerExtractionFromMultipleViewContainer() throws {
        let view = HStack {
            DatePicker("Test", selection: $state.selectedDate1)
            DatePicker("Test", selection: $state.selectedDate2)
        }
        XCTAssertNoThrow(try view.inspect().datePicker(0))
        XCTAssertNoThrow(try view.inspect().datePicker(1))
    }
    
    static var allTests = [
        ("testBindingValue", testBindingValue),
        ("testEnclosedView", testEnclosedView),
        ("testDatePickerExtractionFromSingleViewContainer",
         testDatePickerExtractionFromSingleViewContainer),
        ("testDatePickerExtractionFromMultipleViewContainer",
         testDatePickerExtractionFromMultipleViewContainer),
    ]
}
