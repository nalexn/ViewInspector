import XCTest
import SwiftUI
import Combine
@testable import ViewInspector

// MARK: - Simultaneous Gesture Gesture Tests

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
final class SimultaneousGestureChildrenTests: XCTestCase {

    typealias GUT = SimultaneousGesture<MagnificationGesture, RotationGesture>
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
    
    func testSimultaneousGestureChildren() throws {
        try gestureTests!.gestureTest(.first) { first, second in SimultaneousGesture(first, second) }
        try gestureTests!.gestureTest(.second) { first, second in SimultaneousGesture(first, second) }
    }
    
    func testSimultaneousGestureChildrenFailure() throws {
        try gestureTests!.gestureFailureTest(.first) { first, second in SimultaneousGesture(first, second) }
        try gestureTests!.gestureFailureTest(.second) { first, second in SimultaneousGesture(first, second) }
    }

    func testSimultaneousGestureChildrenCallUpdating() throws {
        try updatingTests!.callUpdatingTest(.first) { first, second in SimultaneousGesture(first, second) }
        try updatingTests!.callUpdatingTest(.second) { first, second in SimultaneousGesture(first, second) }
    }
    
    func testSimultaneousGestureChildrenCallUpdatingNotFirst() throws {
        try updatingTests!.callUpdatingNotFirstTest(.first) { first, second in SimultaneousGesture(first, second) }
        try updatingTests!.callUpdatingNotFirstTest(.second) { first, second in SimultaneousGesture(first, second) }
    }
    
    func testSimultaneousGestureChildrenCallUpdatingMultiple() throws {
        try updatingTests!.callUpdatingMultipleTest(.first) { first, second in SimultaneousGesture(first, second) }
        try updatingTests!.callUpdatingMultipleTest(.second) { first, second in SimultaneousGesture(first, second) }
    }
    
    func testSimultaneousGestureChildrenCallUpdatingFailure() throws {
        try updatingTests!.callUpdatingFailureTest(.first) { first, second in SimultaneousGesture(first, second) }
        try updatingTests!.callUpdatingFailureTest(.second) { first, second in SimultaneousGesture(first, second) }
    }

    func testSimultaneousGestureChildrenCallChanged() throws {
        try changedTests!.callChangedTest(.first) { first, second in SimultaneousGesture(first, second) }
        try changedTests!.callChangedTest(.second) { first, second in SimultaneousGesture(first, second) }
    }
    
    func testSimultaneousGestureChildrenCallChangedNotFirst() throws {
        try changedTests!.callChangedNotFirstTest(.first) { first, second in SimultaneousGesture(first, second) }
        try changedTests!.callChangedNotFirstTest(.second) { first, second in SimultaneousGesture(first, second) }
    }
    
    func testSimultaneousGestureFirstCallChangedMultiple() throws {
        try changedTests!.callChangedMultipleTest(.first) { first, second in SimultaneousGesture(first, second) }
        try changedTests!.callChangedMultipleTest(.second) { first, second in SimultaneousGesture(first, second) }
    }
    
    func testSimultaneousGestureChildrenCallChangedFailure() throws {
        try changedTests!.callChangedFailureTest(.first) { first, second in SimultaneousGesture(first, second) }
        try changedTests!.callChangedFailureTest(.second) { first, second in SimultaneousGesture(first, second) }
    }
    
    func testSimultaneousGestureChildrenCallEnded() throws {
        try endedTests!.callEndedTest(.first) { first, second in SimultaneousGesture(first, second) }
        try endedTests!.callEndedTest(.second) { first, second in SimultaneousGesture(first, second) }
    }

    func testSimultaneousGestureChildrenCallEndedNotFirst() throws {
        try endedTests!.callEndedNotFirstTest(.first) { first, second in SimultaneousGesture(first, second) }
        try endedTests!.callEndedNotFirstTest(.second) { first, second in SimultaneousGesture(first, second) }
    }

    func testSimultaneousGestureChildrenCallEndedMultiple() throws {
        try endedTests!.callEndedMultipleTest(.first) { first, second in SimultaneousGesture(first, second) }
        try endedTests!.callEndedMultipleTest(.second) { first, second in SimultaneousGesture(first, second) }

    }
    
    func testSimultaneousGestureChildrenCallEndedFailure() throws {
        try endedTests!.callEndedFailureTest(.first) { first, second in SimultaneousGesture(first, second) }
        try endedTests!.callEndedFailureTest(.second) { first, second in SimultaneousGesture(first, second) }
    }
    
    #if os(macOS)
    func testSimultaneousGestureChildrenModifiers() throws {
        try gestureTests!.modifiersTest(.first) { first, second in SimultaneousGesture(first, second) }
        try gestureTests!.modifiersTest(.second) { first, second in SimultaneousGesture(first, second) }
    }
    
    func testSimultaneousGestureChildrenModifiersNodifiersNotFirst() throws {
        try gestureTests!.modifiersNotFirstTest(.first) { first, second in SimultaneousGesture(first, second) }
        try gestureTests!.modifiersNotFirstTest(.second) { first, second in SimultaneousGesture(first, second) }
    }

    func testSimultaneousGestureChildrenModifiersNodifiersMultiple() throws {
        try gestureTests!.modifiersMultipleTest(.first) { first, second in SimultaneousGesture(first, second) }
        try gestureTests!.modifiersMultipleTest(.second) { first, second in SimultaneousGesture(first, second) }
    }
    
    func testSimultaneousGestureChildrenModifiersNone() throws {
        try gestureTests!.modifiersFailureTest(.first) { first, second in SimultaneousGesture(first, second) }
        try gestureTests!.modifiersFailureTest(.second) { first, second in SimultaneousGesture(first, second) }
    }
    #endif
}
