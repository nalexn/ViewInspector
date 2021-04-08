import XCTest
import SwiftUI
@testable import ViewInspector

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
final class GestureTests: XCTestCase {

    @GestureState var gestureState = CGSize.zero
    
    var dragTime: Date?
    var dragLocation: CGPoint?
    var dragStartLocation: CGPoint?
    var dragVelocity: CGVector?
    var dragValue: DragGesture.Value?
    
    var longPressFinished: Bool?
    var longPressValue: LongPressGesture.Value?
    
    var magnificationMagnifyBy: CGFloat?
    var magnificationValue: MagnificationGesture.Value?
    
    var rotationAngle: Angle?
    var rotationValue: RotationGesture.Value?
    
    var tapValue: TapGesture.Value?
    
    var exclusiveGestureValue: ExclusiveGesture<MagnificationGesture, RotationGesture>.Value?
    
    var sequenceGestureValue: SequenceGesture<MagnificationGesture, RotationGesture>.Value?
    
    var simultaneousGestureValue: SimultaneousGesture<MagnificationGesture, RotationGesture>.Value?
    
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
        
        longPressFinished = false
        longPressValue = LongPressGesture.Value(finished: longPressFinished!)
        
        magnificationMagnifyBy = 10
        magnificationValue = MagnificationGesture.Value(magnifyBy: magnificationMagnifyBy!)
        
        rotationAngle = Angle(degrees: 90)
        rotationValue = RotationGesture.Value(angle: rotationAngle!)
        
        tapValue = TapGesture.Value()
        
        exclusiveGestureValue = ExclusiveGesture<MagnificationGesture, RotationGesture>.Value.first(magnificationValue!)
        
        sequenceGestureValue = SequenceGesture<MagnificationGesture, RotationGesture>.Value.first(magnificationValue!)

        simultaneousGestureValue = SimultaneousGesture<MagnificationGesture, RotationGesture>.Value(
            first: magnificationValue,
            second: rotationValue)
    }
    
    override func tearDownWithError() throws {
        dragTime = nil
        dragLocation = nil
        dragStartLocation = nil
        dragVelocity = nil
        dragValue = nil
        
        longPressFinished = nil
        longPressValue = nil
        
        magnificationMagnifyBy = nil
        magnificationValue = nil
        
        rotationAngle = nil
        rotationValue = nil
        
        tapValue = nil
        
        exclusiveGestureValue = nil
        
        sequenceGestureValue = nil
        
        simultaneousGestureValue = nil
    }

    // MARK: - Gesture Modifier Tests
    
    func testGesture() throws {
        let sut = EmptyView().gesture(DragGesture())
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testGestureDoesNotBlock() throws {
        let sut = EmptyView().gesture(DragGesture()).padding(100)
        XCTAssertEqual(try sut.inspect().emptyView().padding(.top), 100)
    }

    func testGestureInspection() throws {
        let sut = EmptyView().gesture(DragGesture())
        XCTAssertNoThrow(try sut.inspect().emptyView().gesture(DragGesture.self))
    }
    
    func testGestureInspectionFailureDueToNoModifier() throws {
        let sut = EmptyView()
        XCTAssertThrowsError(try sut.inspect().emptyView().gesture(DragGesture.self))
    }
    
    func testGestureInspectionFailureDueToTypeMismatch() throws {
        let sut = EmptyView().gesture(LongPressGesture())
        XCTAssertThrowsError(try sut.inspect().emptyView().gesture(DragGesture.self))
    }
    
    func testGestureInspectionWithIndex1() throws {
        let sut = EmptyView().gesture(DragGesture()).gesture(LongPressGesture())
        XCTAssertNoThrow(try sut.inspect().emptyView().gesture(DragGesture.self, 0))
        XCTAssertNoThrow(try sut.inspect().emptyView().gesture(LongPressGesture.self, 1))
    }
    
    func testGestureInspectionWithIndex2() throws {
        let sut = EmptyView().gesture(DragGesture()).highPriorityGesture(TapGesture()).gesture(LongPressGesture())
        XCTAssertNoThrow(try sut.inspect().emptyView().gesture(DragGesture.self, 0))
        XCTAssertNoThrow(try sut.inspect().emptyView().gesture(LongPressGesture.self, 1))
    }
    
    func testGestureInspectionWithIndexFailureDueToNoModifier() throws {
        let sut = EmptyView().gesture(DragGesture()).gesture(LongPressGesture())
        XCTAssertThrowsError(try sut.inspect().emptyView().gesture(DragGesture.self, 2))
    }
    
    func testGestureInspectionWithIndexFailureDueToTypeMismatch() throws {
        let sut = EmptyView().gesture(DragGesture()).gesture(LongPressGesture())
        XCTAssertThrowsError(try sut.inspect().emptyView().gesture(LongPressGesture.self, 0))
    }
    
    func testGestureInspectionPathToRoot() throws {
        let sut = EmptyView().padding(100).gesture(DragGesture())
        XCTAssertEqual(try sut.inspect().emptyView().gesture(DragGesture.self).pathToRoot, "emptyView().gesture(DragGesture.self, 0)")
    }
    
    func testGestureInspectionWithIndexPathToRoot() throws {
        let sut = EmptyView().padding(100).gesture(DragGesture()).gesture(LongPressGesture())
        XCTAssertEqual(try sut.inspect().emptyView().gesture(LongPressGesture.self, 1).pathToRoot, "emptyView().gesture(LongPressGesture.self, 1)")
    }

    // MARK: - High Priority Gesture Modifier Tests
    
    func testHighPriorityGesture() throws {
        let sut = EmptyView().highPriorityGesture(DragGesture())
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testHighPriorityGestureDoesNotBlock() throws {
        let sut = EmptyView().highPriorityGesture(DragGesture()).padding(100)
        XCTAssertEqual(try sut.inspect().emptyView().padding(.top), 100)
    }

    func testHighPriorityGestureInspection() throws {
        let sut = EmptyView().highPriorityGesture(DragGesture())
        XCTAssertNoThrow(try sut.inspect().emptyView().highPriorityGesture(DragGesture.self))
    }
    
    func testHighPriorityGestureInspectionFailureDueToNoModifier() throws {
        let sut = EmptyView()
        XCTAssertThrowsError(try sut.inspect().emptyView().highPriorityGesture(DragGesture.self))
    }
    
    func testHighPriorityGestureInspectionFailureDueToTypeMismatch() throws {
        let sut = EmptyView().highPriorityGesture(LongPressGesture())
        XCTAssertThrowsError(try sut.inspect().emptyView().highPriorityGesture(DragGesture.self))
    }
    
    func testHighPriorityGestureInspectionWithIndex1() throws {
        let sut = EmptyView().highPriorityGesture(DragGesture()).highPriorityGesture(LongPressGesture())
        XCTAssertNoThrow(try sut.inspect().emptyView().highPriorityGesture(DragGesture.self, 0))
        XCTAssertNoThrow(try sut.inspect().emptyView().highPriorityGesture(LongPressGesture.self, 1))
    }
    
    func testHighPriorityGestureInspectionWithIndex2() throws {
        let sut = EmptyView().highPriorityGesture(DragGesture()).gesture(TapGesture()).highPriorityGesture(LongPressGesture())
        XCTAssertNoThrow(try sut.inspect().emptyView().highPriorityGesture(DragGesture.self, 0))
        XCTAssertNoThrow(try sut.inspect().emptyView().highPriorityGesture(LongPressGesture.self, 1))
    }
    
    func testHighPriorityGestureInspectionWithIndexFailureDueToNoModifier() throws {
        let sut = EmptyView().highPriorityGesture(DragGesture()).highPriorityGesture(LongPressGesture())
        XCTAssertThrowsError(try sut.inspect().emptyView().highPriorityGesture(DragGesture.self, 2))
    }
    
    func testHighPriorityGestureInspectionWithIndexFailureDueToTypeMismatch() throws {
        let sut = EmptyView().highPriorityGesture(DragGesture()).highPriorityGesture(LongPressGesture())
        XCTAssertThrowsError(try sut.inspect().emptyView().highPriorityGesture(LongPressGesture.self, 0))
    }
    
    func testHighPriorityGestureInspectionPathToRoot() throws {
        let sut = EmptyView().padding(100).highPriorityGesture(DragGesture())
        XCTAssertEqual(try sut.inspect().emptyView().highPriorityGesture(DragGesture.self).pathToRoot, "emptyView().highPriorityGesture(DragGesture.self, 0)")
    }
    
    func testHighPriorityGestureInspectionWithIndexPathToRoot() throws {
        let sut = EmptyView().padding(100).highPriorityGesture(DragGesture()).highPriorityGesture(LongPressGesture())
        XCTAssertEqual(try sut.inspect().emptyView().highPriorityGesture(LongPressGesture.self, 1).pathToRoot, "emptyView().highPriorityGesture(LongPressGesture.self, 1)")
    }

    // MARK: - Simultaneous Gesture Modifier Tests
    
    func testSimultaneousGesture() throws {
        let sut = EmptyView().simultaneousGesture(DragGesture())
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testSimultaneousGestureDoesNotBlock() throws {
        let sut = EmptyView().simultaneousGesture(DragGesture()).padding(100)
        XCTAssertEqual(try sut.inspect().emptyView().padding(.top), 100)
    }

    func testSimultaneousGestureInspection() throws {
        let sut = EmptyView().simultaneousGesture(DragGesture())
        XCTAssertNoThrow(try sut.inspect().emptyView().simultaneousGesture(DragGesture.self))
    }
    
    func testSimultaneousGestureInspectionFailureDueToNoModifier() throws {
        let sut = EmptyView()
        XCTAssertThrowsError(try sut.inspect().emptyView().simultaneousGesture(DragGesture.self))
    }
    
    func testSimultaneousGestureInspectionFailureDueToTypeMismatch() throws {
        let sut = EmptyView().simultaneousGesture(LongPressGesture())
        XCTAssertThrowsError(try sut.inspect().emptyView().simultaneousGesture(DragGesture.self))
    }
    
    func testSimultaneousGestureInspectionWithIndex1() throws {
        let sut = EmptyView().simultaneousGesture(DragGesture()).simultaneousGesture(LongPressGesture())
        XCTAssertNoThrow(try sut.inspect().emptyView().simultaneousGesture(DragGesture.self, 0))
        XCTAssertNoThrow(try sut.inspect().emptyView().simultaneousGesture(LongPressGesture.self, 1))
    }
    
    func testSimultaneousGestureInspectionWithIndex2() throws {
        let sut = EmptyView().simultaneousGesture(DragGesture()).gesture(TapGesture()).simultaneousGesture(LongPressGesture())
        XCTAssertNoThrow(try sut.inspect().emptyView().simultaneousGesture(DragGesture.self, 0))
        XCTAssertNoThrow(try sut.inspect().emptyView().simultaneousGesture(LongPressGesture.self, 1))
    }
    
    func testSimultaneousGestureInspectionWithIndexFailureDueToNoModifier() throws {
        let sut = EmptyView().simultaneousGesture(DragGesture()).simultaneousGesture(LongPressGesture())
        XCTAssertThrowsError(try sut.inspect().emptyView().simultaneousGesture(DragGesture.self, 2))
    }
    
    func testSimultaneousGestureInspectionWithIndexFailureDueToTypeMismatch() throws {
        let sut = EmptyView().simultaneousGesture(DragGesture()).simultaneousGesture(LongPressGesture())
        XCTAssertThrowsError(try sut.inspect().emptyView().simultaneousGesture(LongPressGesture.self, 0))
    }
    
    func testSimultaneousGestureInspectionPathToRoot() throws {
        let sut = EmptyView().padding(100).simultaneousGesture(DragGesture())
        XCTAssertEqual(try sut.inspect().emptyView().simultaneousGesture(DragGesture.self).pathToRoot, "emptyView().simultaneousGesture(DragGesture.self, 0)")
    }
    
    func testSimultaneousGestureInspectionWithIndexPathToRoot() throws {
        let sut = EmptyView().padding(100).simultaneousGesture(DragGesture()).simultaneousGesture(LongPressGesture())
        XCTAssertEqual(try sut.inspect().emptyView().simultaneousGesture(LongPressGesture.self, 1).pathToRoot, "emptyView().simultaneousGesture(LongPressGesture.self, 1)")
    }

    // MARK: - Drag Gesture Tests
    
    func testCreateDragGestureValue() throws {
        XCTAssertNotNil(dragTime)
        XCTAssertNotNil(dragLocation)
        XCTAssertNotNil(dragStartLocation)
        XCTAssertNotNil(dragVelocity)
        let value = try XCTUnwrap(dragValue)
        assertDragValue(value)
    }
    
    func testDragGestureMask() throws {
        try gestureMaskTest(DragGesture())
    }
    
    func testDragGesture() throws {
        let sut = EmptyView().gesture(DragGesture(minimumDistance: 1, coordinateSpace: .global))
        let dragGesture = try sut.inspect().emptyView().gesture(DragGesture.self).gestureProperties()
        XCTAssertEqual(dragGesture.minimumDistance, 1)
        XCTAssertEqual(dragGesture.coordinateSpace, .global)
    }
    
    func testDragGestureWithUpdatingModifier() throws {
        try gesturePropertiesWithUpdatingModifierTest(DragGesture())
    }
    
    func testDragGestureWithOnChangedModifier() throws {
        try gesturePropertiesWithOnChangedModifierTest(DragGesture())
    }
    
    func testDragGestureWithOnEndedModifier() throws {
        try gesturePropertiesWithOnEndedModifierTest(DragGesture())
    }
    
    #if os(macOS)
    func testDragGestureWithModifiers() throws {
        try gesturePropertiesWithModifiersTest(DragGesture())
    }
    #endif
    
    func testDragGestureFailure() throws {
        try gesturePropertiesFailureTest(DragGesture())
    }

    func testDragGestureCallUpdating() throws {
        try gestureCallUpdating(gesture: DragGesture(), value: dragValue!, assertValue: assertDragValue)
    }
    
    func testDragGestureCallUpdatingNotFirst() throws {
        try gestureCallUpdatingNotFirstTest(gesture: DragGesture(), value: dragValue!, assertValue: assertDragValue)
    }

    func testDragGestureCallUpdatingMultiple() throws {
        try gestureCallUpdatingMultipleTest(gesture: DragGesture(), value: dragValue!, assertValue: assertDragValue)
    }
    
    func testDragGestureCallUpdatingFailure() throws {
        try gestureCallUpdatingFailureTest(gesture: DragGesture(), value: dragValue!)
    }
    
    func testDragGestureCallOnChanged() throws {
        try gestureCallOnChangedTest(gesture: DragGesture(), value: dragValue!, assertValue: assertDragValue)
    }
    
    func testDragGestureCallOnChangedNotFirst() throws {
        try gestureCallOnChangedNotFirstTest(gesture: DragGesture(), value: dragValue!, assertValue: assertDragValue)
    }
    
    func testDragGestureCallOnChangedMultiple() throws {
        try gestureCallOnChangedMultipleTest(gesture: DragGesture(), value: dragValue!, assertValue: assertDragValue)
    }
    
    func testDragGestureCallOnChangedFailure() throws {
        try gestureCallOnChangedFailureTest(gesture: DragGesture(), value: dragValue!)
    }
    
    func testDragGestureCallOnEnded() throws {
        try gestureCallOnEndedTest(gesture: DragGesture(), value: dragValue!, assertValue: assertDragValue)
    }
    
    func testDragGestureCallOnEndedNotFirst() throws {
        try gestureCallOnEndedNotFirstTest(gesture: DragGesture(), value: dragValue!, assertValue: assertDragValue)
    }

    func testDragGestureCallOnEndedMultiple() throws {
        try gestureCallOnEndedMultipleTest(gesture: DragGesture(), value: dragValue!, assertValue: assertDragValue)
    }
    
    func testDragGestureCallOnEndedFailure() throws {
        try gestureCallOnEndedFailureTest(gesture: DragGesture(), value: dragValue!)
    }
    
    #if os(macOS)
    func testDragGestureModifiers() throws {
        try gestureModifiersTest(gesture: DragGesture())
    }
        
    func testDragGestureModifiersNotFirst() throws {
        try gestureModifiersNotFirstTest(gesture: DragGesture(), value: dragValue!)
    }
    
    func testDragGestureModifiersMultiple() throws {
        try gestureModifiersMultipleTest(gesture: DragGesture())
    }
    
    func testDragGestureModifiersNone() throws {
        try gestureModifiersNoneTest(gesture: DragGesture())
    }
    #endif

    func assertDragValue(_ value: DragGesture.Value, file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertEqual(value.location, dragLocation, file: file, line: line)
        XCTAssertEqual(value.predictedEndLocation, CGPoint(x: 102, y: 102), file: file, line: line)
        XCTAssertEqual(value.predictedEndTranslation, CGSize(width: 52, height: 52), file: file, line: line)
        XCTAssertEqual(value.startLocation, dragStartLocation, file: file, line: line)
        XCTAssertEqual(value.time, dragTime, file: file, line: line)
        XCTAssertEqual(value.translation, CGSize(width: 50, height: 50), file: file, line: line)
    }
    
    // MARK: - Long Press Gesture Tests
    
    func testCreateLongPressGestureValue() throws {
        XCTAssertNotNil(longPressFinished)
        let value = try XCTUnwrap(longPressValue)
        assertLongPressValue(value)
    }
    
    func testLongPressGestureMask() throws {
        try gestureMaskTest(LongPressGesture())
    }
    
    func testLongPressGesture() throws {
        let sut = EmptyView().gesture(LongPressGesture(minimumDuration: 5, maximumDistance: 1))
        let longPressGesture = try sut.inspect().emptyView().gesture(LongPressGesture.self).gestureProperties()
        XCTAssertEqual(longPressGesture.minimumDuration, 5)
        XCTAssertEqual(longPressGesture.maximumDistance, 1)
    }
    
    func testLongPressGestureWithUpdatingModifier() throws {
        try gesturePropertiesWithUpdatingModifierTest(LongPressGesture())
    }
    
    func testLongPressGestureWithOnChangedModifier() throws {
        try gesturePropertiesWithOnChangedModifierTest(LongPressGesture())
    }
    
    func testLongPressGestureWithOnEndedModifier() throws {
        try gesturePropertiesWithOnEndedModifierTest(LongPressGesture())
    }
    
    #if os(macOS)
    func testLongPressGestureWithModifiers() throws {
        try gesturePropertiesWithModifiersTest(LongPressGesture())
    }
    #endif
    
    func testLongPressGestureFailure() throws {
        try gesturePropertiesFailureTest(LongPressGesture())
    }

    func testLongPressGestureCallUpdating() throws {
        try gestureCallUpdating(gesture: LongPressGesture(), value: longPressValue!, assertValue: assertLongPressValue)
    }
    
    func testLongPressGestureCallUpdatingNotFirst() throws {
        try gestureCallUpdatingNotFirstTest(gesture: LongPressGesture(), value: longPressValue!, assertValue: assertLongPressValue)
    }

    func testLongPressGestureCallUpdatingMultiple() throws {
        try gestureCallUpdatingMultipleTest(gesture: LongPressGesture(), value: longPressValue!, assertValue: assertLongPressValue)
    }
    
    func testLongPressGestureCallUpdatingFailure() throws {
        try gestureCallUpdatingFailureTest(gesture: LongPressGesture(), value: longPressValue!)
    }
    
    func testLongPressGestureCallOnChanged() throws {
        try gestureCallOnChangedTest(gesture: LongPressGesture(), value: longPressValue!, assertValue: assertLongPressValue)
    }
    
    func testLongPressGestureCallOnChangedNotFirst() throws {
        try gestureCallOnChangedNotFirstTest(gesture: LongPressGesture(), value: longPressValue!, assertValue: assertLongPressValue)
    }
    
    func testLongPressGestureCallOnChangedMultiple() throws {
        try gestureCallOnChangedMultipleTest(gesture: LongPressGesture(), value: longPressValue!, assertValue: assertLongPressValue)
    }
    
    func testLongPressGestureCallOnChangedFailure() throws {
        try gestureCallOnChangedFailureTest(gesture: LongPressGesture(), value: longPressValue!)
    }
    
    func testLongPressGestureCallOnEnded() throws {
        try gestureCallOnEndedTest(gesture: LongPressGesture(), value: longPressValue!, assertValue: assertLongPressValue)
    }
    
    func testLongPressGestureCallOnEndedNotFirst() throws {
        try gestureCallOnEndedNotFirstTest(gesture: LongPressGesture(), value: longPressValue!, assertValue: assertLongPressValue)
    }

    func testLongPressGestureCallOnEndedMultiple() throws {
        try gestureCallOnEndedMultipleTest(gesture: LongPressGesture(), value: longPressValue!, assertValue: assertLongPressValue)
    }
    
    func testLongPressGestureCallOnEndedFailure() throws {
        try gestureCallOnEndedFailureTest(gesture: LongPressGesture(), value: longPressValue!)
    }
    
    #if os(macOS)
    func testLongPressGestureModifiers() throws {
        try gestureModifiersTest(gesture: LongPressGesture())
    }
        
    func testLongPressGestureModifiersNotFirst() throws {
        try gestureModifiersNotFirstTest(gesture: LongPressGesture(), value: longPressValue!)
    }
    
    func testLongPressGestureModifiersMultiple() throws {
        try gestureModifiersMultipleTest(gesture: LongPressGesture())
    }
    
    func testLongPressGestureModifiersNone() throws {
        try gestureModifiersNoneTest(gesture: LongPressGesture())
    }
    #endif
    
    func assertLongPressValue(_ value: LongPressGesture.Value, file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertEqual(value, longPressFinished!)
    }
    
    // MARK: - Magnification Gesture Tests

    func testCreateMagnificationGestureValue() throws {
        XCTAssertNotNil(magnificationMagnifyBy)
        let value = try XCTUnwrap(magnificationValue)
        assertMagnificationValue(value)
    }
    
    func testMagnificationGestureMask() throws {
        try gestureMaskTest(MagnificationGesture())
    }
    
    func testMagnificationGesture() throws {
        let sut = EmptyView().gesture(MagnificationGesture(minimumScaleDelta: 1.5))
        let magnificationGesture = try sut.inspect().emptyView().gesture(MagnificationGesture.self).gestureProperties()
        XCTAssertEqual(magnificationGesture.minimumScaleDelta, 1.5)
    }

    func testMagnificationGestureWithUpdatingModifier() throws {
        try gesturePropertiesWithUpdatingModifierTest(MagnificationGesture())
    }
    
    func testMagnificationGestureWithOnChangedModifier() throws {
        try gesturePropertiesWithOnChangedModifierTest(MagnificationGesture())
    }
    
    func testMagnificationGestureWithOnEndedModifier() throws {
        try gesturePropertiesWithOnEndedModifierTest(MagnificationGesture())
    }
    
    #if os(macOS)
    func testMagnificationGestureWithModifiers() throws {
        try gesturePropertiesWithModifiersTest(MagnificationGesture())
    }
    #endif
    
    func testMagnificationGestureFailure() throws {
        try gesturePropertiesFailureTest(MagnificationGesture())
    }

    func testMagnificationGestureCallUpdating() throws {
        try gestureCallUpdating(gesture: MagnificationGesture(), value: magnificationValue!, assertValue: assertMagnificationValue)
    }
    
    func testMagnificationGestureCallUpdatingNotFirst() throws {
        try gestureCallUpdatingNotFirstTest(gesture: MagnificationGesture(), value: magnificationValue!, assertValue: assertMagnificationValue)
    }

    func testMagnificationGestureCallUpdatingMultiple() throws {
        try gestureCallUpdatingMultipleTest(gesture: MagnificationGesture(), value: magnificationValue!, assertValue: assertMagnificationValue)
    }
    
    func testMagnificationGestureCallUpdatingFailure() throws {
        try gestureCallUpdatingFailureTest(gesture: MagnificationGesture(), value: magnificationValue!)
    }
    
    func testMagnificationGestureCallOnChanged() throws {
        try gestureCallOnChangedTest(gesture: MagnificationGesture(), value: magnificationValue!, assertValue: assertMagnificationValue)
    }
    
    func testMagnificationGestureCallOnChangedNotFirst() throws {
        try gestureCallOnChangedNotFirstTest(gesture: MagnificationGesture(), value: magnificationValue!, assertValue: assertMagnificationValue)
    }
    
    func testMagnificationGestureCallOnChangedMultiple() throws {
        try gestureCallOnChangedMultipleTest(gesture: MagnificationGesture(), value: magnificationValue!, assertValue: assertMagnificationValue)
    }
    
    func testMagnificationGestureCallOnChangedFailure() throws {
        try gestureCallOnChangedFailureTest(gesture: MagnificationGesture(), value: magnificationValue!)
    }
    
    func testMagnificationGestureCallOnEnded() throws {
        try gestureCallOnEndedTest(gesture: MagnificationGesture(), value: magnificationValue!, assertValue: assertMagnificationValue)
    }
    
    func testMagnificationGestureCallOnEndedNotFirst() throws {
        try gestureCallOnEndedNotFirstTest(gesture: MagnificationGesture(), value: magnificationValue!, assertValue: assertMagnificationValue)
    }

    func testMagnificationGestureCallOnEndedMultiple() throws {
        try gestureCallOnEndedMultipleTest(gesture: MagnificationGesture(), value: magnificationValue!, assertValue: assertMagnificationValue)
    }
    
    func testMagnificationGestureCallOnEndedFailure() throws {
        try gestureCallOnEndedFailureTest(gesture: MagnificationGesture(), value: magnificationValue!)
    }
    
    #if os(macOS)
    func testMagnificationGestureModifiers() throws {
        try gestureModifiersTest(gesture: MagnificationGesture())
    }
        
    func testMagnificationGestureModifiersNotFirst() throws {
        try gestureModifiersNotFirstTest(gesture: MagnificationGesture(), value: magnificationValue!)
    }
    
    func testMagnificationGestureModifiersMultiple() throws {
        try gestureModifiersMultipleTest(gesture: MagnificationGesture())
    }
    
    func testMagnificationGestureModifiersNone() throws {
        try gestureModifiersNoneTest(gesture: MagnificationGesture())
    }
    #endif

    func assertMagnificationValue(_ value: MagnificationGesture.Value, file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertEqual(value, magnificationMagnifyBy)
    }

    // MARK: - Rotation Gesture Tests

    func testCreateRotationGestureValue() throws {
        XCTAssertNotNil(rotationAngle)
        let value = try XCTUnwrap(rotationValue)
        assertRotationValue(value)
    }
    
    func testRotationGestureMask() throws {
        try gestureMaskTest(RotationGesture())
    }
    
    func testRotationGesture() throws {
        let sut = EmptyView().gesture(RotationGesture(minimumAngleDelta: Angle(degrees: 5)))
        let rotationGesture = try sut.inspect().emptyView().gesture(RotationGesture.self).gestureProperties()
        XCTAssertEqual(rotationGesture.minimumAngleDelta, Angle(degrees: 5))
    }
    
    func testRotationGestureWithUpdatingModifier() throws {
        try gesturePropertiesWithUpdatingModifierTest(RotationGesture())
    }
    
    func testRotationGestureWithOnChangedModifier() throws {
        try gesturePropertiesWithOnChangedModifierTest(RotationGesture())
    }
    
    func testRotationGestureWithOnEndedModifier() throws {
        try gesturePropertiesWithOnEndedModifierTest(RotationGesture())
    }
    
    #if os(macOS)
    func testRotationGestureWithModifiers() throws {
        try gesturePropertiesWithModifiersTest(RotationGesture())
    }
    #endif
    
    func testRotationGestureFailure() throws {
        try gesturePropertiesFailureTest(RotationGesture())
    }

    func testRotationGestureCallUpdating() throws {
        try gestureCallUpdating(gesture: RotationGesture(), value: rotationValue!, assertValue: assertRotationValue)
    }
    
    func testRotationGestureCallUpdatingNotFirst() throws {
        try gestureCallUpdatingNotFirstTest(gesture: RotationGesture(), value: rotationValue!, assertValue: assertRotationValue)
    }

    func testRotationGestureCallUpdatingMultiple() throws {
        try gestureCallUpdatingMultipleTest(gesture: RotationGesture(), value: rotationValue!, assertValue: assertRotationValue)
    }
    
    func testRotationGestureCallUpdatingFailure() throws {
        try gestureCallUpdatingFailureTest(gesture: RotationGesture(), value: rotationValue!)
    }
    
    func testRotationGestureCallOnChanged() throws {
        try gestureCallOnChangedTest(gesture: RotationGesture(), value: rotationValue!, assertValue: assertRotationValue)
    }
    
    func testRotationGestureCallOnChangedNotFirst() throws {
        try gestureCallOnChangedNotFirstTest(gesture: RotationGesture(), value: rotationValue!, assertValue: assertRotationValue)
    }
    
    func testRotationGestureCallOnChangedMultiple() throws {
        try gestureCallOnChangedMultipleTest(gesture: RotationGesture(), value: rotationValue!, assertValue: assertRotationValue)
    }
    
    func testRotationGestureCallOnChangedFailure() throws {
        try gestureCallOnChangedFailureTest(gesture: RotationGesture(), value: rotationValue!)
    }
    
    func testRotationGestureCallOnEnded() throws {
        try gestureCallOnEndedTest(gesture: RotationGesture(), value: rotationValue!, assertValue: assertRotationValue)
    }
    
    func testRotationGestureCallOnEndedNotFirst() throws {
        try gestureCallOnEndedNotFirstTest(gesture: RotationGesture(), value: rotationValue!, assertValue: assertRotationValue)
    }

    func testRotationGestureCallOnEndedMultiple() throws {
        try gestureCallOnEndedMultipleTest(gesture: RotationGesture(), value: rotationValue!, assertValue: assertRotationValue)
    }
    
    func testRotationGestureCallOnEndedFailure() throws {
        try gestureCallOnEndedFailureTest(gesture: RotationGesture(), value: rotationValue!)
    }
    
    #if os(macOS)
    func testRotationGestureModifiers() throws {
        try gestureModifiersTest(gesture: RotationGesture())
    }
        
    func testRotationGestureModifiersNotFirst() throws {
        try gestureModifiersNotFirstTest(gesture: RotationGesture(), value: rotationValue!)
    }
    
    func testRotationGestureModifiersMultiple() throws {
        try gestureModifiersMultipleTest(gesture: RotationGesture())
    }
    
    func testRotationGestureModifiersNone() throws {
        try gestureModifiersNoneTest(gesture: RotationGesture())
    }
    #endif

    func assertRotationValue(_ value: RotationGesture.Value, file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertEqual(value, rotationAngle!)
    }

    // MARK: - Tap Gesture Tests

    func testCreateTapGestureValue() throws {
        let value: TapGesture.Value = try XCTUnwrap(tapValue)
        assertTapValue(value)
    }

    func testTapGestureMask() throws {
        try gestureMaskTest(TapGesture())
    }
    
    func testTapGesture() throws {
        let sut = EmptyView().gesture(TapGesture(count: 2))
        let tapGesture = try sut.inspect().emptyView().gesture(TapGesture.self).gestureProperties()
        XCTAssertEqual(tapGesture.count, 2)
    }
    
    func testTapGestureWithUpdatingModifier() throws {
        try gesturePropertiesWithUpdatingModifierTest(TapGesture())
    }
        
    func testTapGestureWithOnEndedModifier() throws {
        try gesturePropertiesWithOnEndedModifierTest(TapGesture())
    }
    
    #if os(macOS)
    func testTapGestureWithModifiers() throws {
        try gesturePropertiesWithModifiersTest(TapGesture())
    }
    #endif
    
    func testTapGestureFailure() throws {
        try gesturePropertiesFailureTest(TapGesture())
    }

    func testTapGestureCallUpdating() throws {
        try gestureCallUpdating(gesture: TapGesture(), value: tapValue!, assertValue: assertTapValue)
    }
    
    func testTapGestureCallUpdatingNotFirst() throws {
        try gestureCallUpdatingNotFirstTest(gesture: TapGesture(), value: tapValue!, assertValue: assertTapValue)
    }

    func testTapGestureCallUpdatingMultiple() throws {
        try gestureCallUpdatingMultipleTest(gesture: TapGesture(), value: tapValue!, assertValue: assertTapValue)
    }
    
    func testTapGestureCallUpdatingFailure() throws {
        try gestureCallUpdatingFailureTest(gesture: TapGesture(), value: tapValue!)
    }
    
    func testTapGestureCallOnEnded() throws {
        try gestureCallOnEndedTest(gesture: TapGesture(), value: tapValue!, assertValue: assertTapValue)
    }
    
    func testTapGestureCallOnEndedNotFirst() throws {
        try gestureCallOnEndedNotFirstTest(gesture: TapGesture(), value: tapValue!, assertValue: assertTapValue)
    }

    func testTapGestureCallOnEndedMultiple() throws {
        try gestureCallOnEndedMultipleTest(gesture: TapGesture(), value: tapValue!, assertValue: assertTapValue)
    }
    
    func testTapGestureCallOnEndedFailure() throws {
        try gestureCallOnEndedFailureTest(gesture: TapGesture(), value: tapValue!)
    }
    
    #if os(macOS)
    func testTapGestureModifiers() throws {
        try gestureModifiersTest(gesture: TapGesture())
    }
        
    func testTapGestureModifiersNotFirst() throws {
        try gestureModifiersNotFirstTest(gesture: TapGesture(), value: tapValue!)
    }
    
    func testTapGestureModifiersMultiple() throws {
        try gestureModifiersMultipleTest(gesture: TapGesture())
    }
    
    func testTapGestureModifiersNone() throws {
        try gestureModifiersNoneTest(gesture: TapGesture())
    }
    #endif

    func assertTapValue(_ value: TapGesture.Value, file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertTrue(value == ())
    }
    
    // MARK: - Exclusive Gesture Tests
    
    func testCreateExclusiveGestureValue() throws {
        XCTAssertNotNil(magnificationValue)
        let value = try XCTUnwrap(exclusiveGestureValue)
        assertExclusiveGestureValue(value)
    }
    
    func testExclusiveGestureGestureMask() throws {
        try gestureMaskTest(ExclusiveGesture(MagnificationGesture(), RotationGesture()))
    }
    
    func testExclusiveGestureGesture() throws {
        let sut = EmptyView().gesture(ExclusiveGesture(
            MagnificationGesture(minimumScaleDelta: 1.5),
            RotationGesture(minimumAngleDelta: Angle(degrees: 5))))
        let emptyView = try sut.inspect().emptyView()
        let gesture = try emptyView.gesture(ExclusiveGesture<MagnificationGesture, RotationGesture>.self)
        let exclusiveGesture = try gesture.gestureProperties()
        XCTAssertEqual(exclusiveGesture.first.minimumScaleDelta, 1.5)
        XCTAssertEqual(exclusiveGesture.second.minimumAngleDelta, Angle(degrees: 5))
    }
    
    func testExclusiveGestureWithUpdatingModifier() throws {
        try gesturePropertiesWithUpdatingModifierTest(ExclusiveGesture(MagnificationGesture(), RotationGesture()))
    }
    
    func testExclusiveGestureWithOnChangedModifier() throws {
        try gesturePropertiesWithOnChangedModifierTest(ExclusiveGesture(MagnificationGesture(), RotationGesture()))
    }
    
    func testExclusiveGestureWithOnEndedModifier() throws {
        try gesturePropertiesWithOnEndedModifierTest(ExclusiveGesture(MagnificationGesture(), RotationGesture()))
    }
    
    #if os(macOS)
    func testExclusiveGestureWithModifiers() throws {
        try gesturePropertiesWithModifiersTest(ExclusiveGesture(MagnificationGesture(), RotationGesture()))
    }
    #endif
    
    func testExclusiveGestureFailure() throws {
        try gesturePropertiesFailureTest(ExclusiveGesture(MagnificationGesture(), RotationGesture()))
    }
    
    func testExclusiveGestureCallUpdating() throws {
        try gestureCallUpdating(
            gesture: ExclusiveGesture(MagnificationGesture(), RotationGesture()),
            value: exclusiveGestureValue!,
            assertValue: assertExclusiveGestureValue)
    }
    
    func testExclusiveGestureCallUpdatingNotFirst() throws {
        try gestureCallUpdatingNotFirstTest(
            gesture: ExclusiveGesture(MagnificationGesture(), RotationGesture()),
            value: exclusiveGestureValue!,
            assertValue: assertExclusiveGestureValue)
    }

    func testExclusiveGestureCallUpdatingMultiple() throws {
        try gestureCallUpdatingMultipleTest(
            gesture: ExclusiveGesture(MagnificationGesture(), RotationGesture()),
            value: exclusiveGestureValue!,
            assertValue: assertExclusiveGestureValue)
    }
    
    func testExclusiveGestureCallUpdatingFailure() throws {
        try gestureCallUpdatingFailureTest(
            gesture: ExclusiveGesture(MagnificationGesture(), RotationGesture()),
            value: exclusiveGestureValue!)
    }

    func testExclusiveGestureCallOnEnded() throws {
        try gestureCallOnEndedTest(
            gesture: ExclusiveGesture(MagnificationGesture(), RotationGesture()),
            value: exclusiveGestureValue!,
            assertValue: assertExclusiveGestureValue)
    }
    
    func testExclusiveGestureCallOnEndedNotFirst() throws {
        try gestureCallOnEndedNotFirstTest(
            gesture: ExclusiveGesture(MagnificationGesture(), RotationGesture()),
            value: exclusiveGestureValue!,
            assertValue: assertExclusiveGestureValue)
    }

    func testExclusiveGestureCallOnEndedMultiple() throws {
        try gestureCallOnEndedMultipleTest(
            gesture: ExclusiveGesture(MagnificationGesture(), RotationGesture()),
            value: exclusiveGestureValue!,
            assertValue: assertExclusiveGestureValue)
    }
    
    func testExclusiveGestureCallOnEndedFailure() throws {
        try gestureCallOnEndedFailureTest(
            gesture: ExclusiveGesture(MagnificationGesture(), RotationGesture()),
            value: exclusiveGestureValue!)
    }
    
    #if os(macOS)
    func testExclusiveGestureModifiers() throws {
        try gestureModifiersTest(gesture: ExclusiveGesture(MagnificationGesture(), RotationGesture()))
    }
        
    func testExclusiveGestureModifiersNotFirst() throws {
        try gestureModifiersNotFirstTest(
            gesture: ExclusiveGesture(MagnificationGesture(), RotationGesture()),
            value: exclusiveGestureValue!)
    }
    
    func testExclusiveGestureModifiersMultiple() throws {
        try gestureModifiersMultipleTest(gesture: ExclusiveGesture(MagnificationGesture(), RotationGesture()))
    }
    
    func testExclusiveGestureModifiersNone() throws {
        try gestureModifiersNoneTest(gesture: ExclusiveGesture(MagnificationGesture(), RotationGesture()))
    }
    #endif
    
    func testExclusiveGestureChildren() throws {
        try composedGestureTest(
            type: ExclusiveGesture<MagnificationGesture, RotationGesture>.self,
            order: .first) { first, second in ExclusiveGesture(first, second)
        }
        try composedGestureTest(
            type: ExclusiveGesture<MagnificationGesture, RotationGesture>.self,
            order: .second) { first, second in ExclusiveGesture(first, second)
        }
    }
    
    func testExclusiveGestureChildrenFailure() throws {
        try composedGestureFailureTest(
            type: ExclusiveGesture<MagnificationGesture, RotationGesture>.self,
            order: .first) { first, second in ExclusiveGesture(first, second)
        }
        try composedGestureFailureTest(
            type: ExclusiveGesture<MagnificationGesture, RotationGesture>.self,
            order: .second) { first, second in ExclusiveGesture(first, second)
        }
    }

    func testExclusiveGestureChildrenCallUpdating() throws {
        try composedGestureCallUpdatingTest(
            type: ExclusiveGesture<MagnificationGesture, RotationGesture>.self,
            order: .first) { first, second in ExclusiveGesture(first, second)
        }
        try composedGestureCallUpdatingTest(
            type: ExclusiveGesture<MagnificationGesture, RotationGesture>.self,
            order: .second) { first, second in ExclusiveGesture(first, second)
        }
    }
    
    func testExclusiveGestureChildrenCallUpdatingNotFirst() throws {
        try composedGestureCallUpdatingNotFirstTest(
            type: ExclusiveGesture<MagnificationGesture, RotationGesture>.self,
            order: .first) { first, second in ExclusiveGesture(first, second)
        }
        try composedGestureCallUpdatingNotFirstTest(
            type: ExclusiveGesture<MagnificationGesture, RotationGesture>.self,
            order: .second) { first, second in ExclusiveGesture(first, second)
        }
    }
    
    func testExclusiveGestureChildrenCallUpdatingMultiple() throws {
        try composedGestureCallUpdatingMultipleTest(
            type: ExclusiveGesture<MagnificationGesture, RotationGesture>.self,
            order: .first) { first, second in ExclusiveGesture(first, second)
        }
        try composedGestureCallUpdatingMultipleTest(
            type: ExclusiveGesture<MagnificationGesture, RotationGesture>.self,
            order: .second) { first, second in ExclusiveGesture(first, second)
        }
    }
    
    func testExclusiveGestureChildrenCallUpdatingFailure() throws {
        try composedGestureCallUpdatingFailureTest(
            type: ExclusiveGesture<MagnificationGesture, RotationGesture>.self,
            order: .first) { first, second in ExclusiveGesture(first, second)
        }
        try composedGestureCallUpdatingFailureTest(
            type: ExclusiveGesture<MagnificationGesture, RotationGesture>.self,
            order: .second) { first, second in ExclusiveGesture(first, second)
        }
    }

    func testExclusiveGestureChildrenCallChanged() throws {
        try composedGestureCallChangedTest(
            type: ExclusiveGesture<MagnificationGesture, RotationGesture>.self,
            order: .first) { first, second in ExclusiveGesture(first, second)
        }
        try composedGestureCallChangedTest(
            type: ExclusiveGesture<MagnificationGesture, RotationGesture>.self,
            order: .second) { first, second in ExclusiveGesture(first, second)
        }
    }
    
    func testExclusiveGestureChildrenCallChangedNotFirst() throws {
        try composedGestureCallChangedNotFirstTest(
            type: ExclusiveGesture<MagnificationGesture, RotationGesture>.self,
            order: .first) { first, second in ExclusiveGesture(first, second)
        }
        try composedGestureCallChangedNotFirstTest(
            type: ExclusiveGesture<MagnificationGesture, RotationGesture>.self,
            order: .second) { first, second in ExclusiveGesture(first, second)
        }
    }
    
    func testExclusiveGestureFirstCallChangedMultiple() throws {
        try composedGestureCallChangedMultipleTest(
            type: ExclusiveGesture<MagnificationGesture, RotationGesture>.self,
            order: .first) { first, second in ExclusiveGesture(first, second)
        }
        try composedGestureCallChangedMultipleTest(
            type: ExclusiveGesture<MagnificationGesture, RotationGesture>.self,
            order: .second) { first, second in ExclusiveGesture(first, second)
        }
    }
    
    func testExclusiveGestureChildrenCallChangedFailure() throws {
        try composedGestureCallChangedFailureTest(
            type: ExclusiveGesture<MagnificationGesture, RotationGesture>.self,
            order: .first) { first, second in ExclusiveGesture(first, second)
        }
        try composedGestureCallChangedFailureTest(
            type: ExclusiveGesture<MagnificationGesture, RotationGesture>.self,
            order: .second) { first, second in ExclusiveGesture(first, second)
        }
    }
    
    func testExclusiveGestureChildrenCallEnded() throws {
        try composedGestureCallEndedTest(
            type: ExclusiveGesture<MagnificationGesture, RotationGesture>.self,
            order: .first) { first, second in ExclusiveGesture(first, second)
        }
        try composedGestureCallEndedTest(
            type: ExclusiveGesture<MagnificationGesture, RotationGesture>.self,
            order: .second) { first, second in ExclusiveGesture(first, second)
        }
    }

    func testExclusiveGestureChildrenCallEndedNotFirst() throws {
        try composedGestureCallEndedNotFirstTest(
            type: ExclusiveGesture<MagnificationGesture, RotationGesture>.self,
            order: .first) { first, second in ExclusiveGesture(first, second)
        }
        try composedGestureCallEndedNotFirstTest(
            type: ExclusiveGesture<MagnificationGesture, RotationGesture>.self,
            order: .second) { first, second in ExclusiveGesture(first, second)
        }
    }

    func testExclusiveGestureChildrenCallEndedMultiple() throws {
        try composedGestureCallEndedMultipleTest(
            type: ExclusiveGesture<MagnificationGesture, RotationGesture>.self,
            order: .first) { first, second in ExclusiveGesture(first, second)
        }
        try composedGestureCallEndedMultipleTest(
            type: ExclusiveGesture<MagnificationGesture, RotationGesture>.self,
            order: .second) { first, second in ExclusiveGesture(first, second)
        }
    }
    
    func testExclusiveGestureChildrenCallEndedFailure() throws {
        try composedGestureCallEndedFailureTest(
            type: ExclusiveGesture<MagnificationGesture, RotationGesture>.self,
            order: .first) { first, second in ExclusiveGesture(first, second)
        }
        try composedGestureCallEndedFailureTest(
            type: ExclusiveGesture<MagnificationGesture, RotationGesture>.self,
            order: .second) { first, second in ExclusiveGesture(first, second)
        }
    }
    
    #if os(macOS)
    func testExclusiveGestureChildrenModifiers() throws {
        try composedGestureModifiersTest(
            type: ExclusiveGesture<MagnificationGesture, RotationGesture>.self,
            order: .first) { first, second in ExclusiveGesture(first, second)
        }
        try composedGestureModifiersTest(
            type: ExclusiveGesture<MagnificationGesture, RotationGesture>.self,
            order: .second) { first, second in ExclusiveGesture(first, second)
        }
    }
    
    func testExclusiveGestureChildrenModifiersNodifiersNotFirst() throws {
        try composedGestureModifiersNotFirstTest(
            type: ExclusiveGesture<MagnificationGesture, RotationGesture>.self,
            order: .first) { first, second in ExclusiveGesture(first, second)
        }
        try composedGestureModifiersNotFirstTest(
            type: ExclusiveGesture<MagnificationGesture, RotationGesture>.self,
            order: .second) { first, second in ExclusiveGesture(first, second)
        }
    }

    func testExclusiveGestureChildrenModifiersNodifiersMultiple() throws {
        try composedGestureModifiersMultipleTest(
            type: ExclusiveGesture<MagnificationGesture, RotationGesture>.self,
            order: .first) { first, second in ExclusiveGesture(first, second)
        }
        try composedGestureModifiersMultipleTest(
            type: ExclusiveGesture<MagnificationGesture, RotationGesture>.self,
            order: .second) { first, second in ExclusiveGesture(first, second)
        }
    }
    
    func testExclusiveGestureChildrenModifiersNone() throws {
        try composedGestureModifiersFailureTest(
            type: ExclusiveGesture<MagnificationGesture, RotationGesture>.self,
            order: .first) { first, second in ExclusiveGesture(first, second)
        }
        try composedGestureModifiersFailureTest(
            type: ExclusiveGesture<MagnificationGesture, RotationGesture>.self,
            order: .second) { first, second in ExclusiveGesture(first, second)
        }
    }
    #endif

    func assertExclusiveGestureValue(_ value: ExclusiveGesture<MagnificationGesture, RotationGesture>.Value, file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertEqual(value, exclusiveGestureValue, file: file, line: line)
    }
    
    // MARK: - Sequence Gesture Tests
    
    func testCreateSequenceGestureValue() throws {
        XCTAssertNotNil(magnificationValue)
        let value = try XCTUnwrap(sequenceGestureValue)
        assertSequenceGestureValue(value)
    }
    
    func testSequenceGestureGestureMask() throws {
        try gestureMaskTest(SequenceGesture(MagnificationGesture(), RotationGesture()))
    }
    
    func testSequenceGestureGesture() throws {
        let sut = EmptyView().gesture(SequenceGesture(
            MagnificationGesture(minimumScaleDelta: 1.5),
            RotationGesture(minimumAngleDelta: Angle(degrees: 5))))
        let emptyView = try sut.inspect().emptyView()
        let gesture = try emptyView.gesture(SequenceGesture<MagnificationGesture, RotationGesture>.self)
        let sequenceGesture = try gesture.gestureProperties()
        XCTAssertEqual(sequenceGesture.first.minimumScaleDelta, 1.5)
        XCTAssertEqual(sequenceGesture.second.minimumAngleDelta, Angle(degrees: 5))
    }

    func testSequenceGestureWithUpdatingModifier() throws {
        try gesturePropertiesWithUpdatingModifierTest(SequenceGesture(MagnificationGesture(), RotationGesture()))
    }
    
    func testSequenceGestureWithOnChangedModifier() throws {
        try gesturePropertiesWithOnChangedModifierTest(SequenceGesture(MagnificationGesture(), RotationGesture()))
    }
    
    func testSequenceGestureWithOnEndedModifier() throws {
        try gesturePropertiesWithOnEndedModifierTest(SequenceGesture(MagnificationGesture(), RotationGesture()))
    }
    
    #if os(macOS)
    func testSequenceGestureWithModifiers() throws {
        try gesturePropertiesWithModifiersTest(SequenceGesture(MagnificationGesture(), RotationGesture()))
    }
    #endif
    
    func testSequenceGestureFailure() throws {
        try gesturePropertiesFailureTest(SequenceGesture(MagnificationGesture(), RotationGesture()))
    }
    
    func testSequenceGestureCallUpdating() throws {
        try gestureCallUpdating(
            gesture: SequenceGesture(MagnificationGesture(), RotationGesture()),
            value: sequenceGestureValue!,
            assertValue: assertSequenceGestureValue)
    }
    
    func testSequenceGestureCallUpdatingNotFirst() throws {
        try gestureCallUpdatingNotFirstTest(
            gesture: SequenceGesture(MagnificationGesture(), RotationGesture()),
            value: sequenceGestureValue!,
            assertValue: assertSequenceGestureValue)
    }

    func testSequenceGestureCallUpdatingMultiple() throws {
        try gestureCallUpdatingMultipleTest(
            gesture: SequenceGesture(MagnificationGesture(), RotationGesture()),
            value: sequenceGestureValue!,
            assertValue: assertSequenceGestureValue)
    }
    
    func testSequenceGestureCallUpdatingFailure() throws {
        try gestureCallUpdatingFailureTest(
            gesture: SequenceGesture(MagnificationGesture(), RotationGesture()),
            value: sequenceGestureValue!)
    }

    func testSequenceGestureCallOnEnded() throws {
        try gestureCallOnEndedTest(
            gesture: SequenceGesture(MagnificationGesture(), RotationGesture()),
            value: sequenceGestureValue!,
            assertValue: assertSequenceGestureValue)
    }
    
    func testSequenceGestureCallOnEndedNotFirst() throws {
        try gestureCallOnEndedNotFirstTest(
            gesture: SequenceGesture(MagnificationGesture(), RotationGesture()),
            value: sequenceGestureValue!,
            assertValue: assertSequenceGestureValue)
    }

    func testSequenceGestureCallOnEndedMultiple() throws {
        try gestureCallOnEndedMultipleTest(
            gesture: SequenceGesture(MagnificationGesture(), RotationGesture()),
            value: sequenceGestureValue!,
            assertValue: assertSequenceGestureValue)
    }
    
    func testSequenceGestureCallOnEndedFailure() throws {
        try gestureCallOnEndedFailureTest(
            gesture: SequenceGesture(MagnificationGesture(), RotationGesture()),
            value: sequenceGestureValue!)
    }
    
    #if os(macOS)
    func testSequenceGestureModifiers() throws {
        try gestureModifiersTest(gesture: SequenceGesture(MagnificationGesture(), RotationGesture()))
    }
        
    func testSequenceGestureModifiersNotFirst() throws {
        try gestureModifiersNotFirstTest(
            gesture: SequenceGesture(MagnificationGesture(), RotationGesture()),
            value: sequenceGestureValue!)
    }
    
    func testSequenceGestureModifiersMultiple() throws {
        try gestureModifiersMultipleTest(gesture: SequenceGesture(MagnificationGesture(), RotationGesture()))
    }
    
    func testSequenceGestureModifiersNone() throws {
        try gestureModifiersNoneTest(gesture: SequenceGesture(MagnificationGesture(), RotationGesture()))
    }
    #endif
    
    func testSequenceGestureChildren() throws {
        try composedGestureTest(
            type: SequenceGesture<MagnificationGesture, RotationGesture>.self,
            order: .first) { first, second in SequenceGesture(first, second)
        }
        try composedGestureTest(
            type: SequenceGesture<MagnificationGesture, RotationGesture>.self,
            order: .second) { first, second in SequenceGesture(first, second)
        }
    }
    
    func testSequenceGestureChildrenFailure() throws {
        try composedGestureFailureTest(
            type: SequenceGesture<MagnificationGesture, RotationGesture>.self,
            order: .first) { first, second in SequenceGesture(first, second)
        }
        try composedGestureFailureTest(
            type: SequenceGesture<MagnificationGesture, RotationGesture>.self,
            order: .second) { first, second in
            SequenceGesture(first, second)
        }
    }

    func testSequenceGestureChildrenCallUpdating() throws {
        try composedGestureCallUpdatingTest(
            type: SequenceGesture<MagnificationGesture, RotationGesture>.self,
            order: .first) { first, second in SequenceGesture(first, second)
        }
        try composedGestureCallUpdatingTest(
            type: SequenceGesture<MagnificationGesture, RotationGesture>.self,
            order: .second) { first, second in SequenceGesture(first, second)
        }
    }
    
    func testSequenceGestureChildrenCallUpdatingNotFirst() throws {
        try composedGestureCallUpdatingNotFirstTest(
            type: SequenceGesture<MagnificationGesture, RotationGesture>.self,
            order: .first) { first, second in SequenceGesture(first, second)
        }
        try composedGestureCallUpdatingNotFirstTest(
            type: SequenceGesture<MagnificationGesture, RotationGesture>.self,
            order: .second) { first, second in SequenceGesture(first, second)
        }
    }
    
    func testSequenceGestureChildrenCallUpdatingMultiple() throws {
        try composedGestureCallUpdatingMultipleTest(
            type: SequenceGesture<MagnificationGesture, RotationGesture>.self,
            order: .first) { first, second in SequenceGesture(first, second)
        }
        try composedGestureCallUpdatingMultipleTest(
            type: SequenceGesture<MagnificationGesture, RotationGesture>.self,
            order: .second) { first, second in SequenceGesture(first, second)
        }
    }
    
    func testSequenceGestureChildrenCallUpdatingFailure() throws {
        try composedGestureCallUpdatingFailureTest(
            type: SequenceGesture<MagnificationGesture, RotationGesture>.self,
            order: .first) { first, second in SequenceGesture(first, second)
        }
        try composedGestureCallUpdatingFailureTest(
            type: SequenceGesture<MagnificationGesture, RotationGesture>.self,
            order: .second) { first, second in SequenceGesture(first, second)
        }
    }

    func testSequenceGestureChildrenCallChanged() throws {
        try composedGestureCallChangedTest(
            type: SequenceGesture<MagnificationGesture, RotationGesture>.self,
            order: .first) { first, second in SequenceGesture(first, second)
        }
        try composedGestureCallChangedTest(
            type: SequenceGesture<MagnificationGesture, RotationGesture>.self,
            order: .second) { first, second in SequenceGesture(first, second)
        }
    }
    
    func testSequenceGestureChildrenCallChangedNotFirst() throws {
        try composedGestureCallChangedNotFirstTest(
            type: SequenceGesture<MagnificationGesture, RotationGesture>.self,
            order: .first) { first, second in SequenceGesture(first, second)
        }
        try composedGestureCallChangedNotFirstTest(
            type: SequenceGesture<MagnificationGesture, RotationGesture>.self,
            order: .second) { first, second in SequenceGesture(first, second)
        }
    }
    
    func testSequenceGestureFirstCallChangedMultiple() throws {
        try composedGestureCallChangedMultipleTest(
            type: SequenceGesture<MagnificationGesture, RotationGesture>.self,
            order: .first) { first, second in SequenceGesture(first, second)
        }
        try composedGestureCallChangedMultipleTest(
            type: SequenceGesture<MagnificationGesture, RotationGesture>.self,
            order: .second) { first, second in SequenceGesture(first, second)
        }
    }
    
    func testSequenceGestureChildrenCallChangedFailure() throws {
        try composedGestureCallChangedFailureTest(
            type: SequenceGesture<MagnificationGesture, RotationGesture>.self,
            order: .first) { first, second in SequenceGesture(first, second)
        }
        try composedGestureCallChangedFailureTest(
            type: SequenceGesture<MagnificationGesture, RotationGesture>.self,
            order: .second) { first, second in SequenceGesture(first, second)
        }
    }
    
    func testSequenceGestureChildrenCallEnded() throws {
        try composedGestureCallEndedTest(
            type: SequenceGesture<MagnificationGesture, RotationGesture>.self,
            order: .first) { first, second in SequenceGesture(first, second)
        }
        try composedGestureCallEndedTest(
            type: SequenceGesture<MagnificationGesture, RotationGesture>.self,
            order: .second) { first, second in SequenceGesture(first, second)
        }
    }

    func testSequenceGestureChildrenCallEndedNotFirst() throws {
        try composedGestureCallEndedNotFirstTest(
            type: SequenceGesture<MagnificationGesture, RotationGesture>.self,
            order: .first) { first, second in SequenceGesture(first, second)
        }
        try composedGestureCallEndedNotFirstTest(
            type: SequenceGesture<MagnificationGesture, RotationGesture>.self,
            order: .second) { first, second in SequenceGesture(first, second)
        }
    }

    func testSequenceGestureChildrenCallEndedMultiple() throws {
        try composedGestureCallEndedMultipleTest(
            type: SequenceGesture<MagnificationGesture, RotationGesture>.self,
            order: .first) { first, second in SequenceGesture(first, second)
        }
        try composedGestureCallEndedMultipleTest(
            type: SequenceGesture<MagnificationGesture, RotationGesture>.self,
            order: .second) { first, second in SequenceGesture(first, second)
        }
    }
    
    func testSequenceGestureChildrenCallEndedFailure() throws {
        try composedGestureCallEndedFailureTest(
            type: SequenceGesture<MagnificationGesture, RotationGesture>.self,
            order: .first) { first, second in SequenceGesture(first, second)
        }
        try composedGestureCallEndedFailureTest(
            type: SequenceGesture<MagnificationGesture, RotationGesture>.self,
            order: .second) { first, second in SequenceGesture(first, second)
        }
    }
    
    #if os(macOS)
    func testSequenceGestureChildrenModifiers() throws {
        try composedGestureModifiersTest(
            type: SequenceGesture<MagnificationGesture, RotationGesture>.self,
            order: .first) { first, second in SequenceGesture(first, second)
        }
        try composedGestureModifiersTest(
            type: SequenceGesture<MagnificationGesture, RotationGesture>.self,
            order: .second) { first, second in SequenceGesture(first, second)
        }
    }
    
    func testSequenceGestureChildrenModifiersNodifiersNotFirst() throws {
        try composedGestureModifiersNotFirstTest(
            type: SequenceGesture<MagnificationGesture, RotationGesture>.self,
            order: .first) { first, second in SequenceGesture(first, second)
        }
        try composedGestureModifiersNotFirstTest(
            type: SequenceGesture<MagnificationGesture, RotationGesture>.self,
            order: .second) { first, second in SequenceGesture(first, second)
        }
    }

    func testSequenceGestureChildrenModifiersNodifiersMultiple() throws {
        try composedGestureModifiersMultipleTest(
            type: SequenceGesture<MagnificationGesture, RotationGesture>.self,
            order: .first) { first, second in SequenceGesture(first, second)
        }
        try composedGestureModifiersMultipleTest(
            type: SequenceGesture<MagnificationGesture, RotationGesture>.self,
            order: .second) { first, second in SequenceGesture(first, second)
        }
    }
    
    func testSequenceGestureChildrenModifiersNone() throws {
        try composedGestureModifiersFailureTest(
            type: SequenceGesture<MagnificationGesture, RotationGesture>.self,
            order: .first) { first, second in SequenceGesture(first, second)
        }
        try composedGestureModifiersFailureTest(
            type: SequenceGesture<MagnificationGesture, RotationGesture>.self,
            order: .second) { first, second in SequenceGesture(first, second)
        }
    }
    #endif

    func assertSequenceGestureValue(_ value: SequenceGesture<MagnificationGesture, RotationGesture>.Value, file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertEqual(value, sequenceGestureValue, file: file, line: line)
    }
    
    // MARK: - Simultaneous Gesture Tests
    
    func testCreateSimultaneousGestureValue() throws {
        XCTAssertNotNil(magnificationValue)
        XCTAssertNotNil(rotationValue)
        let value = try XCTUnwrap(simultaneousGestureValue)
        assertSimultaneousGestureValue(value)
    }
    
    func testSimultaneousGestureGestureMask() throws {
        try gestureMaskTest(SimultaneousGesture(MagnificationGesture(), RotationGesture()))
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
        try gesturePropertiesWithUpdatingModifierTest(SimultaneousGesture(MagnificationGesture(), RotationGesture()))
    }
    
    func testSimultaneousGestureWithOnChangedModifier() throws {
        try gesturePropertiesWithOnChangedModifierTest(SimultaneousGesture(MagnificationGesture(), RotationGesture()))
    }
    
    func testSimultaneousGestureWithOnEndedModifier() throws {
        try gesturePropertiesWithOnEndedModifierTest(SimultaneousGesture(MagnificationGesture(), RotationGesture()))
    }
    
    #if os(macOS)
    func testSimultaneousGestureWithModifiers() throws {
        try gesturePropertiesWithModifiersTest(SimultaneousGesture(MagnificationGesture(), RotationGesture()))
    }
    #endif
    
    func testSimultaneousGestureFailure() throws {
        try gesturePropertiesFailureTest(SimultaneousGesture(MagnificationGesture(), RotationGesture()))
    }
    
    func testSimultaneousGestureCallUpdating() throws {
        try gestureCallUpdating(
            gesture: SimultaneousGesture(MagnificationGesture(), RotationGesture()),
            value: simultaneousGestureValue!,
            assertValue: assertSimultaneousGestureValue)
    }
    
    func testSimultaneousGestureCallUpdatingNotFirst() throws {
        try gestureCallUpdatingNotFirstTest(
            gesture: SimultaneousGesture(MagnificationGesture(), RotationGesture()),
            value: simultaneousGestureValue!,
            assertValue: assertSimultaneousGestureValue)
    }

    func testSimultaneousGestureCallUpdatingMultiple() throws {
        try gestureCallUpdatingMultipleTest(
            gesture: SimultaneousGesture(MagnificationGesture(), RotationGesture()),
            value: simultaneousGestureValue!,
            assertValue: assertSimultaneousGestureValue)
    }
    
    func testSimultaneousGestureCallUpdatingFailure() throws {
        try gestureCallUpdatingFailureTest(
            gesture: SimultaneousGesture(MagnificationGesture(), RotationGesture()),
            value: simultaneousGestureValue!)
    }

    func testSimultaneousGestureCallOnEnded() throws {
        try gestureCallOnEndedTest(
            gesture: SimultaneousGesture(MagnificationGesture(), RotationGesture()),
            value: simultaneousGestureValue!,
            assertValue: assertSimultaneousGestureValue)
    }
    
    func testSimultaneousGestureCallOnEndedNotFirst() throws {
        try gestureCallOnEndedNotFirstTest(
            gesture: SimultaneousGesture(MagnificationGesture(), RotationGesture()),
            value: simultaneousGestureValue!,
            assertValue: assertSimultaneousGestureValue)
    }

    func testSimultaneousGestureCallOnEndedMultiple() throws {
        try gestureCallOnEndedMultipleTest(
            gesture: SimultaneousGesture(MagnificationGesture(), RotationGesture()),
            value: simultaneousGestureValue!,
            assertValue: assertSimultaneousGestureValue)
    }
    
    func testSimultaneousGestureCallOnEndedFailure() throws {
        try gestureCallOnEndedFailureTest(
            gesture: SimultaneousGesture(MagnificationGesture(), RotationGesture()),
            value: simultaneousGestureValue!)
    }
    
    #if os(macOS)
    func testSimultaneousGestureModifiers() throws {
        try gestureModifiersTest(gesture: SimultaneousGesture(MagnificationGesture(), RotationGesture()))
    }
        
    func testSimultaneousGestureModifiersNotFirst() throws {
        try gestureModifiersNotFirstTest(
            gesture: SimultaneousGesture(MagnificationGesture(), RotationGesture()),
            value: simultaneousGestureValue!)
    }
    
    func testSimultaneousGestureModifiersMultiple() throws {
        try gestureModifiersMultipleTest(gesture: SimultaneousGesture(MagnificationGesture(), RotationGesture()))
    }
    
    func testSimultaneousGestureModifiersNone() throws {
        try gestureModifiersNoneTest(gesture: SimultaneousGesture(MagnificationGesture(), RotationGesture()))
    }
    #endif
    
    func testSimultaneousGestureChildren() throws {
        try composedGestureTest(
            type: SimultaneousGesture<MagnificationGesture, RotationGesture>.self,
            order: .first) { first, second in SimultaneousGesture(first, second)
        }
        try composedGestureTest(
            type: SimultaneousGesture<MagnificationGesture, RotationGesture>.self,
            order: .second) { first, second in SimultaneousGesture(first, second)
        }
    }
    
    func testSimultaneousGestureChildrenFailure() throws {
        try composedGestureFailureTest(
            type: SimultaneousGesture<MagnificationGesture, RotationGesture>.self,
            order: .first) { first, second in SimultaneousGesture(first, second)
        }
        try composedGestureFailureTest(
            type: SimultaneousGesture<MagnificationGesture, RotationGesture>.self,
            order: .second) { first, second in SimultaneousGesture(first, second)
        }
    }

    func testSimultaneousGestureChildrenCallUpdating() throws {
        try composedGestureCallUpdatingTest(
            type: SimultaneousGesture<MagnificationGesture, RotationGesture>.self,
            order: .first) { first, second in SimultaneousGesture(first, second)
        }
        try composedGestureCallUpdatingTest(
            type: SimultaneousGesture<MagnificationGesture, RotationGesture>.self,
            order: .second) { first, second in SimultaneousGesture(first, second)
        }
    }
    
    func testSimultaneousGestureChildrenCallUpdatingNotFirst() throws {
        try composedGestureCallUpdatingNotFirstTest(
            type: SimultaneousGesture<MagnificationGesture, RotationGesture>.self,
            order: .first) { first, second in SimultaneousGesture(first, second)
        }
        try composedGestureCallUpdatingNotFirstTest(
            type: SimultaneousGesture<MagnificationGesture, RotationGesture>.self,
            order: .second) { first, second in SimultaneousGesture(first, second)
        }
    }
    
    func testSimultaneousGestureChildrenCallUpdatingMultiple() throws {
        try composedGestureCallUpdatingMultipleTest(
            type: SimultaneousGesture<MagnificationGesture, RotationGesture>.self,
            order: .first) { first, second in SimultaneousGesture(first, second)
        }
        try composedGestureCallUpdatingMultipleTest(
            type: SimultaneousGesture<MagnificationGesture, RotationGesture>.self,
            order: .second) { first, second in SimultaneousGesture(first, second)
        }
    }
    
    func testSimultaneousGestureChildrenCallUpdatingFailure() throws {
        try composedGestureCallUpdatingFailureTest(
            type: SimultaneousGesture<MagnificationGesture, RotationGesture>.self,
            order: .first) { first, second in SimultaneousGesture(first, second)
        }
        try composedGestureCallUpdatingFailureTest(
            type: SimultaneousGesture<MagnificationGesture, RotationGesture>.self,
            order: .second) { first, second in SimultaneousGesture(first, second)
        }
    }

    func testSimultaneousGestureChildrenCallChanged() throws {
        try composedGestureCallChangedTest(
            type: SimultaneousGesture<MagnificationGesture, RotationGesture>.self,
            order: .first) { first, second in SimultaneousGesture(first, second)
        }
        try composedGestureCallChangedTest(
            type: SimultaneousGesture<MagnificationGesture, RotationGesture>.self,
            order: .second) { first, second in SimultaneousGesture(first, second)
        }
    }
    
    func testSimultaneousGestureChildrenCallChangedNotFirst() throws {
        try composedGestureCallChangedNotFirstTest(
            type: SimultaneousGesture<MagnificationGesture, RotationGesture>.self,
            order: .first) { first, second in SimultaneousGesture(first, second)
        }
        try composedGestureCallChangedNotFirstTest(
            type: SimultaneousGesture<MagnificationGesture, RotationGesture>.self,
            order: .second) { first, second in SimultaneousGesture(first, second)
        }
    }
    
    func testSimultaneousGestureFirstCallChangedMultiple() throws {
        try composedGestureCallChangedMultipleTest(
            type: SimultaneousGesture<MagnificationGesture, RotationGesture>.self,
            order: .first) { first, second in SimultaneousGesture(first, second)
        }
        try composedGestureCallChangedMultipleTest(
            type: SimultaneousGesture<MagnificationGesture, RotationGesture>.self,
            order: .second) { first, second in SimultaneousGesture(first, second)
        }
    }
    
    func testSimultaneousGestureChildrenCallChangedFailure() throws {
        try composedGestureCallChangedFailureTest(
            type: SimultaneousGesture<MagnificationGesture, RotationGesture>.self,
            order: .first) { first, second in SimultaneousGesture(first, second)
        }
        try composedGestureCallChangedFailureTest(
            type: SimultaneousGesture<MagnificationGesture, RotationGesture>.self,
            order: .second) { first, second in SimultaneousGesture(first, second)
        }
    }
    
    func testSimultaneousGestureChildrenCallEnded() throws {
        try composedGestureCallEndedTest(
            type: SimultaneousGesture<MagnificationGesture, RotationGesture>.self,
            order: .first) { first, second in SimultaneousGesture(first, second)
        }
        try composedGestureCallEndedTest(
            type: SimultaneousGesture<MagnificationGesture, RotationGesture>.self,
            order: .second) { first, second in SimultaneousGesture(first, second)
        }
    }

    func testSimultaneousGestureChildrenCallEndedNotFirst() throws {
        try composedGestureCallEndedNotFirstTest(
            type: SimultaneousGesture<MagnificationGesture, RotationGesture>.self,
            order: .first) { first, second in SimultaneousGesture(first, second)
        }
        try composedGestureCallEndedNotFirstTest(
            type: SimultaneousGesture<MagnificationGesture, RotationGesture>.self,
            order: .second) { first, second in SimultaneousGesture(first, second)
        }
    }

    func testSimultaneousGestureChildrenCallEndedMultiple() throws {
        try composedGestureCallEndedMultipleTest(
            type: SimultaneousGesture<MagnificationGesture, RotationGesture>.self,
            order: .first) { first, second in SimultaneousGesture(first, second)
        }
        try composedGestureCallEndedMultipleTest(
            type: SimultaneousGesture<MagnificationGesture, RotationGesture>.self,
            order: .second) { first, second in SimultaneousGesture(first, second)
        }
    }
    
    func testSimultaneousGestureChildrenCallEndedFailure() throws {
        try composedGestureCallEndedFailureTest(
            type: SimultaneousGesture<MagnificationGesture, RotationGesture>.self,
            order: .first) { first, second in SimultaneousGesture(first, second)
        }
        try composedGestureCallEndedFailureTest(
            type: SimultaneousGesture<MagnificationGesture, RotationGesture>.self,
            order: .second) { first, second in SimultaneousGesture(first, second)
        }
    }
    
    #if os(macOS)
    func testSimultaneousGestureChildrenModifiers() throws {
        try composedGestureModifiersTest(
            type: SimultaneousGesture<MagnificationGesture, RotationGesture>.self,
            order: .first) { first, second in SimultaneousGesture(first, second)
        }
        try composedGestureModifiersTest(
            type: SimultaneousGesture<MagnificationGesture, RotationGesture>.self,
            order: .second) { first, second in SimultaneousGesture(first, second)
        }
    }
    
    func testSimultaneousGestureChildrenModifiersNodifiersNotFirst() throws {
        try composedGestureModifiersNotFirstTest(
            type: SimultaneousGesture<MagnificationGesture, RotationGesture>.self,
            order: .first) { first, second in SimultaneousGesture(first, second)
        }
        try composedGestureModifiersNotFirstTest(
            type: SimultaneousGesture<MagnificationGesture, RotationGesture>.self,
            order: .second) { first, second in SimultaneousGesture(first, second)
        }
    }

    func testSimultaneousGestureChildrenModifiersNodifiersMultiple() throws {
        try composedGestureModifiersMultipleTest(
            type: SimultaneousGesture<MagnificationGesture, RotationGesture>.self,
            order: .first) { first, second in SimultaneousGesture(first, second)
        }
        try composedGestureModifiersMultipleTest(
            type: SimultaneousGesture<MagnificationGesture, RotationGesture>.self,
            order: .second) { first, second in SimultaneousGesture(first, second)
        }
    }
    
    func testSimultaneousGestureChildrenModifiersNone() throws {
        try composedGestureModifiersFailureTest(
            type: SimultaneousGesture<MagnificationGesture, RotationGesture>.self,
            order: .first) { first, second in SimultaneousGesture(first, second)
        }
        try composedGestureModifiersFailureTest(
            type: SimultaneousGesture<MagnificationGesture, RotationGesture>.self,
            order: .second) { first, second in SimultaneousGesture(first, second)
        }
    }
    #endif

    func assertSimultaneousGestureValue(_ value: SimultaneousGesture<MagnificationGesture, RotationGesture>.Value, file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertEqual(value, simultaneousGestureValue, file: file, line: line)
    }
    
    // MARK: - Common Test Support
    
    func gestureMaskTest<T>(_ gesture: T, file: StaticString = #filePath, line: UInt = #line) throws
    where T: Gesture & Inspectable
    {
        let sut = EmptyView().gesture(gesture, including: .subviews)
        XCTAssertEqual(try sut.inspect().emptyView().gesture(T.self).gestureMask(), .subviews, file: file, line: line)
    }
    
    func gesturePropertiesWithUpdatingModifierTest<T>(_ gesture: T, file: StaticString = #filePath, line: UInt = #line) throws
    where T: Gesture & Inspectable
    {
        let modifiedGesture = gesture
            .updating($gestureState) { value, state, transaction in }
        let sut = EmptyView().gesture(modifiedGesture)
        XCTAssertNoThrow(try sut.inspect().emptyView().gesture(T.self).gestureProperties() as T, file: file, line: line)
    }

    func gesturePropertiesWithOnChangedModifierTest<T>(_ gesture: T, file: StaticString = #filePath, line: UInt = #line) throws
    where T: Gesture & Inspectable, T.Value: Equatable
    {
        let modifiedGesture = gesture
            .onChanged { value in }
        let sut = EmptyView().gesture(modifiedGesture)
        XCTAssertNoThrow(try sut.inspect().emptyView().gesture(T.self).gestureProperties() as T, file: file, line: line)
    }

    func gesturePropertiesWithOnEndedModifierTest<T>(_ gesture: T, file: StaticString = #filePath, line: UInt = #line) throws
    where T: Gesture & Inspectable
    {
        let modifiedGesture = gesture
            .onEnded { value in }
        let sut = EmptyView().gesture(modifiedGesture)
        XCTAssertNoThrow(try sut.inspect().emptyView().gesture(T.self).gestureProperties() as T, file: file, line: line)
    }

    #if os(macOS)
    func gesturePropertiesWithModifiersTest<T>(_ gesture: T, file: StaticString = #filePath, line: UInt = #line) throws
    where T: Gesture & Inspectable
    {
        let modifiedGesture = gesture
            .modifiers(.shift)
        let sut = EmptyView().gesture(modifiedGesture)
        XCTAssertNoThrow(try sut.inspect().emptyView().gesture(T.self).gestureProperties() as T, file: file, line: line)
    }
    #endif

    func gesturePropertiesFailureTest<T>(_ gesture: T, file: StaticString = #filePath, line: UInt = #line) throws
    where T: Gesture & Inspectable
    {
        let sut = EmptyView()
        XCTAssertThrowsError(try sut.inspect().emptyView().gesture(T.self).gestureProperties() as T, file: file, line: line)
    }
    
    func gestureCallUpdating<T>(
        gesture: T,
        value: T.Value,
        assertValue: @escaping (T.Value, StaticString, UInt) -> (),
        file: StaticString = #filePath,
        line: UInt = #line) throws
    where T: Gesture & Inspectable
    {
        let exp = XCTestExpectation(description: "updating")
        let modifiedGesture = gesture
            .updating($gestureState) { value, state, transaction in
                assertValue(value, file, line)
                exp.fulfill()
            }
        let sut = EmptyView().gesture(modifiedGesture)
        var state = CGSize.zero
        var transaction = Transaction()
        try sut.inspect().emptyView().gesture(T.self).gestureCallUpdating(value: value, state: &state, transaction: &transaction)
        wait(for: [exp], timeout: 0.1)
    }
    
    func gestureCallUpdatingNotFirstTest<T>(
        gesture: T,
        value: T.Value,
        assertValue: @escaping (T.Value, StaticString, UInt) -> (),
        file: StaticString = #filePath,
        line: UInt = #line) throws
    where T: Gesture & Inspectable
    {
        let exp = XCTestExpectation(description: "updating")
        let modifiedGesture = gesture
            .onEnded { value in }
            .updating($gestureState) { value, state, transaction in
                assertValue(value, file, line)
                exp.fulfill()
            }
        let sut = EmptyView().gesture(modifiedGesture)
        var state = CGSize.zero
        var transaction = Transaction()
        try sut.inspect().emptyView().gesture(T.self).gestureCallUpdating(value: value, state: &state, transaction: &transaction)
        wait(for: [exp], timeout: 0.1)
    }

    func gestureCallUpdatingMultipleTest<T>(
        gesture: T,
        value: T.Value,
        assertValue: @escaping (T.Value, StaticString, UInt) -> (),
        file: StaticString = #filePath,
        line: UInt = #line) throws
    where T: Gesture & Inspectable
    {
        let exp1 = XCTestExpectation(description: "updating1")
        let exp2 = XCTestExpectation(description: "updating2")
        let modifiedGesture = gesture
            .updating($gestureState) { value, state, transaction in
                assertValue(value, file, line)
                exp1.fulfill()
            }
            .updating($gestureState) { value, state, transaction in
                assertValue(value, file, line)
                exp2.fulfill()
            }
        let sut = EmptyView().gesture(modifiedGesture)
        var state = CGSize.zero
        var transaction = Transaction()
        try sut.inspect().emptyView().gesture(T.self).gestureCallUpdating(value: value, state: &state, transaction: &transaction)
        wait(for: [exp1, exp2], timeout: 0.1)
    }
    
    func gestureCallUpdatingFailureTest<T>(
        gesture: T,
        value: T.Value,
        file: StaticString = #filePath,
        line: UInt = #line) throws
    where T: Gesture & Inspectable
    {
        let sut = EmptyView().gesture(gesture)
        var state = CGSize.zero
        var transaction = Transaction()
        XCTAssertThrowsError(try sut.inspect().gesture(T.self).gestureCallUpdating(value: value, state: &state, transaction: &transaction))
    }

    func gestureCallOnChangedTest<T>(
        gesture: T,
        value: T.Value,
        assertValue: @escaping (T.Value, StaticString, UInt) -> (),
        file: StaticString = #filePath,
        line: UInt = #line) throws
    where T: Gesture & Inspectable, T.Value: Equatable
    {
        let exp = XCTestExpectation(description: "onChanged")
        let modifiedGesture = gesture
            .onChanged { value in
                assertValue(value, file, line)
                exp.fulfill()
            }
        let sut = EmptyView().gesture(modifiedGesture)
    try sut.inspect().emptyView().gesture(T.self).gestureCallChanged(value: value)
        wait(for: [exp], timeout: 0.1)
    }

    func gestureCallOnChangedNotFirstTest<T>(
        gesture: T,
        value: T.Value,
        assertValue: @escaping (T.Value, StaticString, UInt) -> (),
        file: StaticString = #filePath,
        line: UInt = #line) throws
    where T: Gesture & Inspectable, T.Value: Equatable
    {
        let exp = XCTestExpectation(description: "onChanged")
        let modifiedGesture = gesture
            .onEnded { value in }
            .onChanged { value in
                assertValue(value, file, line)
                exp.fulfill()
            }
        let sut = EmptyView().gesture(modifiedGesture)
        try sut.inspect().emptyView().gesture(T.self).gestureCallChanged(value: value)
        wait(for: [exp], timeout: 0.1)
    }

    func gestureCallOnChangedMultipleTest<T>(
        gesture: T,
        value: T.Value,
        assertValue: @escaping (T.Value, StaticString, UInt) -> (),
        file: StaticString = #filePath,
        line: UInt = #line) throws
    where T: Gesture & Inspectable, T.Value: Equatable
    {
        let exp1 = XCTestExpectation(description: "onChanged1")
        let exp2 = XCTestExpectation(description: "onChanged2")
        let modifiedGesture = gesture
            .onChanged { value in
                assertValue(value, file, line)
                exp1.fulfill()
            }
            .onChanged { value in
                assertValue(value, file, line)
                exp2.fulfill()
            }
        let sut = EmptyView().gesture(modifiedGesture)
        try sut.inspect().emptyView().gesture(T.self).gestureCallChanged(value: value)
        wait(for: [exp1, exp2], timeout: 0.1)
    }

    func gestureCallOnChangedFailureTest<T>(
        gesture: T,
        value: T.Value,
        file: StaticString = #filePath,
        line: UInt = #line) throws
    where T: Gesture & Inspectable, T.Value: Equatable
    {
        let sut = EmptyView().gesture(gesture)
        XCTAssertThrowsError(try sut.inspect().gesture(T.self).gestureCallChanged(value: value))
    }
    
    func gestureCallOnEndedTest<T>(
        gesture: T,
        value: T.Value,
        assertValue: @escaping (T.Value, StaticString, UInt) -> (),
        file: StaticString = #filePath,
        line: UInt = #line) throws
    where T: Gesture & Inspectable
    {
        let exp = XCTestExpectation(description: "onEnded")
        let modifiedGesture = gesture
            .onEnded { value in
                assertValue(value, file, line)
                exp.fulfill()
            }
        let sut = EmptyView().gesture(modifiedGesture)
        
        try sut.inspect().emptyView().gesture(T.self).gestureCallEnded(value: value)
        wait(for: [exp], timeout: 0.1)
    }

    func gestureCallOnEndedNotFirstTest<T>(
        gesture: T,
        value: T.Value,
        assertValue: @escaping (T.Value, StaticString, UInt) -> (),
        file: StaticString = #filePath,
        line: UInt = #line) throws
    where T: Gesture & Inspectable
    {
        let exp = XCTestExpectation(description: "onEnded")
        let modifiedGesture = gesture
            .updating($gestureState) { value, state, transaction in }
            .onEnded { value in
                assertValue(value, file, line)
                exp.fulfill()
            }
        let sut = EmptyView().gesture(modifiedGesture)
        
        try sut.inspect().emptyView().gesture(T.self).gestureCallEnded(value: value)
        wait(for: [exp], timeout: 0.1)
    }

    func gestureCallOnEndedMultipleTest<T>(
        gesture: T,
        value: T.Value,
        assertValue: @escaping (T.Value, StaticString, UInt) -> (),
        file: StaticString = #filePath,
        line: UInt = #line) throws
    where T: Gesture & Inspectable
    {
        let exp1 = XCTestExpectation(description: "onEnded1")
        let exp2 = XCTestExpectation(description: "onEnded2")
        let modifiedGesture = gesture
            .onEnded { value in
                assertValue(value, file, line)
                exp1.fulfill()
            }
            .onEnded { value in
                assertValue(value, file, line)
                exp2.fulfill()
            }
        let sut = EmptyView().gesture(modifiedGesture)
        
        try sut.inspect().emptyView().gesture(T.self).gestureCallEnded(value: value)
        wait(for: [exp1, exp2], timeout: 0.1)
    }
    
    func gestureCallOnEndedFailureTest<T>(
        gesture: T,
        value: T.Value,
        file: StaticString = #filePath,
        line: UInt = #line) throws
    where T: Gesture & Inspectable
    {
        let sut = EmptyView().gesture(gesture)
        XCTAssertThrowsError(try sut.inspect().gesture(T.self).gestureCallEnded(value: value))
    }
    
    #if os(macOS)
    func gestureModifiersTest<T>(
        gesture: T,
        file: StaticString = #filePath,
        line: UInt = #line) throws
    where T: Gesture & Inspectable
    {
        let modifiedGesture = gesture
            .modifiers(.shift)
        let sut = EmptyView().gesture(modifiedGesture)
        XCTAssertEqual(try sut.inspect().emptyView().gesture(T.self).gestureModifiers(), .shift, file: file, line: line)
    }

    func gestureModifiersNotFirstTest<T>(
        gesture: T,
        value: T.Value,
        file: StaticString = #filePath,
        line: UInt = #line) throws
    where T: Gesture & Inspectable
    {
        let modifiedGesture = gesture
            .onEnded { value in }
            .modifiers(.shift)
        let sut = EmptyView().gesture(modifiedGesture)
        XCTAssertEqual(try sut.inspect().emptyView().gesture(T.self).gestureModifiers(), .shift, file: file, line: line)
    }
    
    func gestureModifiersMultipleTest<T>(
        gesture: T,
        file: StaticString = #filePath,
        line: UInt = #line) throws
    where T: Gesture & Inspectable
    {
        let modifiedGesture = gesture
            .modifiers(.shift)
            .modifiers(.control)
        let sut = EmptyView().gesture(modifiedGesture)
        XCTAssertEqual(try sut.inspect().emptyView().gesture(T.self).gestureModifiers(), [.shift, .control], file: file, line: line)
    }

    func gestureModifiersNoneTest<T>(
        gesture: T,
        file: StaticString = #filePath,
        line: UInt = #line) throws
    where T: Gesture & Inspectable
    {
        let sut = EmptyView().gesture(gesture)
        XCTAssertEqual(try sut.inspect().emptyView().gesture(T.self).gestureModifiers(), [], file: file, line: line)
    }
    #endif
    
    func composedGestureTest<T, U>(
        type: U.Type,
        order: InspectableView<ViewType.Gesture<T>>.GestureOrder,
        file: StaticString = #filePath,
        line: UInt = #line,
        _ factory: (MagnificationGesture, RotationGesture) -> T) throws
    where T: Gesture & Inspectable, U: Gesture & Inspectable
    {
        let magnificationGesture = MagnificationGesture(minimumScaleDelta: 1.5)
        let rotationGesture = RotationGesture(minimumAngleDelta: Angle(degrees: 5))
        let sut = EmptyView().gesture(factory(magnificationGesture, rotationGesture))
        let composedGesture = try sut.inspect()
            .emptyView()
            .gesture(type)
        switch order {
        case .first:
            let firstGesture = try composedGesture.first(MagnificationGesture.self).gestureProperties()
            XCTAssertEqual(firstGesture.minimumScaleDelta, 1.5, file: file, line: line)
        case .second:
            let secondGesture = try composedGesture.second(RotationGesture.self).gestureProperties()
            XCTAssertEqual(secondGesture.minimumAngleDelta, Angle(degrees: 5), file: file, line: line)
        }
    }
    
    func composedGestureFailureTest<T, U>(
        type: U.Type,
        order: InspectableView<ViewType.Gesture<T>>.GestureOrder,
        file: StaticString = #filePath,
        line: UInt = #line,
        _ factory: (MagnificationGesture, RotationGesture) -> T) throws
    where T: Gesture & Inspectable, U: Gesture & Inspectable
    {
        let magnificationGesture = MagnificationGesture(minimumScaleDelta: 1.5)
        let rotationGesture = RotationGesture(minimumAngleDelta: Angle(degrees: 5))
        let sut = EmptyView().gesture(factory(magnificationGesture, rotationGesture))
        let gesture = try sut.inspect()
            .emptyView()
            .gesture(type)
        switch order {
        case .first:
            XCTAssertThrowsError(try gesture.first(TapGesture.self))
        case .second:
            XCTAssertThrowsError(try gesture.second(TapGesture.self))
        }
    }
    
    typealias ComposedGestureUpdating<T> =
        (GestureStateGesture<MagnificationGesture, CGSize>,
         GestureStateGesture<RotationGesture, CGSize>) -> T
    
    func composedGestureCallUpdatingTest<T, U>(
        type: U.Type,
        order: InspectableView<ViewType.Gesture<T>>.GestureOrder,
        file: StaticString = #filePath,
        line: UInt = #line,
        _ factory: ComposedGestureUpdating<T>) throws
    where T: Gesture & Inspectable, U: Gesture & Inspectable
    {
        let exp = XCTestExpectation(description: "updating")
        let magnificationGesture = MagnificationGesture(minimumScaleDelta: 1.5)
            .updating($gestureState) { value, state, transaction in
                self.assertMagnificationValue(value)
                exp.fulfill()
            }
        let rotationGesture = RotationGesture(minimumAngleDelta: Angle(degrees: 5))
            .updating($gestureState) { value, state, transaction in
                self.assertRotationValue(value)
                exp.fulfill()
            }
        let sut = EmptyView().gesture(factory(magnificationGesture, rotationGesture))
        var state = CGSize.zero
        var transaction = Transaction()
        let emptyView = try sut.inspect().emptyView()
        let gesture1 = try emptyView
            .gesture(type)
        switch order {
        case .first:
            let gesture2 = try gesture1.first(MagnificationGesture.self)
            try gesture2.gestureCallUpdating(value: magnificationValue!, state: &state, transaction: &transaction)
        case .second:
            let gesture2 = try gesture1.second(RotationGesture.self)
            try gesture2.gestureCallUpdating(value: rotationValue!, state: &state, transaction: &transaction)
        }
        wait(for: [exp], timeout: 0.1)
    }
    
    typealias ComposedGestureUpdatingNotFirst<T> =
        (GestureStateGesture<_EndedGesture<MagnificationGesture>, CGSize>,
         GestureStateGesture<_EndedGesture<RotationGesture>, CGSize>) -> T

    func composedGestureCallUpdatingNotFirstTest<T, U>(
        type: U.Type,
        order: InspectableView<ViewType.Gesture<T>>.GestureOrder,
        file: StaticString = #filePath,
        line: UInt = #line,
        _ factory: ComposedGestureUpdatingNotFirst<T>) throws
    where T: Gesture & Inspectable, U: Gesture & Inspectable
    {
        let exp = XCTestExpectation(description: "updating")
        let magnificationGesture = MagnificationGesture(minimumScaleDelta: 1.5)
            .onEnded { value in }
            .updating($gestureState) { value, state, transaction in
                self.assertMagnificationValue(value)
                exp.fulfill()
            }
        let rotationGesture = RotationGesture(minimumAngleDelta: Angle(degrees: 5))
            .onEnded { value in }
            .updating($gestureState) { value, state, transaction in
                self.assertRotationValue(value)
                exp.fulfill()
            }
        let sut = EmptyView().gesture(factory(magnificationGesture, rotationGesture))
        var state = CGSize.zero
        var transaction = Transaction()
        let emptyView = try sut.inspect().emptyView()
        let gesture1 = try emptyView
            .gesture(type)
        switch order {
        case .first:
            let gesture2 = try gesture1.first(MagnificationGesture.self)
            try gesture2.gestureCallUpdating(value: magnificationValue!, state: &state, transaction: &transaction)
        case .second:
            let gesture2 = try gesture1.second(RotationGesture.self)
            try gesture2.gestureCallUpdating(value: rotationValue!, state: &state, transaction: &transaction)
        }
        wait(for: [exp], timeout: 0.1)
    }
    
    typealias ComposedGestureUpdatingMultiple<T> =
        (GestureStateGesture<GestureStateGesture<MagnificationGesture, CGSize>, CGSize>,
         GestureStateGesture<GestureStateGesture<RotationGesture, CGSize>, CGSize>) -> T
    
    func composedGestureCallUpdatingMultipleTest<T, U>(
        type: U.Type,
        order: InspectableView<ViewType.Gesture<T>>.GestureOrder,
        file: StaticString = #filePath,
        line: UInt = #line,
        _ factory: ComposedGestureUpdatingMultiple<T>) throws
    where T: Gesture, T: Inspectable, U: Gesture, U: Inspectable
    {
        let exp1 = XCTestExpectation(description: "updating1")
        let exp2 = XCTestExpectation(description: "updating2")
        let magnificationGesture = MagnificationGesture(minimumScaleDelta: 1.5)
            .updating($gestureState) { value, state, transaction in
                self.assertMagnificationValue(value)
                exp1.fulfill()
            }
            .updating($gestureState) { value, state, transaction in
                self.assertMagnificationValue(value)
                exp2.fulfill()
            }
        let rotationGesture = RotationGesture(minimumAngleDelta: Angle(degrees: 5))
            .updating($gestureState) { value, state, transaction in
                self.assertRotationValue(value)
                exp1.fulfill()
            }
            .updating($gestureState) { value, state, transaction in
                self.assertRotationValue(value)
                exp2.fulfill()
            }
        let sut = EmptyView().gesture(factory(magnificationGesture, rotationGesture))
        var state = CGSize.zero
        var transaction = Transaction()
        let emptyView = try sut.inspect().emptyView()
        let gesture1 = try emptyView
            .gesture(type)
        switch order {
        case .first:
            let gesture2 = try gesture1.first(MagnificationGesture.self)
            try gesture2.gestureCallUpdating(value: magnificationValue!, state: &state, transaction: &transaction)
        case .second:
            let gesture2 = try gesture1.second(RotationGesture.self)
            try gesture2.gestureCallUpdating(value: rotationValue!, state: &state, transaction: &transaction)
        }
        wait(for: [exp1, exp2], timeout: 0.1)
    }
    
    func composedGestureCallUpdatingFailureTest<T, U>(
        type: U.Type,
        order: InspectableView<ViewType.Gesture<T>>.GestureOrder,
        file: StaticString = #filePath,
        line: UInt = #line,
        _ factory: (MagnificationGesture, RotationGesture) -> T) throws
    where T: Gesture & Inspectable, U: Gesture & Inspectable
    {
        let magnificationGesture = MagnificationGesture(minimumScaleDelta: 1.5)
        let rotationGesture = RotationGesture(minimumAngleDelta: Angle(degrees: 5))
        let sut = EmptyView().gesture(factory(magnificationGesture, rotationGesture))
        var state = CGSize.zero
        var transaction = Transaction()
        let gesture1 = try sut.inspect()
            .emptyView()
            .gesture(type)
        switch order {
        case .first:
            let gesture2 = try gesture1.first(MagnificationGesture.self)
            XCTAssertThrowsError(try gesture2.gestureCallUpdating(value: magnificationValue!, state: &state, transaction: &transaction))
        case .second:
            let gesture2 = try gesture1.second(RotationGesture.self)
            XCTAssertThrowsError(try gesture2.gestureCallUpdating(value: rotationValue!, state: &state, transaction: &transaction))
        }
    }
    
    typealias ComposedGestureChanged<T> =
        (_ChangedGesture<MagnificationGesture>,
         _ChangedGesture<RotationGesture>) -> T
    
    func composedGestureCallChangedTest<T, U>(
        type: U.Type,
        order: InspectableView<ViewType.Gesture<T>>.GestureOrder,
        file: StaticString = #filePath,
        line: UInt = #line,
        _ factory: ComposedGestureChanged<T>) throws
    where T: Gesture & Inspectable, U: Gesture & Inspectable
    {
        let exp = XCTestExpectation(description: "changed")
        let magnificationGesture = MagnificationGesture(minimumScaleDelta: 1.5)
            .onChanged { value in
                self.assertMagnificationValue(value)
                exp.fulfill()
            }
        let rotationGesture = RotationGesture(minimumAngleDelta: Angle(degrees: 5))
            .onChanged { value in
                self.assertRotationValue(value)
                exp.fulfill()
            }
        let sut = EmptyView().gesture(factory(magnificationGesture, rotationGesture))
        let emptyView = try sut.inspect().emptyView()
        let gesture1 = try emptyView
            .gesture(type)
        switch order {
        case .first:
            let gesture2 = try gesture1.first(MagnificationGesture.self)
            try gesture2.gestureCallChanged(value: magnificationValue!)
        case .second:
            let gesture2 = try gesture1.second(RotationGesture.self)
            try gesture2.gestureCallChanged(value: rotationValue!)
        }
        wait(for: [exp], timeout: 0.1)
    }

    typealias ComposedGestureChangedNotFirst<T> =
        (_ChangedGesture<_EndedGesture<MagnificationGesture>>,
         _ChangedGesture<_EndedGesture<RotationGesture>>) -> T
    
    func composedGestureCallChangedNotFirstTest<T, U>(
        type: U.Type,
        order: InspectableView<ViewType.Gesture<T>>.GestureOrder,
        file: StaticString = #filePath,
        line: UInt = #line,
        _ factory: ComposedGestureChangedNotFirst<T>) throws
    where T: Gesture & Inspectable, U: Gesture & Inspectable
    {
        let exp = XCTestExpectation(description: "changed")
        let magnificationGesture = MagnificationGesture(minimumScaleDelta: 1.5)
            .onEnded { value in }
            .onChanged { value in
                self.assertMagnificationValue(value)
                exp.fulfill()
            }
        let rotationGesture = RotationGesture(minimumAngleDelta: Angle(degrees: 5))
            .onEnded { value in }
            .onChanged { value in
                self.assertRotationValue(value)
                exp.fulfill()
            }
        let sut = EmptyView().gesture(factory(magnificationGesture, rotationGesture))
        let emptyView = try sut.inspect().emptyView()
        let gesture1 = try emptyView
            .gesture(type)
        switch order {
        case .first:
            let gesture2 = try gesture1.first(MagnificationGesture.self)
            try gesture2.gestureCallChanged(value: magnificationValue!)
        case .second:
            let gesture2 = try gesture1.second(RotationGesture.self)
            try gesture2.gestureCallChanged(value: rotationValue!)
        }
        wait(for: [exp], timeout: 0.1)
    }
    
    typealias ComposedGestureChangedMultiple<T> =
        (_ChangedGesture<_ChangedGesture<MagnificationGesture>>,
         _ChangedGesture<_ChangedGesture<RotationGesture>>) -> T
    
    func composedGestureCallChangedMultipleTest<T, U>(
        type: U.Type,
        order: InspectableView<ViewType.Gesture<T>>.GestureOrder,
        file: StaticString = #filePath,
        line: UInt = #line,
        _ factory: ComposedGestureChangedMultiple<T>) throws
    where T: Gesture & Inspectable, U: Gesture & Inspectable
    {
        let exp1 = XCTestExpectation(description: "changed1")
        let exp2 = XCTestExpectation(description: "changed2")
        let magnificationGesture = MagnificationGesture(minimumScaleDelta: 1.5)
            .onChanged { value in
                self.assertMagnificationValue(value)
                exp1.fulfill()
            }
            .onChanged { value in
                self.assertMagnificationValue(value)
                exp2.fulfill()
            }
        let rotationGesture = RotationGesture(minimumAngleDelta: Angle(degrees: 5))
            .onChanged { value in
                self.assertRotationValue(value)
                exp1.fulfill()
            }
            .onChanged { value in
                self.assertRotationValue(value)
                exp2.fulfill()
            }
        let sut = EmptyView().gesture(factory(magnificationGesture, rotationGesture))
        let emptyView = try sut.inspect().emptyView()
        let gesture1 = try emptyView
            .gesture(type)
        switch order {
        case .first:
            let gesture2 = try gesture1.first(MagnificationGesture.self)
            try gesture2.gestureCallChanged(value: magnificationValue!)
        case .second:
            let gesture2 = try gesture1.second(RotationGesture.self)
            try gesture2.gestureCallChanged(value: rotationValue!)
        }
        wait(for: [exp1, exp2], timeout: 0.1)
    }

    func composedGestureCallChangedFailureTest<T, U>(
        type: U.Type,
        order: InspectableView<ViewType.Gesture<T>>.GestureOrder,
        file: StaticString = #filePath,
        line: UInt = #line,
        _ factory: (MagnificationGesture, RotationGesture) -> T) throws
    where T: Gesture & Inspectable, U: Gesture & Inspectable
    {
        let magnificationGesture = MagnificationGesture(minimumScaleDelta: 1.5)
        let rotationGesture = RotationGesture(minimumAngleDelta: Angle(degrees: 5))
        let sut = EmptyView().gesture(factory(magnificationGesture, rotationGesture))
        let gesture1 = try sut.inspect()
            .emptyView()
            .gesture(type)
        switch order {
        case .first:
            let gesture2 = try gesture1.first(MagnificationGesture.self)
            XCTAssertThrowsError(try gesture2.gestureCallChanged(value: magnificationValue!))
        case .second:
            let gesture2 = try gesture1.second(RotationGesture.self)
            XCTAssertThrowsError(try gesture2.gestureCallChanged(value: rotationValue!))
        }
    }

    typealias ComposedGestureEnded<T> =
        (_EndedGesture<MagnificationGesture>,
         _EndedGesture<RotationGesture>) -> T
    
    func composedGestureCallEndedTest<T, U>(
        type: U.Type,
        order: InspectableView<ViewType.Gesture<T>>.GestureOrder,
        file: StaticString = #filePath,
        line: UInt = #line,
        _ factory: ComposedGestureEnded<T>) throws
    where T: Gesture & Inspectable, U: Gesture & Inspectable
    {
        let exp = XCTestExpectation(description: "ended")
        let magnificationGesture = MagnificationGesture(minimumScaleDelta: 1.5)
            .onEnded { value in
                self.assertMagnificationValue(value)
                exp.fulfill()
            }
        let rotationGesture = RotationGesture(minimumAngleDelta: Angle(degrees: 5))
            .onEnded { value in
                self.assertRotationValue(value)
                exp.fulfill()
            }
        let sut = EmptyView().gesture(factory(magnificationGesture, rotationGesture))
        let emptyView = try sut.inspect().emptyView()
        let gesture1 = try emptyView
            .gesture(type)
        switch order {
        case .first:
            let gesture2 = try gesture1.first(MagnificationGesture.self)
            try gesture2.gestureCallEnded(value: magnificationValue!)
        case .second:
            let gesture2 = try gesture1.second(RotationGesture.self)
            try gesture2.gestureCallEnded(value: rotationValue!)
        }
        wait(for: [exp], timeout: 0.1)
    }

    typealias ComposedGestureEndedNotFirst<T> =
        (_EndedGesture<_ChangedGesture<MagnificationGesture>>,
         _EndedGesture<_ChangedGesture<RotationGesture>>) -> T
    
    func composedGestureCallEndedNotFirstTest<T, U>(
        type: U.Type,
        order: InspectableView<ViewType.Gesture<T>>.GestureOrder,
        file: StaticString = #filePath,
        line: UInt = #line,
        _ factory: ComposedGestureEndedNotFirst<T>) throws
    where T: Gesture & Inspectable, U: Gesture & Inspectable
    {
        let exp = XCTestExpectation(description: "ended")
        let magnificationGesture = MagnificationGesture(minimumScaleDelta: 1.5)
            .onChanged { value in }
            .onEnded { value in
                self.assertMagnificationValue(value)
                exp.fulfill()
            }
        let rotationGesture = RotationGesture(minimumAngleDelta: Angle(degrees: 5))
            .onChanged { value in }
            .onEnded { value in
                self.assertRotationValue(value)
                exp.fulfill()
            }
        let sut = EmptyView().gesture(factory(magnificationGesture, rotationGesture))
        let emptyView = try sut.inspect().emptyView()
        let gesture1 = try emptyView
            .gesture(type)
        switch order {
        case .first:
            let gesture2 = try gesture1.first(MagnificationGesture.self)
            try gesture2.gestureCallEnded(value: magnificationValue!)
        case .second:
            let gesture2 = try gesture1.second(RotationGesture.self)
            try gesture2.gestureCallEnded(value: rotationValue!)
        }
        wait(for: [exp], timeout: 0.1)
    }

    typealias ComposedGestureEndedMultiple<T> =
        (_EndedGesture<_EndedGesture<MagnificationGesture>>,
         _EndedGesture<_EndedGesture<RotationGesture>>) -> T
    
    func composedGestureCallEndedMultipleTest<T, U>(
        type: U.Type,
        order: InspectableView<ViewType.Gesture<T>>.GestureOrder,
        file: StaticString = #filePath,
        line: UInt = #line,
        _ factory: ComposedGestureEndedMultiple<T>) throws
    where T: Gesture & Inspectable, U: Gesture & Inspectable
    {
        let exp1 = XCTestExpectation(description: "ended1")
        let exp2 = XCTestExpectation(description: "ended2")
        let magnificationGesture = MagnificationGesture(minimumScaleDelta: 1.5)
            .onEnded { value in
                self.assertMagnificationValue(value)
                exp1.fulfill()
            }
            .onEnded { value in
                self.assertMagnificationValue(value)
                exp2.fulfill()
            }
        let rotationGesture = RotationGesture(minimumAngleDelta: Angle(degrees: 5))
            .onEnded { value in
                self.assertRotationValue(value)
                exp1.fulfill()
            }
            .onEnded { value in
                self.assertRotationValue(value)
                exp2.fulfill()
            }
        let sut = EmptyView().gesture(factory(magnificationGesture, rotationGesture))
        let emptyView = try sut.inspect().emptyView()
        let gesture1 = try emptyView
            .gesture(type)
        switch order {
        case .first:
            let gesture2 = try gesture1.first(MagnificationGesture.self)
            try gesture2.gestureCallEnded(value: magnificationValue!)
        case .second:
            let gesture2 = try gesture1.second(RotationGesture.self)
            try gesture2.gestureCallEnded(value: rotationValue!)
        }
        wait(for: [exp1, exp2], timeout: 0.1)
    }

    func composedGestureCallEndedFailureTest<T, U>(
        type: U.Type,
        order: InspectableView<ViewType.Gesture<T>>.GestureOrder,
        file: StaticString = #filePath,
        line: UInt = #line,
        _ factory: (MagnificationGesture, RotationGesture) -> T) throws
    where T: Gesture & Inspectable, U: Gesture & Inspectable
    {
        let magnificationGesture = MagnificationGesture(minimumScaleDelta: 1.5)
        let rotationGesture = RotationGesture(minimumAngleDelta: Angle(degrees: 5))
        let sut = EmptyView().gesture(factory(magnificationGesture, rotationGesture))
        let gesture1 = try sut.inspect()
            .emptyView()
            .gesture(type)
        switch order {
        case .first:
            let gesture2 = try gesture1.first(MagnificationGesture.self)
            XCTAssertThrowsError(try gesture2.gestureCallEnded(value: magnificationValue!))
        case .second:
            let gesture2 = try gesture1.second(RotationGesture.self)
            XCTAssertThrowsError(try gesture2.gestureCallEnded(value: rotationValue!))
        }
    }
    
    #if os(macOS)
    typealias ComposedGestureModifiers<T> =
        (_ModifiersGesture<MagnificationGesture>,
         _ModifiersGesture<RotationGesture>) -> T

    func composedGestureModifiersTest<T, U>(
        type: U.Type,
        order: InspectableView<ViewType.Gesture<T>>.GestureOrder,
        file: StaticString = #filePath,
        line: UInt = #line,
        _ factory: ComposedGestureModifiers<T>) throws
    where T: Gesture & Inspectable, U: Gesture & Inspectable
    {
        let magnificationGesture = MagnificationGesture(minimumScaleDelta: 1.5)
            .modifiers(.shift)
        let rotationGesture = RotationGesture(minimumAngleDelta: Angle(degrees: 5))
            .modifiers(.shift)
        let sut = EmptyView().gesture(factory(magnificationGesture, rotationGesture))
        let emptyView = try sut.inspect().emptyView()
        let gesture1 = try emptyView
            .gesture(type)
        switch order {
        case .first:
            let gesture2 = try gesture1.first(MagnificationGesture.self)
            XCTAssertEqual(try gesture2.gestureModifiers(), .shift)
        case .second:
            let gesture2 = try gesture1.second(RotationGesture.self)
            XCTAssertEqual(try gesture2.gestureModifiers(), .shift)
        }
    }
    
    typealias ComposedGestureModifiersNotFirst<T> =
        (_ModifiersGesture<_EndedGesture<MagnificationGesture>>,
         _ModifiersGesture<_EndedGesture<RotationGesture>>) -> T

    func composedGestureModifiersNotFirstTest<T, U>(
        type: U.Type,
        order: InspectableView<ViewType.Gesture<T>>.GestureOrder,
        file: StaticString = #filePath,
        line: UInt = #line,
        _ factory: ComposedGestureModifiersNotFirst<T>) throws
    where T: Gesture & Inspectable, U: Gesture & Inspectable
    {
        let magnificationGesture = MagnificationGesture(minimumScaleDelta: 1.5)
            .onEnded { value in }
            .modifiers(.shift)
        let rotationGesture = RotationGesture(minimumAngleDelta: Angle(degrees: 5))
            .onEnded { value in }
            .modifiers(.shift)
        let sut = EmptyView().gesture(factory(magnificationGesture, rotationGesture))
        let emptyView = try sut.inspect().emptyView()
        let gesture1 = try emptyView
            .gesture(type)
        switch order {
        case .first:
            let gesture2 = try gesture1.first(MagnificationGesture.self)
            XCTAssertEqual(try gesture2.gestureModifiers(), .shift)
        case .second:
            let gesture2 = try gesture1.second(RotationGesture.self)
            XCTAssertEqual(try gesture2.gestureModifiers(), .shift)
        }
    }
    
    typealias ComposedGestureModifiersMultiple<T> =
        (_ModifiersGesture<_ModifiersGesture<MagnificationGesture>>,
         _ModifiersGesture<_ModifiersGesture<RotationGesture>>) -> T

    func composedGestureModifiersMultipleTest<T, U>(
        type: U.Type,
        order: InspectableView<ViewType.Gesture<T>>.GestureOrder,
        file: StaticString = #filePath,
        line: UInt = #line,
        _ factory: ComposedGestureModifiersMultiple<T>) throws
    where T: Gesture & Inspectable, U: Gesture & Inspectable
    {
        let magnificationGesture = MagnificationGesture(minimumScaleDelta: 1.5)
            .modifiers(.shift)
            .modifiers(.control)
        let rotationGesture = RotationGesture(minimumAngleDelta: Angle(degrees: 5))
            .modifiers(.shift)
            .modifiers(.control)
        let sut = EmptyView().gesture(factory(magnificationGesture, rotationGesture))
        let emptyView = try sut.inspect().emptyView()
        let gesture1 = try emptyView
            .gesture(type)
        switch order {
        case .first:
            let gesture2 = try gesture1.first(MagnificationGesture.self)
            XCTAssertEqual(try gesture2.gestureModifiers(), [.shift, .control])
        case .second:
            let gesture2 = try gesture1.second(RotationGesture.self)
            XCTAssertEqual(try gesture2.gestureModifiers(), [.shift, .control])
        }
    }

    func composedGestureModifiersFailureTest<T, U>(
        type: U.Type,
        order: InspectableView<ViewType.Gesture<T>>.GestureOrder,
        file: StaticString = #filePath,
        line: UInt = #line,
        _ factory: (MagnificationGesture, RotationGesture) -> T) throws
    where T: Gesture & Inspectable, U: Gesture & Inspectable
    {
        let magnificationGesture = MagnificationGesture(minimumScaleDelta: 1.5)
        let rotationGesture = RotationGesture(minimumAngleDelta: Angle(degrees: 5))
        let sut = EmptyView().gesture(factory(magnificationGesture, rotationGesture))
        let gesture1 = try sut.inspect()
            .emptyView()
            .gesture(type)
        switch order {
        case .first:
            let gesture2 = try gesture1.first(MagnificationGesture.self)
            XCTAssertEqual(try gesture2.gestureModifiers(), [])
        case .second:
            let gesture2 = try gesture1.second(RotationGesture.self)
            XCTAssertEqual(try gesture2.gestureModifiers(), [])
        }
    }
    #endif
}
