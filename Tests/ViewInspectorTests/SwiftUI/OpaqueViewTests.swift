import XCTest
import SwiftUI
@testable import ViewInspector

final class OpaqueViewTests: XCTestCase {
    
    func testOpaqueStandardView() throws {
        let view = Text("Test").padding()
        let sut = try view.inspect().text()
        XCTAssertEqual(try sut.string(), "Test")
        XCTAssertEqual(sut.content.modifiers.count, 1)
    }
    
    func testOpaqueInspectableView() throws {
        let view = InspectableTestView().padding()
        let sut = try view.inspect().view(InspectableTestView.self).text()
        XCTAssertEqual(try sut.string(), "Test")
        XCTAssertEqual(sut.content.modifiers.count, 0)
    }
    
    func testOpaqueEnvInspectableView() throws {
        let view = EnvInspectableTestView()
            .environmentObject(EnvInspectableTestView.State())
            .padding()
        let sut = try view.inspect().view(EnvInspectableTestView.self).text()
        XCTAssertEqual(try sut.string(), "Test")
        XCTAssertEqual(sut.content.modifiers.count, 0)
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

private struct EnvInspectableTestView: View, Inspectable {
    
    var body: some View {
        body(State())
    }
    
    func body(_ state: State) -> some View {
        Text("Test")
    }
    
    class State: ObservableObject { }
}
