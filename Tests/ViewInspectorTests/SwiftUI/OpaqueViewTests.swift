import XCTest
import SwiftUI
@testable import ViewInspector

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
final class OpaqueViewTests: XCTestCase {
    
    func testOpaqueStandardView() throws {
        let view = Text("Test").padding()
        let sut = try view.inspect().text()
        XCTAssertEqual(try sut.string(), "Test")
        XCTAssertEqual(sut.content.medium.viewModifiers.count, 1)
    }
    
    func testOpaqueInspectableView() throws {
        let view = InspectableTestView().padding()
        let sut = try view.inspect().view(InspectableTestView.self).text()
        XCTAssertEqual(try sut.string(), "Test")
        XCTAssertEqual(sut.content.medium.viewModifiers.count, 0)
    }
    
    func testOpaqueEnvInspectableView() throws {
        let view = EnvInspectableTestView()
            .environmentObject(EnvInspectableTestView.State())
            .padding()
        let sut = try view.inspect().view(EnvInspectableTestView.self).text()
        XCTAssertEqual(try sut.string(), "Test")
        XCTAssertEqual(sut.content.medium.viewModifiers.count, 0)
    }
    
    func testInspectableTestViews() {
        XCTAssertNoThrow(InspectableTestView().body)
        XCTAssertNoThrow(EnvInspectableTestView().body)
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
private struct InspectableTestView: View, InspectableProtocol {
    var body: some View {
        Text("Test")
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
private struct EnvInspectableTestView: View, InspectableProtocol {
    
    var body: some View {
        body(State())
    }
    
    func body(_ state: State) -> some View {
        Text("Test")
    }
    
    class State: ObservableObject { }
}
