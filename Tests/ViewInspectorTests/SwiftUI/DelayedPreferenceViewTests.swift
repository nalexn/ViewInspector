import XCTest
import SwiftUI
@testable import ViewInspector

final class DelayedPreferenceViewTests: XCTestCase {
    
    #if os(iOS) || os(tvOS)
    func testUnwrapDelayedPreferenceView() throws {
        let view = NavigationView {
            Text("Test")
                .backgroundPreferenceValue(Key.self) { _ in EmptyView() }
        }
        // Not supported
        XCTAssertThrowsError(try view.inspect().text(0))
    }
    #endif
    
    struct Key: PreferenceKey {
        static var defaultValue: String = "test"
        static func reduce(value: inout String, nextValue: () -> String) {
            value = nextValue()
        }
    }
}
