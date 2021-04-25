import XCTest
import SwiftUI
import Combine
@testable import ViewInspector

// MARK: - Long Press Gesture Tests

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
final class LongPressGestureTests: XCTestCase {
    
    var longPressFinished: Bool?
    var longPressValue: LongPressGesture.Value?
    
    var gestureTests: CommonGestureTests<LongPressGesture>?
    
    override func setUpWithError() throws {
        longPressFinished = false
        longPressValue = LongPressGesture.Value(finished: longPressFinished!)
        
        gestureTests = CommonGestureTests<LongPressGesture>(testCase: self,
                                                            gesture: LongPressGesture(),
                                                            value: longPressValue!,
                                                            assert: assertLongPressValue)
    }
    
    override func tearDownWithError() throws {
        longPressFinished = nil
        longPressValue = nil
        gestureTests = nil
    }

    func testCreateLongPressGestureValue() throws {
        XCTAssertNotNil(longPressFinished)
        let value = try XCTUnwrap(longPressValue)
        assertLongPressValue(value)
    }
    
    func testLongPressGestureMask() throws {
        try gestureTests!.maskTest()
    }
    
    func testLongPressGesture() throws {
        let sut = EmptyView()
            .gesture(LongPressGesture(minimumDuration: 5, maximumDistance: 1))
        let longPressGesture = try sut.inspect().emptyView().gesture(LongPressGesture.self).gestureProperties()
        XCTAssertEqual(longPressGesture.minimumDuration, 5)
        XCTAssertEqual(longPressGesture.maximumDistance, 1)
    }
    
    func testLongPressGestureWithUpdatingModifier() throws {
        try gestureTests!.propertiesWithUpdatingModifierTest()
    }
    
    func testLongPressGestureWithOnChangedModifier() throws {
        try gestureTests!.propertiesWithOnChangedModifierTest()
    }
    
    func testLongPressGestureWithOnEndedModifier() throws {
        try gestureTests!.propertiesWithOnEndedModifierTest()
    }
    
    #if os(macOS)
    func testLongPressGestureWithModifiers() throws {
        try gestureTests!.propertiesWithModifiersTest()
    }
    #endif
    
    func testLongPressGestureFailure() throws {
        try gestureTests!.propertiesFailureTest("LongPressGesture")
    }

    func testLongPressGestureCallUpdating() throws {
        try gestureTests!.callUpdatingTest()
    }
    
    func testLongPressGestureCallUpdatingNotFirst() throws {
        try gestureTests!.callUpdatingNotFirstTest()
    }

    func testLongPressGestureCallUpdatingMultiple() throws {
        try gestureTests!.callUpdatingMultipleTest()
    }
    
    func testLongPressGestureCallUpdatingFailure() throws {
        try gestureTests!.callUpdatingFailureTest()
    }
    
    func testLongPressGestureCallOnChanged() throws {
        try gestureTests!.callOnChangedTest()
    }
    
    func testLongPressGestureCallOnChangedNotFirst() throws {
        try gestureTests!.callOnChangedNotFirstTest()
    }
    
    func testLongPressGestureCallOnChangedMultiple() throws {
        try gestureTests!.callOnChangedMultipleTest()
    }
    
    func testLongPressGestureCallOnChangedFailure() throws {
        try gestureTests!.callOnChangedFailureTest()
    }
    
    func testLongPressGestureCallOnEnded() throws {
        try gestureTests!.callOnEndedTest()
    }
    
    func testLongPressGestureCallOnEndedNotFirst() throws {
        try gestureTests!.callOnEndedNotFirstTest()
    }

    func testLongPressGestureCallOnEndedMultiple() throws {
        try gestureTests!.callOnEndedMultipleTest()
    }
    
    func testLongPressGestureCallOnEndedFailure() throws {
        try gestureTests!.callOnEndedFailureTest()
    }
    
    #if os(macOS)
    func testLongPressGestureModifiers() throws {
        try gestureTests!.modifiersTest()
    }
        
    func testLongPressGestureModifiersNotFirst() throws {
        try gestureTests!.modifiersNotFirstTest()
    }
    
    func testLongPressGestureModifiersMultiple() throws {
        try gestureTests!.modifiersMultipleTest()
    }
    
    func testLongPressGestureModifiersNone() throws {
        try gestureTests!.modifiersNoneTest()
    }
    #endif
    
    func assertLongPressValue(
        _ value: LongPressGesture.Value,
        file: StaticString = #filePath,
        line: UInt = #line) {
        XCTAssertEqual(value, longPressFinished!)
    }
}
