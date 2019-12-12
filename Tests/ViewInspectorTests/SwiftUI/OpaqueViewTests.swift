import XCTest
import SwiftUI
@testable import ViewInspector

final class OpaqueViewTests: XCTestCase {
    
    func testOpaqueAnyView() throws {
        let view = Text("Test").padding()
        let string = try view.inspect().text().string()
        XCTAssertEqual(string, "Test")
    }
    
    func testOpaqueInspectableView() throws {
        let view = InspectableTestView().padding()
        let string = try view.inspect(InspectableTestView.self).text().string()
        XCTAssertEqual(string, "Test")
    }
    
    func testOpaqueEnvInspectableView() throws {
        let view = EnvInspectableTestView().padding()
        let state = EnvInspectableTestView.State()
        let string = try view.inspect(EnvInspectableTestView.self, state).text().string()
        XCTAssertEqual(string, "Test")
    }
    
    func testNonInspectableView() throws {
        let view = NonInspectableView()
        XCTAssertThrowsError(try view.inspect())
    }
    
    func testInspectableTestViews() {
        XCTAssertNoThrow(InspectableTestView().body)
        XCTAssertNoThrow(EnvInspectableTestView().body)
    }
}

private struct InspectableTestView: View, Inspectable {
    var body: some View {
        Text("Test")
    }
}

private struct EnvInspectableTestView: View, InspectableWithEnvObject {
    
    var body: Body {
        content(State())
    }
    
    func content(_ state: State) -> some View {
        Text("Test")
    }
    
    class State: ObservableObject { }
}

private struct NonInspectableView: View {
    var body: some View {
        Text("Test")
    }
}
