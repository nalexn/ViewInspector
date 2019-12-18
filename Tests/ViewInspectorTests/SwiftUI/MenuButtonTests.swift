import XCTest
import SwiftUI
@testable import ViewInspector

final class MenuButtonTests: XCTestCase {
    
    func testEnclosedView() throws {
        let sut = MenuButton(label: Text("")) { EmptyView() }
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testResetsModifiers() throws {
        let view = MenuButton(label: Text("")) { EmptyView() }.padding()
        let sut = try view.inspect().menuButton().emptyView()
        XCTAssertEqual(sut.content.modifiers.count, 0)
    }
    
    func testExtractionFromSingleViewContainer() throws {
        let view = AnyView(MenuButton(label: Text("")) { EmptyView() })
        XCTAssertNoThrow(try view.inspect().menuButton())
    }
    
    func testExtractionFromMultipleViewContainer() throws {
        let view = HStack {
            MenuButton(label: Text("")) { EmptyView() }
            MenuButton(label: Text("")) { EmptyView() }
        }
        XCTAssertNoThrow(try view.inspect().menuButton(0))
        XCTAssertNoThrow(try view.inspect().menuButton(1))
    }
    
    func testLabelView() throws {
        let sut = MenuButton(label: Text("abc")) { EmptyView() }
        let text = try sut.inspect().label().text().string()
        XCTAssertEqual(text, "abc")
    }
}

// MARK: - View Modifiers

final class GlobalModifiersForMenuMenuButton: XCTestCase {
    
    #if os(macOS)
    func testMenuButtonStyle() throws {
        let sut = EmptyView().menuButtonStyle(PullDownMenuButtonStyle())
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    #endif
}
