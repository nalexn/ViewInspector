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
