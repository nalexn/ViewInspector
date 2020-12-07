import XCTest
import Combine
import SwiftUI

@testable import ViewInspector

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
final class TraverseTests: XCTestCase {
    
    func testR() throws {
        let view = AnyView(Group {
            Text("123")
            EmptyView()
                .padding()
                .overlay(HStack {
                    EmptyView()
                    TestView().padding()
                })
           })
        let sut = try view.inspect().traverse().hStack().emptyView(0).pathToRoot
        XCTAssertEqual(sut, "")
//        XCTAssertEqual(try sut.string(), "123")
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
private struct TestView: View {
    
    var body: some View {
        Group {
            Text("Test")
        }
    }
}
