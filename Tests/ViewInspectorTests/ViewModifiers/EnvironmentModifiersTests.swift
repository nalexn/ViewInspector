import XCTest
import SwiftUI
@testable import ViewInspector

// MARK: - ViewEnvironmentTests

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
final class ViewEnvironmentTests: XCTestCase {
    
    func testEnvironment() throws {
        let key = TestEnvKey()
        let sut = EmptyView().environment(\.testKey, key)
        XCTAssertNoThrow(try sut.inspect().emptyView())
        XCTAssertNoThrow(try sut.inspect().emptyView().environment(\.testKey))
        XCTAssertThrows(try EmptyView().inspect().emptyView().environment(\.testKey),
                        "EmptyView does not have 'environment(TestEnvKey)' modifier")
        let sut2 = EmptyView().environment(\.colorScheme, .light)
        XCTAssertEqual(try sut2.inspect().emptyView().environment(\.colorScheme), .light)
    }
    
    func testEnvironmentObject() throws {
        let sut = EmptyView().environmentObject(TestEnvObject())
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testTransformEnvironment() throws {
        let sut = EmptyView().transformEnvironment(\.testKey, transform: { _ in })
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
private class TestEnvObject: ObservableObject { }

private struct TestEnvKey: EnvironmentKey {
    static var defaultValue: Self { .init() }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
private extension EnvironmentValues {
    var testKey: TestEnvKey {
        get { self[TestEnvKey.self] }
        set { self[TestEnvKey.self] = newValue }
    }
}

// MARK: - ViewPreferenceTests

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
final class ViewPreferenceTests: XCTestCase {
    
    func testPreference() throws {
        let sut = EmptyView().preference(key: Key.self, value: "test")
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testTransformPreference() throws {
        let sut = EmptyView().transformPreference(Key.self) { _ in }
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testAnchorPreference() throws {
        let source = Anchor.Source([Anchor<String>.Source]())
        let sut = EmptyView().anchorPreference(key: Key.self, value: source, transform: { _ in "" })
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testTransformAnchorPreference() throws {
        let source = Anchor.Source([Anchor<String>.Source]())
        let sut = EmptyView().transformAnchorPreference(key: Key.self, value: source, transform: { _, _ in })
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testOnPreferenceChange() throws {
        let sut = EmptyView().onPreferenceChange(Key.self) { _ in }
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testBackgroundPreferenceValue() throws {
        let sut = EmptyView().backgroundPreferenceValue(Key.self) { _ in Text("") }
        // Not supported
        // swiftlint:disable line_length
        XCTAssertThrows(
            try sut.inspect().emptyView(),
            "'PreferenceValue' modifiers are currently not supported. Consider extracting the enclosed view for direct inspection.")
        // swiftlint:enable line_length
    }
    
    func testOverlayPreferenceValue() throws {
        let sut = EmptyView().overlayPreferenceValue(Key.self) { _ in Text("") }
        // Not supported
        // swiftlint:disable line_length
        XCTAssertThrows(
            try sut.inspect().emptyView(),
            "'PreferenceValue' modifiers are currently not supported. Consider extracting the enclosed view for direct inspection.")
        // swiftlint:enable line_length
    }
    
    struct Key: PreferenceKey {
        static var defaultValue: String = "abc"
        static func reduce(value: inout String, nextValue: () -> String) {
            value = nextValue()
        }
    }
}
