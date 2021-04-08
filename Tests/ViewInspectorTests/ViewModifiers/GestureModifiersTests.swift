import XCTest
import SwiftUI
import Combine
@testable import ViewInspector

// MARK: - ViewGesturesTests

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
final class ViewGesturesTests: XCTestCase {
    
    #if !os(tvOS)
    func testOnTapGesture() throws {
        let sut = EmptyView().onTapGesture(count: 5, perform: { })
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testOnTapGestureInspection() throws {
        let exp = XCTestExpectation(description: "onAppear")
        let sut = EmptyView().onTapGesture {
            exp.fulfill()
        }.onLongPressGesture { }
        try sut.inspect().emptyView().callOnTapGesture()
        wait(for: [exp], timeout: 0.1)
    }
    
    func testOnLongPressGesture() throws {
        let sut = EmptyView().onLongPressGesture { }
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testOnLongPressGestureInspection() throws {
        let exp = XCTestExpectation(description: "onLongPressGesture")
        let sut = EmptyView().onLongPressGesture {
            exp.fulfill()
        }.onTapGesture { }
        try sut.inspect().emptyView().callOnLongPressGesture()
        wait(for: [exp], timeout: 0.1)
    }
    #endif
}

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
