import XCTest
import SwiftUI
@testable import ViewInspector

@available(iOS 13.0, macOS 10.15, *)
@available(tvOS, unavailable)
final class TreeViewTests: XCTestCase {
    
    @available(watchOS, deprecated: 7.0)
    func testEnclosedView() throws {
        let sut = Text("Test").contextMenu(ContextMenu(menuItems: { Text("Menu") }))
        let text = try sut.inspect().text().string()
        XCTAssertEqual(text, "Test")
    }
    
    @available(watchOS, deprecated: 7.0)
    func testRetainsModifiers() throws {
        let view = Text("Test")
            .padding()
            .contextMenu(ContextMenu(menuItems: { Text("Menu") }))
            .padding().padding()
        let sut = try view.inspect().text()
        XCTAssertEqual(sut.content.medium.viewModifiers.count, 3)
    }
}

// MARK: - View Modifiers

@available(iOS 13.0, macOS 10.15, *)
@available(tvOS, unavailable)
final class GlobalModifiersForTreeView: XCTestCase {
    
    @available(watchOS, deprecated: 7.0)
    func testContextMenu() throws {
        let sut = EmptyView().contextMenu(ContextMenu(menuItems: { Text("") }))
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
}
