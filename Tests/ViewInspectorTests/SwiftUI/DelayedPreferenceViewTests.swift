import XCTest
import SwiftUI
@testable import ViewInspector

#if os(iOS) || os(tvOS)

final class DelayedPreferenceViewTests: XCTestCase {
    
    func testUnwrapDelayedPreferenceView() throws {
        let view = NavigationView {
            Text("Test")
                .backgroundPreferenceValue(Key.self) { _ in EmptyView() }
        }
        // Not supported
        //swiftlint:disable line_length
        XCTAssertThrows(
            try view.inspect().navigationView().text(0),
            "ViewInspector: 'PreferenceValue' modifiers are currently not supported. Consider extracting the enclosed view for direct inspection.")
        //swiftlint:enable line_length
    }
    
    func testRetainsModifiers() throws {
        /* Disabled until supported
         
        let view = Text("Test")
            .padding()
            .backgroundPreferenceValue(Key.self) { _ in EmptyView() }
            .padding().padding()
        let sut = try view.inspect().text()
        XCTAssertEqual(sut.content.modifiers.count, 3)
        */
    }
    
    struct Key: PreferenceKey {
        static var defaultValue: String = "test"
        static func reduce(value: inout String, nextValue: () -> String) {
            value = nextValue()
        }
    }
}

#endif
