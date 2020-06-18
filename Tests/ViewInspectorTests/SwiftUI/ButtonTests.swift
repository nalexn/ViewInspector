import XCTest
import SwiftUI
@testable import ViewInspector

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
final class ButtonTests: XCTestCase {
    
    func testEnclosedView() throws {
        let sut = Button(action: {}, label: { Text("Test") })
        let text = try sut.inspect().button().text().string()
        XCTAssertEqual(text, "Test")
    }
    
    func testResetsModifiers() throws {
        let view = Button(action: {}, label: { Text("") }).padding()
        let sut = try view.inspect().button().text()
        XCTAssertEqual(sut.content.modifiers.count, 0)
    }
    
    func testExtractionFromSingleViewContainer() throws {
        let view = AnyView(Button(action: {}, label: { Text("") }))
        XCTAssertNoThrow(try view.inspect().anyView().button())
    }
    
    func testExtractionFromMultipleViewContainer() throws {
        let view = HStack {
            Button(action: {}, label: { Text("") })
            Button(action: {}, label: { Text("") })
        }
        XCTAssertNoThrow(try view.inspect().hStack().button(0))
        XCTAssertNoThrow(try view.inspect().hStack().button(1))
    }
    
    func testCallback() throws {
        let exp = XCTestExpectation(description: "Callback")
        let button = Button(action: {
            exp.fulfill()
        }, label: { Text("Test") })
        try button.inspect().button().tap()
        wait(for: [exp], timeout: 0.5)
    }
}

// MARK: - View Modifiers

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
final class GlobalModifiersForButton: XCTestCase {
    
    func testButtonStyle() throws {
        let sut = EmptyView().buttonStyle(PlainButtonStyle())
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
}
