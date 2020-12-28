import XCTest
import SwiftUI
@testable import ViewInspector

#if os(macOS)

@available(macOS 10.15, *)
@available(iOS, unavailable)
@available(tvOS, unavailable)
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
    
    func testSearch() throws {
        let view = AnyView(MenuButton(label: Text("abc")) { Text("xyz") })
        XCTAssertEqual(try view.inspect().find(ViewType.MenuButton.self).pathToRoot,
                       "anyView().menuButton()")
        XCTAssertEqual(try view.inspect().find(text: "abc").pathToRoot,
                       "anyView().menuButton().labelView().text()")
        XCTAssertEqual(try view.inspect().find(text: "xyz").pathToRoot,
                       "anyView().menuButton().text()")
    }
    
    func testLabelView() throws {
        let sut = MenuButton(label: Text("abc")) { EmptyView() }
        let text = try sut.inspect().menuButton().labelView().text().string()
        XCTAssertEqual(text, "abc")
    }
}

// MARK: - View Modifiers

@available(macOS 10.15, *)
@available(iOS, unavailable)
@available(tvOS, unavailable)
final class GlobalModifiersForMenuButton: XCTestCase {
    
    func testMenuButtonStyle() throws {
        let sut = EmptyView().menuButtonStyle(PullDownMenuButtonStyle())
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testMenuButtonStyleInspection() throws {
        let sut = EmptyView().menuButtonStyle(DefaultMenuButtonStyle())
        XCTAssertTrue(try sut.inspect().menuButtonStyle() is DefaultMenuButtonStyle)
    }
}

#endif
