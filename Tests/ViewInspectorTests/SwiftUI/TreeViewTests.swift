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
    #endif
}
