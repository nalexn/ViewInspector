import XCTest
import SwiftUI
import Combine
@testable import ViewInspector

// MARK: - Tap Gesture Tests

@available(iOS 13.0, macOS 10.15, *)
@available(tvOS, unavailable)
final class TapGestureTests: XCTestCase {
    
    var tapValue: TapGesture.Value?
    
    var gestureTests: CommonGestureTests<TapGesture>?
    
    override func setUpWithError() throws {
        tapValue = TapGesture.Value()
        
        gestureTests = CommonGestureTests<TapGesture>(testCase: self,
                                                      gesture: TapGesture(),
                                                      value: tapValue!,
                                                      assert: assertTapValue)
    }
    
    override func tearDownWithError() throws {
        tapValue = nil
        gestureTests = nil
    }

    func testCreateTapGestureValue() throws {
        let value: TapGesture.Value = try XCTUnwrap(tapValue)
        assertTapValue(value)
    }

    func testTapGestureMask() throws {
        try gestureTests!.maskTest()
    }
    
    func testTapGesture() throws {
        let sut = EmptyView().gesture(TapGesture(count: 2))
        let tapGesture = try sut.inspect().emptyView().gesture(TapGesture.self).actualGesture()
        XCTAssertEqual(tapGesture.count, 2)
    }
    
    func testTapGestureWithUpdatingModifier() throws {
        try gestureTests!.propertiesWithUpdatingModifierTest()
    }
        
    func testTapGestureWithOnEndedModifier() throws {
        try gestureTests!.propertiesWithOnEndedModifierTest()
    }
    
    #if os(macOS)
    func testTapGestureWithModifiers() throws {
        try gestureTests!.propertiesWithModifiersTest()
    }
    #endif
    
    func testTapGestureFailure() throws {
        try gestureTests!.propertiesFailureTest("TapGesture")
    }

    func testTapGestureCallUpdating() throws {
        try gestureTests!.callUpdatingTest()
    }
    
    func testTapGestureCallUpdatingNotFirst() throws {
        try gestureTests!.callUpdatingNotFirstTest()
    }

    func testTapGestureCallUpdatingMultiple() throws {
        try gestureTests!.callUpdatingMultipleTest()
    }
    
    func testTapGestureCallUpdatingFailure() throws {
        try gestureTests!.callUpdatingFailureTest()
    }
    
    func testTapGestureCallOnEnded() throws {
        try gestureTests!.callOnEndedTest()
    }
    
    func testTapGestureCallOnEndedNotFirst() throws {
        try gestureTests!.callOnEndedNotFirstTest()
    }

    func testTapGestureCallOnEndedMultiple() throws {
        try gestureTests!.callOnEndedMultipleTest()
    }
    
    func testTapGestureCallOnEndedFailure() throws {
        try gestureTests!.callOnEndedFailureTest()
    }
    
    #if os(macOS)
    func testTapGestureModifiers() throws {
        try gestureTests!.modifiersTest()
    }
        
    func testTapGestureModifiersNotFirst() throws {
        try gestureTests!.modifiersNotFirstTest()
    }
    
    func testTapGestureModifiersMultiple() throws {
        try gestureTests!.modifiersMultipleTest()
    }
    
    func testTapGestureModifiersNone() throws {
        try gestureTests!.modifiersNoneTest()
    }
    #endif

    func assertTapValue(
        _ value: TapGesture.Value,
        file: StaticString = #filePath,
        line: UInt = #line) {
        XCTAssertTrue(value == ())
    }
}
