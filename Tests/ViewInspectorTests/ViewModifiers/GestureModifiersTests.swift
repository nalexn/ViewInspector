import XCTest
import SwiftUI
import Combine
@testable import ViewInspector

// MARK: - ViewGesturesTests

final class ViewGesturesTests: XCTestCase {
    
    @State private var floatValue: Float = 0
    
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
    
    func testGesture() throws {
        let sut = EmptyView().gesture(MagnificationGesture(), including: .subviews)
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testHighPriorityGesture() throws {
        let sut = EmptyView().highPriorityGesture(MagnificationGesture(), including: .subviews)
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testSimultaneousGesture() throws {
        let sut = EmptyView().simultaneousGesture(MagnificationGesture(), including: .subviews)
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    #endif
    
    #if os(watchOS)
    func testDigitalCrownRotation() throws {
        let sut = EmptyView().digitalCrownRotation(self.$floatValue)
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testDigitalCrownRotationExtended() throws {
        let sut = EmptyView().digitalCrownRotation(
            self.$floatValue, from: 5, through: 5, by: 5, sensitivity: .low,
            isContinuous: true, isHapticFeedbackEnabled: true)
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    #endif
}

// MARK: - ViewHitTestingTests

final class ViewHitTestingTests: XCTestCase {
    
    func testAllowsHitTesting() throws {
        let sut = EmptyView().allowsHitTesting(true)
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testContentShape() throws {
        let sut = EmptyView().contentShape(Capsule(), eoFill: true)
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
}
