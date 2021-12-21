import XCTest
import SwiftUI
@testable import ViewInspector

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
final class NestedModifiersTests: XCTestCase {
    
    func testInspectionNestedSameModifiersReturnsFirstApplied() throws {
        let view = EmptyView()
            .border(Color.red, width: 2)
            .border(Color.blue, width: 3)
        let sut = try view.inspect().emptyView().border(Color.self)
        XCTAssertEqual(sut.shapeStyle, .red)
        XCTAssertEqual(sut.width, 2)
    }
}
