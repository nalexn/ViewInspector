import XCTest
import SwiftUI
import Combine
@testable import ViewInspector

// MARK: - Exclusive Gesture Children Tests

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
final class ExclusiveGestureChildrenTests: XCTestCase {

    typealias GUT = ExclusiveGesture<MagnificationGesture, RotationGesture>
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
    
    func testExclusiveGestureChildren() throws {
        try gestureTests!.gestureTest(.first) { first, second in ExclusiveGesture(first, second) }
        try gestureTests!.gestureTest(.second) { first, second in ExclusiveGesture(first, second) }
    }
    
    func testExclusiveGestureChildrenPath() throws {
        try gestureTests!.gesturePathTest(.first) { first, second in ExclusiveGesture(first, second) }
        try gestureTests!.gesturePathTest(.second) { first, second in ExclusiveGesture(first, second) }
    }
    
    func testExclusiveGestureChildrenFailure() throws {
        try gestureTests!.gestureFailureTest(.first) { first, second in ExclusiveGesture(first, second) }
        try gestureTests!.gestureFailureTest(.second) { first, second in ExclusiveGesture(first, second) }
    }

    func testExclusiveGestureChildrenCallUpdating() throws {
        try updatingTests!.callUpdatingTest(.first) { first, second in ExclusiveGesture(first, second) }
        try updatingTests!.callUpdatingTest(.second) { first, second in ExclusiveGesture(first, second) }
    }
    
    func testExclusiveGestureChildrenCallUpdatingNotFirst() throws {
        try updatingTests!.callUpdatingNotFirstTest(.first) { first, second in ExclusiveGesture(first, second) }
        try updatingTests!.callUpdatingNotFirstTest(.second) { first, second in ExclusiveGesture(first, second) }
    }
    
    func testExclusiveGestureChildrenCallUpdatingMultiple() throws {
        try updatingTests!.callUpdatingMultipleTest(.first) { first, second in ExclusiveGesture(first, second) }
        try updatingTests!.callUpdatingMultipleTest(.second) { first, second in ExclusiveGesture(first, second) }
    }
    
    func testExclusiveGestureChildrenCallUpdatingFailure() throws {
        try updatingTests!.callUpdatingFailureTest(.first) { first, second in ExclusiveGesture(first, second) }
        try updatingTests!.callUpdatingFailureTest(.second) { first, second in ExclusiveGesture(first, second) }
    }

    func testExclusiveGestureChildrenCallChanged() throws {
        try changedTests!.callChangedTest(.first) { first, second in ExclusiveGesture(first, second) }
        try changedTests!.callChangedTest(.second) { first, second in ExclusiveGesture(first, second) }
    }
    
    func testExclusiveGestureChildrenCallChangedNotFirst() throws {
        try changedTests!.callChangedNotFirstTest(.first) { first, second in ExclusiveGesture(first, second) }
        try changedTests!.callChangedNotFirstTest(.second) { first, second in ExclusiveGesture(first, second) }
    }
    
    func testExclusiveGestureFirstCallChangedMultiple() throws {
        try changedTests!.callChangedMultipleTest(.first) { first, second in ExclusiveGesture(first, second) }
        try changedTests!.callChangedMultipleTest(.second) { first, second in ExclusiveGesture(first, second) }
    }
    
    func testExclusiveGestureChildrenCallChangedFailure() throws {
        try changedTests!.callChangedFailureTest(.first) { first, second in ExclusiveGesture(first, second) }
        try changedTests!.callChangedFailureTest(.second) { first, second in ExclusiveGesture(first, second) }
    }
    
    func testExclusiveGestureChildrenCallEnded() throws {
        try endedTests!.callEndedTest(.first) { first, second in ExclusiveGesture(first, second) }
        try endedTests!.callEndedTest(.second) { first, second in ExclusiveGesture(first, second) }
    }

    func testExclusiveGestureChildrenCallEndedNotFirst() throws {
        try endedTests!.callEndedNotFirstTest(.first) { first, second in ExclusiveGesture(first, second) }
        try endedTests!.callEndedNotFirstTest(.second) { first, second in ExclusiveGesture(first, second) }
    }

    func testExclusiveGestureChildrenCallEndedMultiple() throws {
        try endedTests!.callEndedMultipleTest(.first) { first, second in ExclusiveGesture(first, second) }
        try endedTests!.callEndedMultipleTest(.second) { first, second in ExclusiveGesture(first, second) }

    }
    
    func testExclusiveGestureChildrenCallEndedFailure() throws {
        try endedTests!.callEndedFailureTest(.first) { first, second in ExclusiveGesture(first, second) }
        try endedTests!.callEndedFailureTest(.second) { first, second in ExclusiveGesture(first, second) }
    }
    
    #if os(macOS)
    func testExclusiveGestureChildrenModifiers() throws {
        try gestureTests!.modifiersTest(.first) { first, second in ExclusiveGesture(first, second) }
        try gestureTests!.modifiersTest(.second) { first, second in ExclusiveGesture(first, second) }
    }
    
    func testExclusiveGestureChildrenModifiersNodifiersNotFirst() throws {
        try gestureTests!.modifiersNotFirstTest(.first) { first, second in ExclusiveGesture(first, second) }
        try gestureTests!.modifiersNotFirstTest(.second) { first, second in ExclusiveGesture(first, second) }
    }

    func testExclusiveGestureChildrenModifiersNodifiersMultiple() throws {
        try gestureTests!.modifiersMultipleTest(.first) { first, second in ExclusiveGesture(first, second) }
        try gestureTests!.modifiersMultipleTest(.second) { first, second in ExclusiveGesture(first, second) }
    }
    
    func testExclusiveGestureChildrenModifiersNone() throws {
        try gestureTests!.modifiersFailureTest(.first) { first, second in ExclusiveGesture(first, second) }
        try gestureTests!.modifiersFailureTest(.second) { first, second in ExclusiveGesture(first, second) }
    }
    #endif
}
