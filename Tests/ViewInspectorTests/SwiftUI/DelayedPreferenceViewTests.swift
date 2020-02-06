import XCTest
import SwiftUI
@testable import ViewInspector

final class DelayedPreferenceViewTests: XCTestCase {
    
    func testIncorrectUnwrap() throws {
        let view = Group {
            Text("").overlayPreferenceValue(Key.self) { _ in EmptyView() }
        }
        XCTAssertThrowsError(try view.inspect().group().text(0))
    }
    
    func testUnknownHierarchyTypeUnwrap() throws {
        let view = Group {
            Text("").overlayPreferenceValue(Key.self) { _ in EmptyView() }
        }
        XCTAssertThrowsError(try view.inspect().group().preferenceValue(Key.self))
    }
    
    func testKnownHierarchyTypeUnwrap() throws {
        let view = Group {
            Text("").overlayPreferenceValue(Key.self) { _ in EmptyView() }
        }
        XCTAssertNoThrow(try view.inspect().group()
            .preferenceValue(Key.self, base: Text.self, overlay: EmptyView.self).emptyView())
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
