import XCTest
import SwiftUI
import Combine
@testable import ViewInspector

// MARK: - Drag Gesture Tests

@available(iOS 13.0, macOS 10.15, *)
@available(tvOS, unavailable)
final class DragGestureTests: XCTestCase {

    var dragTime: Date?
    var dragLocation: CGPoint?
    var dragStartLocation: CGPoint?
    var dragVelocity: CGVector?
    var dragValue: DragGesture.Value?
    
    var gestureTests: CommonGestureTests<DragGesture>?
    
    override func setUpWithError() throws {
        dragTime = Date()
        dragLocation = CGPoint(x: 100, y: 100)
        dragStartLocation = CGPoint(x: 50, y: 50)
        dragVelocity = CGVector(dx: 8, dy: 8)
        
        dragValue = DragGesture.Value(
            time: dragTime!,
            location: dragLocation!,
            startLocation: dragStartLocation!,
            velocity: dragVelocity!)
        
        gestureTests = CommonGestureTests<DragGesture>(testCase: self,
                                                       gesture: DragGesture(),
                                                       value: dragValue!,
                                                       assert: assertDragValue)
    }
    
    override func tearDownWithError() throws {
        dragTime = nil
        dragLocation = nil
        dragStartLocation = nil
        dragVelocity = nil
        dragValue = nil
        gestureTests = nil
    }

    func testCreateDragGestureValue() throws {
        XCTAssertNotNil(dragTime)
        XCTAssertNotNil(dragLocation)
        XCTAssertNotNil(dragStartLocation)
        XCTAssertNotNil(dragVelocity)
        let value = try XCTUnwrap(dragValue)
        assertDragValue(value)
    }
    
    func testDragGestureMask() throws {
        try gestureTests!.maskTest()
    }
    
    func testDragGesture() throws {
        let sut = EmptyView()
            .gesture(DragGesture(minimumDistance: 1, coordinateSpace: .global))
        let dragGesture = try sut.inspect().emptyView().gesture(DragGesture.self).gestureProperties()
        XCTAssertEqual(dragGesture.minimumDistance, 1)
        XCTAssertEqual(dragGesture.coordinateSpace, .global)
    }
    
    func testDragGestureWithUpdatingModifier() throws {
        try gestureTests!.propertiesWithUpdatingModifierTest()
    }
    
    func testDragGestureWithOnChangedModifier() throws {
        try gestureTests!.propertiesWithOnChangedModifierTest()
    }
    
    func testDragGestureWithOnEndedModifier() throws {
        try gestureTests!.propertiesWithOnEndedModifierTest()
    }
    
    #if os(macOS)
    func testDragGestureWithModifiers() throws {
        try gestureTests!.propertiesWithModifiersTest()
    }
    #endif
    
    func testDragGestureFailure() throws {
        try gestureTests!.propertiesFailureTest("DragGesture")
    }

    func testDragGestureCallUpdating() throws {
        try gestureTests!.callUpdatingTest()
    }
    
    func testDragGestureCallUpdatingNotFirst() throws {
        try gestureTests!.callUpdatingNotFirstTest()
    }

    func testDragGestureCallUpdatingMultiple() throws {
        try gestureTests!.callUpdatingMultipleTest()
    }
    
    func testDragGestureCallUpdatingFailure() throws {
        try gestureTests!.callUpdatingFailureTest()
    }
    
    func testDragGestureCallOnChanged() throws {
        try gestureTests!.callOnChangedTest()
    }
    
    func testDragGestureCallOnChangedNotFirst() throws {
        try gestureTests!.callOnChangedNotFirstTest()
    }
    
    func testDragGestureCallOnChangedMultiple() throws {
        try gestureTests!.callOnChangedMultipleTest()
    }
    
    func testDragGestureCallOnChangedFailure() throws {
        try gestureTests!.callOnChangedFailureTest()
    }
    
    func testDragGestureCallOnEnded() throws {
        try gestureTests!.callOnEndedTest()
    }
    
    func testDragGestureCallOnEndedNotFirst() throws {
        try gestureTests!.callOnEndedNotFirstTest()
    }

    func testDragGestureCallOnEndedMultiple() throws {
        try gestureTests!.callOnEndedMultipleTest()
    }
    
    func testDragGestureCallOnEndedFailure() throws {
        try gestureTests!.callOnEndedFailureTest()
    }
    
    #if os(macOS)
    func testDragGestureModifiers() throws {
        try gestureTests!.modifiersTest()
    }
        
    func testDragGestureModifiersNotFirst() throws {
        try gestureTests!.modifiersNotFirstTest()
    }
    
    func testDragGestureModifiersMultiple() throws {
        try gestureTests!.modifiersMultipleTest()
    }
    
    func testDragGestureModifiersNone() throws {
        try gestureTests!.modifiersNoneTest()
    }
    #endif

    func assertDragValue(
        _ value: DragGesture.Value,
        file: StaticString = #filePath,
        line: UInt = #line) {
        XCTAssertEqual(value.location, dragLocation, file: file, line: line)
        XCTAssertEqual(value.predictedEndLocation, CGPoint(x: 102, y: 102), file: file, line: line)
        XCTAssertEqual(value.predictedEndTranslation, CGSize(width: 52, height: 52), file: file, line: line)
        XCTAssertEqual(value.startLocation, dragStartLocation, file: file, line: line)
        XCTAssertEqual(value.time, dragTime, file: file, line: line)
        XCTAssertEqual(value.translation, CGSize(width: 50, height: 50), file: file, line: line)
    }
}
