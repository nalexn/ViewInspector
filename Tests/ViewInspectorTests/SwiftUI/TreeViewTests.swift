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
        let count: Int
        if #available(iOS 15.3, tvOS 15.3, macOS 12.3, *) {
            count = 4
        } else {
            count = 3
        }
        XCTAssertEqual(sut.content.medium.viewModifiers.count, count)
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
