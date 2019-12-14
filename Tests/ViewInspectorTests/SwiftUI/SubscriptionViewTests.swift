import XCTest
import SwiftUI
import Combine
@testable import ViewInspector

final class SubscriptionViewTests: XCTestCase {
    
    func testEnclosedView() throws {
        let subject = PassthroughSubject<Void, Never>()
        let view = SubscriptionTestView(publisher: subject.eraseToAnyPublisher())
        let string = try view.inspect().text().string()
        XCTAssertEqual(string, "XYZ")
    }
    
    func testRetainsModifiers() throws {
        let subject = PassthroughSubject<Void, Never>()
        let view = Text("Test")
            .padding()
            .onReceive(subject, perform: { })
            .padding().padding()
        let sut = try view.inspect().text()
        XCTAssertEqual(sut.content.modifiers.count, 3)
    }
}

private struct SubscriptionTestView: View, Inspectable {
    
    let publisher: AnyPublisher<Void, Never>
    
    var body: some View {
        Text("XYZ")
            .onReceive(publisher) { _ in }
    }
}
