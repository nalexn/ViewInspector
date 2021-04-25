import XCTest
import SwiftUI
import Combine
@testable import ViewInspector

// MARK: - ViewHitTestingTests

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
final class ViewHitTestingTests: XCTestCase {
    
    func testAllowsHitTesting() throws {
        let sut = EmptyView().allowsHitTesting(true)
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testAllowsHitTestingInspection() throws {
        let sut = try EmptyView().allowsHitTesting(false)
            .inspect().emptyView().allowsHitTesting()
        XCTAssertFalse(sut)
    }
    
    func testContentShape() throws {
        let sut = EmptyView().contentShape(Capsule(), eoFill: true)
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testContentShapeInspection() throws {
        let box = ContentShape(shape: Capsule(), eoFill: true)
        let sut = try EmptyView().contentShape(box.shape, eoFill: box.eoFill)
            .inspect().emptyView().contentShape(Capsule.self)
        XCTAssertEqual(sut, box)
    }
    
    func testContentShapeInspectionError() throws {
        let box = ContentShape(shape: Capsule(), eoFill: true)
        let sut = try EmptyView().contentShape(box.shape, eoFill: box.eoFill).inspect().emptyView()
        XCTAssertThrows(
            try sut.contentShape(Circle.self),
            "Type mismatch: Capsule is not Circle")
    }
}
