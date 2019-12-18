import XCTest
import SwiftUI
@testable import ViewInspector

#if !os(tvOS)

final class TreeViewTests: XCTestCase {
    
    func testEnclosedView() throws {
        let sut = Text("Test").contextMenu(ContextMenu(menuItems: { Text("Menu") }))
        let text = try sut.inspect().text().string()
        XCTAssertEqual(text, "Test")
    }
    
    func testRetainsModifiers() throws {
        let view = Text("Test")
            .padding()
            .contextMenu(ContextMenu(menuItems: { Text("Menu") }))
            .padding().padding()
        let sut = try view.inspect().text()
        XCTAssertEqual(sut.content.modifiers.count, 3)
    }
}

// MARK: - View Modifiers

final class GlobalModifiersForTreeView: XCTestCase {
    
    func testContextMenu() throws {
        let sut = EmptyView().contextMenu(ContextMenu(menuItems: { Text("") }))
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
}

#endif
