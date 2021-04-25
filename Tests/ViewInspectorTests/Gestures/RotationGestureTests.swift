import XCTest
import SwiftUI
import Combine
@testable import ViewInspector

// MARK: - Retotation Gesture Tests

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
final class RotationGestureTests: XCTestCase {

    var rotationAngle: Angle?
    var rotationValue: RotationGesture.Value?
    
    var gestureTests: CommonGestureTests<RotationGesture>?
    
    override func setUpWithError() throws {
        rotationAngle = Angle(degrees: 90)
        rotationValue = RotationGesture.Value(angle: rotationAngle!)
        
        gestureTests = CommonGestureTests<RotationGesture>(testCase: self,
                                                           gesture: RotationGesture(),
                                                           value: rotationValue!,
                                                           assert: assertRotationValue)
    }
    
    override func tearDownWithError() throws {
        rotationAngle = nil
        rotationValue = nil
        gestureTests = nil
    }

    func testCreateRotationGestureValue() throws {
        XCTAssertNotNil(rotationAngle)
        let value = try XCTUnwrap(rotationValue)
        assertRotationValue(value)
    }
    
    func testRotationGestureMask() throws {
        try gestureTests!.maskTest()
    }
    
    func testRotationGesture() throws {
        let sut = EmptyView().gesture(RotationGesture(minimumAngleDelta: Angle(degrees: 5)))
        let rotationGesture = try sut.inspect().emptyView().gesture(RotationGesture.self).gestureProperties()
        XCTAssertEqual(rotationGesture.minimumAngleDelta, Angle(degrees: 5))
    }
    
    func testRotationGestureWithUpdatingModifier() throws {
        try gestureTests!.propertiesWithUpdatingModifierTest()
    }
    
    func testRotationGestureWithOnChangedModifier() throws {
        try gestureTests!.propertiesWithOnChangedModifierTest()
    }
    
    func testRotationGestureWithOnEndedModifier() throws {
        try gestureTests!.propertiesWithOnEndedModifierTest()
    }
    
    #if os(macOS)
    func testRotationGestureWithModifiers() throws {
        try gestureTests!.propertiesWithModifiersTest()
    }
    #endif
    
    func testRotationGestureFailure() throws {
        try gestureTests!.propertiesFailureTest("RotationGesture")
    }

    func testRotationGestureCallUpdating() throws {
        try gestureTests!.callUpdatingTest()
    }
    
    func testRotationGestureCallUpdatingNotFirst() throws {
        try gestureTests!.callUpdatingNotFirstTest()
    }

    func testRotationGestureCallUpdatingMultiple() throws {
        try gestureTests!.callUpdatingMultipleTest()
    }
    
    func testRotationGestureCallUpdatingFailure() throws {
        try gestureTests!.callUpdatingFailureTest()
    }
    
    func testRotationGestureCallOnChanged() throws {
        try gestureTests!.callOnChangedTest()
    }
    
    func testRotationGestureCallOnChangedNotFirst() throws {
        try gestureTests!.callOnChangedNotFirstTest()
    }
    
    func testRotationGestureCallOnChangedMultiple() throws {
        try gestureTests!.callOnChangedMultipleTest()
    }
    
    func testRotationGestureCallOnChangedFailure() throws {
        try gestureTests!.callOnChangedFailureTest()
    }
    
    func testRotationGestureCallOnEnded() throws {
        try gestureTests!.callOnEndedTest()
    }
    
    func testRotationGestureCallOnEndedNotFirst() throws {
        try gestureTests!.callOnEndedNotFirstTest()
    }

    func testRotationGestureCallOnEndedMultiple() throws {
        try gestureTests!.callOnEndedMultipleTest()
    }
    
    func testRotationGestureCallOnEndedFailure() throws {
        try gestureTests!.callOnEndedFailureTest()
    }
    
    #if os(macOS)
    func testRotationGestureModifiers() throws {
        try gestureTests!.modifiersTest()
    }
        
    func testRotationGestureModifiersNotFirst() throws {
        try gestureTests!.modifiersNotFirstTest()
    }
    
    func testRotationGestureModifiersMultiple() throws {
        try gestureTests!.modifiersMultipleTest()
    }
    
    func testRotationGestureModifiersNone() throws {
        try gestureTests!.modifiersNoneTest()
    }
    #endif

    func assertRotationValue(
        _ value: RotationGesture.Value,
        file: StaticString = #filePath,
        line: UInt = #line) {
        XCTAssertEqual(value, rotationAngle!)
    }
}
