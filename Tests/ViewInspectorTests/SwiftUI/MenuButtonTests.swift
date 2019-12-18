import XCTest
import SwiftUI
@testable import ViewInspector

// MARK: - View Modifiers

final class GlobalModifiersForMenuButton: XCTestCase {
    
    #if os(macOS)
    func testMenuButtonStyle() throws {
        let sut = EmptyView().menuButtonStyle(PullDownMenuButtonStyle())
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    #endif
}
