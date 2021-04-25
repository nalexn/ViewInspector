import XCTest
import SwiftUI
import Combine
@testable import ViewInspector

// MARK: - Magnification Gesture Tests

@available(iOS 13.0, macOS 10.15, *)
@available(tvOS, unavailable)
final class MagnificationGestureTests: XCTestCase {

    var magnificationMagnifyBy: CGFloat?
    var magnificationValue: MagnificationGesture.Value?
    
    var gestureTests: CommonGestureTests<MagnificationGesture>?
    
    override func setUpWithError() throws {
        magnificationMagnifyBy = 10
        magnificationValue = MagnificationGesture.Value(magnifyBy: magnificationMagnifyBy!)
        
        gestureTests = CommonGestureTests<MagnificationGesture>(testCase: self,
                                                                gesture: MagnificationGesture(),
                                                                value: magnificationValue!,
                                                                assert: assertMagnificationValue)
    }
    
    override func tearDownWithError() throws {
        magnificationMagnifyBy = nil
        magnificationValue = nil
        gestureTests = nil
    }

    func testCreateMagnificationGestureValue() throws {
        XCTAssertNotNil(magnificationMagnifyBy)
        let value = try XCTUnwrap(magnificationValue)
        assertMagnificationValue(value)
    }
    
    func testMagnificationGestureMask() throws {
        try gestureTests!.maskTest()
    }
    
    func testMagnificationGesture() throws {
        let sut = EmptyView()
            .gesture(MagnificationGesture(minimumScaleDelta: 1.5))
        let magnificationGesture = try sut.inspect().emptyView().gesture(MagnificationGesture.self).actualGesture()
        XCTAssertEqual(magnificationGesture.minimumScaleDelta, 1.5)
    }

    func testMagnificationGestureWithUpdatingModifier() throws {
        try gestureTests!.propertiesWithUpdatingModifierTest()
    }
    
    func testMagnificationGestureWithOnChangedModifier() throws {
        try gestureTests!.propertiesWithOnChangedModifierTest()
    }
    
    func testMagnificationGestureWithOnEndedModifier() throws {
        try gestureTests!.propertiesWithOnEndedModifierTest()
    }
    
    #if os(macOS)
    func testMagnificationGestureWithModifiers() throws {
        try gestureTests!.propertiesWithModifiersTest()
    }
    #endif
    
    func testMagnificationGestureFailure() throws {
        try gestureTests!.propertiesFailureTest("MagnificationGesture")
    }

    func testMagnificationGestureCallUpdating() throws {
        try gestureTests!.callUpdatingTest()
    }
    
    func testMagnificationGestureCallUpdatingNotFirst() throws {
        try gestureTests!.callUpdatingNotFirstTest()
    }

    func testMagnificationGestureCallUpdatingMultiple() throws {
        try gestureTests!.callUpdatingMultipleTest()
    }
    
    func testMagnificationGestureCallUpdatingFailure() throws {
        try gestureTests!.callUpdatingFailureTest()
    }
    
    func testMagnificationGestureCallOnChanged() throws {
        try gestureTests!.callOnChangedTest()
    }
    
    func testMagnificationGestureCallOnChangedNotFirst() throws {
        try gestureTests!.callOnChangedNotFirstTest()
    }
    
    func testMagnificationGestureCallOnChangedMultiple() throws {
        try gestureTests!.callOnChangedMultipleTest()
    }
    
    func testMagnificationGestureCallOnChangedFailure() throws {
        try gestureTests!.callOnChangedFailureTest()
    }
    
    func testMagnificationGestureCallOnEnded() throws {
        try gestureTests!.callOnEndedTest()
    }
    
    func testMagnificationGestureCallOnEndedNotFirst() throws {
        try gestureTests!.callOnEndedNotFirstTest()
    }

    func testMagnificationGestureCallOnEndedMultiple() throws {
        try gestureTests!.callOnEndedMultipleTest()
    }
    
    func testMagnificationGestureCallOnEndedFailure() throws {
        try gestureTests!.callOnEndedFailureTest()
    }
    
    #if os(macOS)
    func testMagnificationGestureModifiers() throws {
        try gestureTests!.modifiersTest()
    }
        
    func testMagnificationGestureModifiersNotFirst() throws {
        try gestureTests!.modifiersNotFirstTest()
    }
    
    func testMagnificationGestureModifiersMultiple() throws {
        try gestureTests!.modifiersMultipleTest()
    }
    
    func testMagnificationGestureModifiersNone() throws {
        try gestureTests!.modifiersNoneTest()
    }
    #endif

    func assertMagnificationValue(
        _ value: MagnificationGesture.Value,
        file: StaticString = #filePath,
        line: UInt = #line) {
        XCTAssertEqual(value, magnificationMagnifyBy!)
    }
}
