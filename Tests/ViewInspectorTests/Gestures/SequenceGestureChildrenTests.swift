import XCTest
import SwiftUI
import Combine
@testable import ViewInspector

// MARK: - Sequence Gesture Children Tests

@available(iOS 13.0, macOS 10.15, *)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
final class SequenceGestureChildrenTests: XCTestCase {

    typealias GUT = SequenceGesture<MagnificationGesture, RotationGesture>
    var gestureTests: CommonComposedGestureTests<GUT>?
    var updatingTests: CommonComposedGestureUpdatingTests<GUT>?
    var changedTests: CommonComposedGestureChangedTests<GUT>?
    var endedTests: CommonComposedGestureEndedTests<GUT>?
    
    override func setUpWithError() throws {
        gestureTests = CommonComposedGestureTests<GUT>(type: GUT.self)
        updatingTests = CommonComposedGestureUpdatingTests<GUT>(testCase: self, type: GUT.self)
        changedTests = CommonComposedGestureChangedTests<GUT>(testCase: self, type: GUT.self)
        endedTests = CommonComposedGestureEndedTests<GUT>(testCase: self, type: GUT.self)
    }
    
    override func tearDownWithError() throws {
        gestureTests = nil
        updatingTests = nil
        changedTests = nil
        endedTests = nil
    }

    func testSequenceGestureChildren() throws {
        try gestureTests!.gestureTest(.first) { first, second in SequenceGesture(first, second) }
        try gestureTests!.gestureTest(.second) { first, second in SequenceGesture(first, second) }
    }
    
    func testSequenceGestureChildrenPath() throws {
        try gestureTests!.gesturePathTest(.first) { first, second in SequenceGesture(first, second) }
        try gestureTests!.gesturePathTest(.second) { first, second in SequenceGesture(first, second) }
    }
    
    func testSequenceGestureChildrenFailure() throws {
        try gestureTests!.gestureFailureTest(.first) { first, second in SequenceGesture(first, second) }
        try gestureTests!.gestureFailureTest(.second) { first, second in SequenceGesture(first, second) }
    }

    func testSequenceGestureChildrenCallUpdating() throws {
        try updatingTests!.callUpdatingTest(.first) { first, second in SequenceGesture(first, second) }
        try updatingTests!.callUpdatingTest(.second) { first, second in SequenceGesture(first, second) }
    }
    
    func testSequenceGestureChildrenCallUpdatingNotFirst() throws {
        try updatingTests!.callUpdatingNotFirstTest(.first) { first, second in SequenceGesture(first, second) }
        try updatingTests!.callUpdatingNotFirstTest(.second) { first, second in SequenceGesture(first, second) }
    }
    
    func testSequenceGestureChildrenCallUpdatingMultiple() throws {
        try updatingTests!.callUpdatingMultipleTest(.first) { first, second in SequenceGesture(first, second) }
        try updatingTests!.callUpdatingMultipleTest(.second) { first, second in SequenceGesture(first, second) }
    }
    
    func testSequenceGestureChildrenCallUpdatingFailure() throws {
        try updatingTests!.callUpdatingFailureTest(.first) { first, second in SequenceGesture(first, second) }
        try updatingTests!.callUpdatingFailureTest(.second) { first, second in SequenceGesture(first, second) }
    }

    func testSequenceGestureChildrenCallChanged() throws {
        try changedTests!.callChangedTest(.first) { first, second in SequenceGesture(first, second) }
        try changedTests!.callChangedTest(.second) { first, second in SequenceGesture(first, second) }
    }
    
    func testSequenceGestureChildrenCallChangedNotFirst() throws {
        try changedTests!.callChangedNotFirstTest(.first) { first, second in SequenceGesture(first, second) }
        try changedTests!.callChangedNotFirstTest(.second) { first, second in SequenceGesture(first, second) }
    }
    
    func testSequenceGestureFirstCallChangedMultiple() throws {
        try changedTests!.callChangedMultipleTest(.first) { first, second in SequenceGesture(first, second) }
        try changedTests!.callChangedMultipleTest(.second) { first, second in SequenceGesture(first, second) }
    }
    
    func testSequenceGestureChildrenCallChangedFailure() throws {
        try changedTests!.callChangedFailureTest(.first) { first, second in SequenceGesture(first, second) }
        try changedTests!.callChangedFailureTest(.second) { first, second in SequenceGesture(first, second) }
    }
    
    func testSequenceGestureChildrenCallEnded() throws {
        try endedTests!.callEndedTest(.first) { first, second in SequenceGesture(first, second) }
        try endedTests!.callEndedTest(.second) { first, second in SequenceGesture(first, second) }
    }

    func testSequenceGestureChildrenCallEndedNotFirst() throws {
        try endedTests!.callEndedNotFirstTest(.first) { first, second in SequenceGesture(first, second) }
        try endedTests!.callEndedNotFirstTest(.second) { first, second in SequenceGesture(first, second) }
    }

    func testSequenceGestureChildrenCallEndedMultiple() throws {
        try endedTests!.callEndedMultipleTest(.first) { first, second in SequenceGesture(first, second) }
        try endedTests!.callEndedMultipleTest(.second) { first, second in SequenceGesture(first, second) }

    }
    
    func testSequenceGestureChildrenCallEndedFailure() throws {
        try endedTests!.callEndedFailureTest(.first) { first, second in SequenceGesture(first, second) }
        try endedTests!.callEndedFailureTest(.second) { first, second in SequenceGesture(first, second) }
    }
    
    #if os(macOS)
    func testSequenceGestureChildrenModifiers() throws {
        try gestureTests!.modifiersTest(.first) { first, second in SequenceGesture(first, second) }
        try gestureTests!.modifiersTest(.second) { first, second in SequenceGesture(first, second) }
    }
    
    func testSequenceGestureChildrenModifiersNodifiersNotFirst() throws {
        try gestureTests!.modifiersNotFirstTest(.first) { first, second in SequenceGesture(first, second) }
        try gestureTests!.modifiersNotFirstTest(.second) { first, second in SequenceGesture(first, second) }
    }

    func testSequenceGestureChildrenModifiersNodifiersMultiple() throws {
        try gestureTests!.modifiersMultipleTest(.first) { first, second in SequenceGesture(first, second) }
        try gestureTests!.modifiersMultipleTest(.second) { first, second in SequenceGesture(first, second) }
    }
    
    func testSequenceGestureChildrenModifiersNone() throws {
        try gestureTests!.modifiersFailureTest(.first) { first, second in SequenceGesture(first, second) }
        try gestureTests!.modifiersFailureTest(.second) { first, second in SequenceGesture(first, second) }
    }
    #endif
}
