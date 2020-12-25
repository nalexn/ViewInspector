import XCTest
import SwiftUI
@testable import ViewInspector

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
final class ToggleTests: XCTestCase {
    
    func testEnclosedView() throws {
        let binding = Binding(wrappedValue: false)
        let view = Toggle(isOn: binding) { Text("Test") }
        let text = try view.inspect().toggle().labelView().text().string()
        XCTAssertEqual(text, "Test")
    }
    
    func testResetsModifiers() throws {
        let binding = Binding(wrappedValue: false)
        let view = Toggle(isOn: binding) { Text("Test") }.padding()
        let sut = try view.inspect().toggle().labelView().text()
        XCTAssertEqual(sut.content.modifiers.count, 0)
    }
    
    func testTapAndIsOn() throws {
        let binding = Binding(wrappedValue: false)
        let view = Toggle(isOn: binding) { Text("") }
        let sut = try view.inspect().toggle()
        XCTAssertFalse(binding.wrappedValue)
        XCTAssertFalse(try sut.isOn())
        try sut.tap()
        XCTAssertTrue(binding.wrappedValue)
        XCTAssertTrue(try sut.isOn())
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

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
final class GlobalModifiersForToggle: XCTestCase {
    
    func testToggleStyle() throws {
        let sut = EmptyView().toggleStyle(DefaultToggleStyle())
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testToggleStyleInspection() throws {
        let sut = EmptyView().toggleStyle(DefaultToggleStyle())
        XCTAssertTrue(try sut.inspect().toggleStyle() is DefaultToggleStyle)
    }
    
    func testToggleStyleConfiguration() throws {
        let sut1 = ToggleStyleConfiguration(isOn: false)
        let sut2 = ToggleStyleConfiguration(isOn: true)
        XCTAssertFalse(sut1.isOn)
        XCTAssertTrue(sut2.isOn)
    }
    
    func testCustomMenuStyleInspection() throws {
        let sut = TestToggleStyle()
        XCTAssertEqual(try sut.inspect(isOn: true).vStack().styleConfigurationLabel(0).blur().radius, 5)
        XCTAssertEqual(try sut.inspect(isOn: false).vStack().styleConfigurationLabel(0).blur().radius, 0)
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
private struct TestToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        VStack {
            configuration.label
                .blur(radius: configuration.isOn ? 5 : 0)
        }
    }
}
