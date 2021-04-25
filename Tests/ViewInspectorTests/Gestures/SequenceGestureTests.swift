import XCTest
import SwiftUI
import Combine
@testable import ViewInspector

// MARK: - Sequence Gesture Tests

@available(iOS 13.0, macOS 10.15, *)
@available(tvOS, unavailable)
final class SequenceGestureTests: XCTestCase {

    @GestureState var gestureState = CGSize.zero

    var magnificationMagnifyBy: CGFloat?
    var magnificationValue: MagnificationGesture.Value?

    var sequenceGestureValue: SequenceGesture<MagnificationGesture, RotationGesture>.Value?

    var gestureTests: CommonGestureTests<SequenceGesture<MagnificationGesture, RotationGesture>>?
    
    override func setUpWithError() throws {
        magnificationMagnifyBy = 10
        magnificationValue = MagnificationGesture.Value(magnifyBy: magnificationMagnifyBy!)
        sequenceGestureValue = SequenceGesture<MagnificationGesture, RotationGesture>.Value.first(magnificationValue!)

        gestureTests = CommonGestureTests<SequenceGesture<MagnificationGesture, RotationGesture>>(
            testCase: self,
            gesture: SequenceGesture(MagnificationGesture(), RotationGesture()),
            value: sequenceGestureValue!,
            assert: assertSequenceGestureValue)
    }
    
    override func tearDownWithError() throws {
        magnificationMagnifyBy = nil
        magnificationValue = nil
        sequenceGestureValue = nil
        gestureTests = nil
    }

    func testCreateSequenceGestureValue() throws {
        XCTAssertNotNil(magnificationValue)
        let value = try XCTUnwrap(sequenceGestureValue)
        assertSequenceGestureValue(value)
    }
    
    func testSequenceGestureGestureMask() throws {
        try gestureTests!.maskTest()
    }
    
    func testSequenceGestureGesture() throws {
        let sut = EmptyView().gesture(SequenceGesture(
            MagnificationGesture(minimumScaleDelta: 1.5),
            RotationGesture(minimumAngleDelta: Angle(degrees: 5))))
        let emptyView = try sut.inspect().emptyView()
        let gesture = try emptyView.gesture(SequenceGesture<MagnificationGesture, RotationGesture>.self)
        let sequenceGesture = try gesture.actualGesture()
        XCTAssertEqual(sequenceGesture.first.minimumScaleDelta, 1.5)
        XCTAssertEqual(sequenceGesture.second.minimumAngleDelta, Angle(degrees: 5))
    }

    func testSequenceGestureWithUpdatingModifier() throws {
        try gestureTests!.propertiesWithUpdatingModifierTest()
    }
    
    func testSequenceGestureWithOnChangedModifier() throws {
        try gestureTests!.propertiesWithOnChangedModifierTest()
    }
    
    func testSequenceGestureWithOnEndedModifier() throws {
        try gestureTests!.propertiesWithOnEndedModifierTest()
    }
    
    #if os(macOS)
    func testSequenceGestureWithModifiers() throws {
        try gestureTests!.propertiesWithModifiersTest()
    }
    #endif
    
    func testSequenceGestureFailure() throws {
        let type = "SequenceGesture<MagnificationGesture, RotationGesture>"
        try gestureTests!.propertiesFailureTest(type)
    }
    
    func testSequenceGestureCallUpdating() throws {
        try gestureTests!.callUpdatingTest()
    }
    
    func testSequenceGestureCallUpdatingNotFirst() throws {
        try gestureTests!.callUpdatingNotFirstTest()
    }

    func testSequenceGestureCallUpdatingMultiple() throws {
        try gestureTests!.callUpdatingMultipleTest()
    }
    
    func testSequenceGestureCallUpdatingFailure() throws {
        try gestureTests!.callUpdatingFailureTest()
    }

    func testSequenceGestureCallOnEnded() throws {
        try gestureTests!.callOnEndedTest()
    }
    
    func testSequenceGestureCallOnEndedNotFirst() throws {
        try gestureTests!.callOnEndedNotFirstTest()
    }

    func testSequenceGestureCallOnEndedMultiple() throws {
        try gestureTests!.callOnEndedMultipleTest()
    }
    
    func testSequenceGestureCallOnEndedFailure() throws {
        try gestureTests!.callOnEndedFailureTest()
    }
    
    #if os(macOS)
    func testSequenceGestureModifiers() throws {
        try gestureTests!.modifiersTest()
    }
        
    func testSequenceGestureModifiersNotFirst() throws {
        try gestureTests!.modifiersNotFirstTest()
    }
    
    func testSequenceGestureModifiersMultiple() throws {
        try gestureTests!.modifiersMultipleTest()
    }
    
    func testSequenceGestureModifiersNone() throws {
        try gestureTests!.modifiersNoneTest()
    }
    #endif

    func assertSequenceGestureValue(
        _ value: SequenceGesture<MagnificationGesture, RotationGesture>.Value,
        file: StaticString = #filePath,
        line: UInt = #line) {
        XCTAssertEqual(value, sequenceGestureValue, file: file, line: line)
    }
}
