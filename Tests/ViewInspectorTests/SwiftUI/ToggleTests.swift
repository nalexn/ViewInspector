import XCTest
import SwiftUI
@testable import ViewInspector

final class ToggleTests: XCTestCase {
    
    @State var isOn1 = false
    @State var isOn2 = false
    
    override func setUp() {
        isOn1 = false
        isOn2 = false
    }
    
    func testEnclosedView() throws {
        let view = Toggle(isOn: $isOn1) { Text("Test") }
        let text = try view.inspect().toggle().text().string()
        XCTAssertEqual(text, "Test")
    }
    
    func testResetsModifiers() throws {
        let view = Toggle(isOn: $isOn1) { Text("Test") }.padding()
        let sut = try view.inspect().toggle().text()
        XCTAssertEqual(sut.content.modifiers.count, 0)
    }
    
    func testExtractionFromSingleViewContainer() throws {
        let view = AnyView(Toggle(isOn: $isOn1) { Text("Test") })
        XCTAssertNoThrow(try view.inspect().anyView().toggle())
    }
    
    func testExtractionFromMultipleViewContainer() throws {
        let view = HStack {
            Toggle(isOn: $isOn1) { Text("Test") }
            Toggle(isOn: $isOn2) { Text("Test") }
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
