import XCTest
import SwiftUI
@testable import ViewInspector

final class TreeViewTests: XCTestCase {
    
    #if !os(tvOS)
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
    #endif
}

// MARK: - View Modifiers

final class GlobalModifiersForTreeView: XCTestCase {
    
    #if !os(tvOS)
    func testContextMenu() throws {
        let sut = EmptyView().contextMenu(ContextMenu(menuItems: { Text("") }))
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    #endif
}
