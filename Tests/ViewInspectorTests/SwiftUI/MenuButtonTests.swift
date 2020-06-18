import XCTest
import SwiftUI
@testable import ViewInspector

#if os(macOS)

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
final class MenuButtonTests: XCTestCase {
    
    func testEnclosedView() throws {
        let sut = MenuButton(label: Text("")) { EmptyView() }
        XCTAssertNoThrow(try sut.inspect().menuButton().emptyView())
    }
    
    func testResetsModifiers() throws {
        let view = MenuButton(label: Text("")) { EmptyView() }.padding()
        let sut = try view.inspect().menuButton().emptyView()
        XCTAssertEqual(sut.content.modifiers.count, 0)
    }
    
    func testExtractionFromSingleViewContainer() throws {
        let view = AnyView(MenuButton(label: Text("")) { EmptyView() })
        XCTAssertNoThrow(try view.inspect().anyView().menuButton())
    }
    
    func testExtractionFromMultipleViewContainer() throws {
        let view = HStack {
            MenuButton(label: Text("")) { EmptyView() }
            MenuButton(label: Text("")) { EmptyView() }
        }
        XCTAssertNoThrow(try view.inspect().hStack().menuButton(0))
        XCTAssertNoThrow(try view.inspect().hStack().menuButton(1))
    }
    
    func testLabelView() throws {
        let sut = MenuButton(label: Text("abc")) { EmptyView() }
        let text = try sut.inspect().menuButton().label().text().string()
        XCTAssertEqual(text, "abc")
    }
}

// MARK: - View Modifiers

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
final class GlobalModifiersForMenuMenuButton: XCTestCase {
    
    func testMenuButtonStyle() throws {
        let sut = EmptyView().menuButtonStyle(PullDownMenuButtonStyle())
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
}

#endif
