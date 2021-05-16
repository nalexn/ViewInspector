import XCTest
import SwiftUI
@testable import ViewInspector

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
final class TransitiveModifiersTests: XCTestCase {
    
    func testHiddenTransitivity() throws {
        let sut = try HittenTestView().inspect()
        XCTAssertFalse(try sut.find(text: "abc").isHidden())
        XCTAssertTrue(try sut.find(text: "123").isHidden())
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
private struct HittenTestView: View, Inspectable {
    var body: some View {
        VStack {
            Text("abc")
            HStack {
                Text("123")
            }.hidden()
        }
    }
}
