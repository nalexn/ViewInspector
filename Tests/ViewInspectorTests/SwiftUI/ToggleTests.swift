import XCTest
import SwiftUI
@testable import ViewInspector

final class ToggleTests: XCTestCase {
    
    func testEnclosedView() throws {
        let binding = Binding(wrappedValue: false)
        let view = Toggle(isOn: binding) { Text("Test") }
        let text = try view.inspect().toggle().text().string()
        XCTAssertEqual(text, "Test")
    }
    
    func testResetsModifiers() throws {
        let binding = Binding(wrappedValue: false)
        let view = Toggle(isOn: binding) { Text("Test") }.padding()
        let sut = try view.inspect().toggle().text()
        XCTAssertEqual(sut.content.modifiers.count, 0)
    }
    
    func testExtractionFromSingleViewContainer() throws {
        let binding = Binding(wrappedValue: false)
        let view = AnyView(Toggle(isOn: binding) { Text("Test") })
        XCTAssertNoThrow(try view.inspect().anyView().toggle())
    }
    
    func testExtractionFromMultipleViewContainer() throws {
        let binding = Binding(wrappedValue: false)
        let view = HStack {
            Toggle(isOn: binding) { Text("Test") }
            Toggle(isOn: binding) { Text("Test") }
        }
        XCTAssertNoThrow(try view.inspect().hStack().toggle(0))
        XCTAssertNoThrow(try view.inspect().hStack().toggle(1))
    }
}

// MARK: - View Modifiers

final class GlobalModifiersForToggle: XCTestCase {
    
    func testToggleStyle() throws {
        let sut = EmptyView().toggleStyle(DefaultToggleStyle())
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
}
