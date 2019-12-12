import XCTest
import SwiftUI
import Combine
@testable import ViewInspector

final class SubscriptionViewTests: XCTestCase {
    
    let publisher = PassthroughSubject<Bool, Never>()
    
    func testEnclosedView() throws {
        let view = SubscriptionTestView(publisher: publisher.eraseToAnyPublisher())
        let string = try view.inspect().text().string()
        XCTAssertEqual(string, "XYZ")
    }
}

private struct SubscriptionTestView: View, Inspectable {
    
    @State var flag: Bool = false
    let publisher: AnyPublisher<Bool, Never>
    
    var body: some View {
        Text(flag ? "ABC" : "XYZ")
            .onReceive(publisher) { value in
                self.flag = value
            }
    }
}
