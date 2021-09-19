import XCTest
import SwiftUI
import Combine
@testable import ViewInspector

// MARK: - Exclusive Gesture Tests

@available(iOS 13.0, macOS 10.15, *)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
final class ExclusiveGestureTests: XCTestCase {

    @GestureState var gestureState = CGSize.zero

    var magnificationMagnifyBy: CGFloat?
    var magnificationValue: MagnificationGesture.Value?

    var exclusiveGestureValue: ExclusiveGesture<MagnificationGesture, RotationGesture>.Value?
    
    var gestureTests: CommonGestureTests<ExclusiveGesture<MagnificationGesture, RotationGesture>>?

    override func setUpWithError() throws {
        magnificationMagnifyBy = 10
        magnificationValue = MagnificationGesture.Value(magnifyBy: magnificationMagnifyBy!)
        exclusiveGestureValue = ExclusiveGesture<MagnificationGesture, RotationGesture>.Value.first(magnificationValue!)

        gestureTests = CommonGestureTests<ExclusiveGesture<MagnificationGesture, RotationGesture>>(
            testCase: self,
            gesture: ExclusiveGesture(MagnificationGesture(), RotationGesture()),
            value: exclusiveGestureValue!,
            assert: assertExclusiveGestureValue)
    }
    
    override func tearDownWithError() throws {
        magnificationMagnifyBy = nil
        magnificationValue = nil
        exclusiveGestureValue = nil
    }

    func testCreateExclusiveGestureValue() throws {
        XCTAssertNotNil(magnificationValue)
        let value = try XCTUnwrap(exclusiveGestureValue)
        assertExclusiveGestureValue(value)
    }
    
    func testExclusiveGestureGestureMask() throws {
        try gestureTests!.maskTest()
    }
    
    func testExclusiveGestureGesture() throws {
        let sut = EmptyView().gesture(ExclusiveGesture(
            MagnificationGesture(minimumScaleDelta: 1.5),
            RotationGesture(minimumAngleDelta: Angle(degrees: 5))))
        let emptyView = try sut.inspect().emptyView()
        let gesture = try emptyView.gesture(ExclusiveGesture<MagnificationGesture, RotationGesture>.self)
        let exclusiveGesture = try gesture.actualGesture()
        XCTAssertEqual(exclusiveGesture.first.minimumScaleDelta, 1.5)
        XCTAssertEqual(exclusiveGesture.second.minimumAngleDelta, Angle(degrees: 5))
    }
    
    func testExclusiveGestureWithUpdatingModifier() throws {
        try gestureTests!.propertiesWithUpdatingModifierTest()
    }
    
    func testExclusiveGestureWithOnChangedModifier() throws {
        try gestureTests!.propertiesWithOnChangedModifierTest()
    }
    
    func testExclusiveGestureWithOnEndedModifier() throws {
        try gestureTests!.propertiesWithOnEndedModifierTest()
    }
    
    #if os(macOS)
    func testExclusiveGestureWithModifiers() throws {
        try gestureTests!.propertiesWithModifiersTest()
    }
    #endif
    
    func testExclusiveGestureFailure() throws {
        let type = "ExclusiveGesture<MagnificationGesture, RotationGesture>"
        try gestureTests!.propertiesFailureTest(type)
    }
    
    func testExclusiveGestureCallUpdating() throws {
        try gestureTests!.callUpdatingTest()
    }
    
    func testExclusiveGestureCallUpdatingNotFirst() throws {
        try gestureTests!.callUpdatingNotFirstTest()
    }

    func testExclusiveGestureCallUpdatingMultiple() throws {
        try gestureTests!.callUpdatingMultipleTest()
    }
    
    func testExclusiveGestureCallUpdatingFailure() throws {
        try gestureTests!.callUpdatingFailureTest()
    }

    func testExclusiveGestureCallOnEnded() throws {
        try gestureTests!.callOnEndedTest()
    }
    
    func testExclusiveGestureCallOnEndedNotFirst() throws {
        try gestureTests!.callOnEndedNotFirstTest()
    }

    func testExclusiveGestureCallOnEndedMultiple() throws {
        try gestureTests!.callOnEndedMultipleTest()
    }
    
    func testExclusiveGestureCallOnEndedFailure() throws {
        try gestureTests!.callOnEndedFailureTest()
    }
    
    #if os(macOS)
    func testExclusiveGestureModifiers() throws {
        try gestureTests!.modifiersTest()
    }
        
    func testExclusiveGestureModifiersNotFirst() throws {
        try gestureTests!.modifiersNotFirstTest()
    }
    
    func testExclusiveGestureModifiersMultiple() throws {
        try gestureTests!.modifiersMultipleTest()
    }
    
    func testExclusiveGestureModifiersNone() throws {
        try gestureTests!.modifiersNoneTest()
    }
    #endif

    func assertExclusiveGestureValue(
        _ value: ExclusiveGesture<MagnificationGesture, RotationGesture>.Value,
        file: StaticString = #filePath,
        line: UInt = #line) {
        XCTAssertEqual(value, exclusiveGestureValue, file: file, line: line)
    }
}
