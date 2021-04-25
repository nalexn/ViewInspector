import XCTest
import SwiftUI
import Combine
@testable import ViewInspector

// MARK: - Simultaneous Gesture Tests

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
final class SimultaneousGestureTests: XCTestCase {

    @GestureState var gestureState = CGSize.zero

    var magnificationMagnifyBy: CGFloat?
    var magnificationValue: MagnificationGesture.Value?

    var rotationAngle: Angle?
    var rotationValue: RotationGesture.Value?
    
    var simultaneousGestureValue: SimultaneousGesture<MagnificationGesture, RotationGesture>.Value?

    var gestureTests: CommonGestureTests<SimultaneousGesture<MagnificationGesture, RotationGesture>>?
    
    override func setUpWithError() throws {
        magnificationMagnifyBy = 10
        magnificationValue = MagnificationGesture.Value(magnifyBy: magnificationMagnifyBy!)
        rotationAngle = Angle(degrees: 90)
        rotationValue = RotationGesture.Value(angle: rotationAngle!)
        simultaneousGestureValue = SimultaneousGesture<MagnificationGesture, RotationGesture>.Value(
            first: magnificationValue,
            second: rotationValue)

        gestureTests = CommonGestureTests<SimultaneousGesture<MagnificationGesture, RotationGesture>>(
            testCase: self,
            gesture: SimultaneousGesture(MagnificationGesture(), RotationGesture()),
            value: simultaneousGestureValue!,
            assert: assertSimultaneousGestureValue)
    }
    
    override func tearDownWithError() throws {
        magnificationMagnifyBy = nil
        magnificationValue = nil
        rotationAngle = nil
        rotationValue = nil
        simultaneousGestureValue = nil
        gestureTests = nil
    }

    func testCreateSimultaneousGestureValue() throws {
        XCTAssertNotNil(magnificationValue)
        XCTAssertNotNil(rotationValue)
        let value = try XCTUnwrap(simultaneousGestureValue)
        assertSimultaneousGestureValue(value)
    }
    
    func testSimultaneousGestureGestureMask() throws {
        try gestureTests!.maskTest()
    }
    
    func testSimultaneousGestureGesture() throws {
        let sut = EmptyView().gesture(SimultaneousGesture(
            MagnificationGesture(minimumScaleDelta: 1.5),
            RotationGesture(minimumAngleDelta: Angle(degrees: 5))))
        let emptyView = try sut.inspect().emptyView()
        let gesture = try emptyView.gesture(SimultaneousGesture<MagnificationGesture, RotationGesture>.self)
        let simultaneousGesture = try gesture.gestureProperties()
        XCTAssertEqual(simultaneousGesture.first.minimumScaleDelta, 1.5)
        XCTAssertEqual(simultaneousGesture.second.minimumAngleDelta, Angle(degrees: 5))
    }
    
    func testSimultaneousGestureWithUpdatingModifier() throws {
        try gestureTests!.propertiesWithUpdatingModifierTest()
    }
    
    func testSimultaneousGestureWithOnChangedModifier() throws {
        try gestureTests!.propertiesWithOnChangedModifierTest()
    }
    
    func testSimultaneousGestureWithOnEndedModifier() throws {
        try gestureTests!.propertiesWithOnEndedModifierTest()
    }
    
    #if os(macOS)
    func testSimultaneousGestureWithModifiers() throws {
        try gestureTests!.propertiesWithModifiersTest()
    }
    #endif
    
    func testSimultaneousGestureFailure() throws {
        try gestureTests!.propertiesFailureTest()
    }
    
    func testSimultaneousGestureCallUpdating() throws {
        try gestureTests!.callUpdatingTest()
    }
    
    func testSimultaneousGestureCallUpdatingNotFirst() throws {
        try gestureTests!.callUpdatingNotFirstTest()
    }

    func testSimultaneousGestureCallUpdatingMultiple() throws {
        try gestureTests!.callUpdatingMultipleTest()
    }
    
    func testSimultaneousGestureCallUpdatingFailure() throws {
        try gestureTests!.callUpdatingFailureTest()
    }

    func testSimultaneousGestureCallOnEnded() throws {
        try gestureTests!.callOnEndedTest()
    }
    
    func testSimultaneousGestureCallOnEndedNotFirst() throws {
        try gestureTests!.callOnEndedNotFirstTest()
    }

    func testSimultaneousGestureCallOnEndedMultiple() throws {
        try gestureTests!.callOnEndedMultipleTest()
    }
    
    func testSimultaneousGestureCallOnEndedFailure() throws {
        try gestureTests!.callOnEndedFailureTest()
    }
    
    #if os(macOS)
    func testSimultaneousGestureModifiers() throws {
        try gestureTests!.modifiersTest()
    }
        
    func testSimultaneousGestureModifiersNotFirst() throws {
        try gestureTests!.modifiersNotFirstTest()
    }
    
    func testSimultaneousGestureModifiersMultiple() throws {
        try gestureTests!.modifiersMultipleTest()
    }
    
    func testSimultaneousGestureModifiersNone() throws {
        try gestureTests!.modifiersNoneTest()
    }
    #endif

    func assertSimultaneousGestureValue(
        _ value: SimultaneousGesture<MagnificationGesture, RotationGesture>.Value,
        file: StaticString = #filePath,
        line: UInt = #line) {
        XCTAssertEqual(value, simultaneousGestureValue, file: file, line: line)
    }
}
