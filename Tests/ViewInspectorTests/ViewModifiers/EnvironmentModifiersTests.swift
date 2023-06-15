import XCTest
import SwiftUI
@testable import ViewInspector

// MARK: - ViewEnvironmentTests

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
final class ViewEnvironmentTests: XCTestCase {
    
    func testEnvironmentValue() throws {
        let key = TestEnvKey()
        let sut = EmptyView().environment(\.testKey, key)
        XCTAssertNoThrow(try sut.inspect().emptyView())
        XCTAssertNoThrow(try sut.inspect().emptyView().environment(\.testKey))
        XCTAssertThrows(try EmptyView().inspect().emptyView().environment(\.testKey),
                        "EmptyView does not have 'environment(TestEnvKey)' modifier")
        let sut2 = EmptyView().environment(\.colorScheme, .light)
        XCTAssertEqual(try sut2.inspect().emptyView().environment(\.colorScheme), .light)
    }

    func testClosureEnvironmentValue() {
        let value: (_ value: String) -> Bool = { value in value == "hello world" }
        let sut = EmptyView().environment(\.testHandlerClosure, value)
        XCTAssertNoThrow(try sut.inspect().emptyView())
        XCTAssertNoThrow(try sut.inspect().emptyView().environment(\.testHandlerClosure))
        XCTAssertThrows(try EmptyView().inspect().emptyView().environment(\.testHandlerClosure),
                        "EmptyView does not have 'environment((String) -> Bool)' modifier")
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

private struct TestHandlerClosureKey: EnvironmentKey {
    static var defaultValue: (_ value: String) -> Bool { { _ in true } }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension EnvironmentValues {

  fileprivate var testHandlerClosure: (_ value: String) -> Bool {
    get { self[TestHandlerClosureKey.self] }
    set { self[TestHandlerClosureKey.self] = newValue }
  }
}
