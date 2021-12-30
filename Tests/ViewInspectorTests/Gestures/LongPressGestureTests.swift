import XCTest
import SwiftUI
import Combine
@testable import ViewInspector

// MARK: - Long Press Gesture Tests

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
final class LongPressGestureTests: XCTestCase {
    
    var longPressFinished: Bool?
    
    private var _longPressValue: Any?
    @available(tvOS 14.0, *)
    private func longPressValue() throws -> LongPressGesture.Value {
        return try Inspector.cast(value: _longPressValue!, type: LongPressGesture.Value.self)
    }
    
    private var _gestureTests: Any?
    @available(tvOS 14.0, *)
    private func gestureTests() throws -> CommonGestureTests<LongPressGesture> {
        return try Inspector.cast(value: _gestureTests!, type: CommonGestureTests<LongPressGesture>.self)
    }
    
    override func setUpWithError() throws {
        guard #available(tvOS 14.0, *) else { throw XCTSkip() }
        longPressFinished = false
        _longPressValue = LongPressGesture.Value(finished: longPressFinished!)
        
        _gestureTests = CommonGestureTests<LongPressGesture>(testCase: self,
                                                            gesture: LongPressGesture(),
                                                            value: try longPressValue(),
                                                            assert: assertLongPressValue)
    }
    
    override func tearDownWithError() throws {
        longPressFinished = nil
        _longPressValue = nil
        _gestureTests = nil
    }

    func testCreateLongPressGestureValue() throws {
        guard #available(tvOS 14.0, *) else { throw XCTSkip() }
        XCTAssertNotNil(longPressFinished)
        let value = try longPressValue()
        assertLongPressValue(value)
    }
    
    func testLongPressGestureMask() throws {
        guard #available(tvOS 14.0, *) else { throw XCTSkip() }
        try gestureTests().maskTest()
    }
    
    #if !os(tvOS)
    func testLongPressGesture() throws {
        let sut = EmptyView()
            .gesture(LongPressGesture(minimumDuration: 5, maximumDistance: 1))
        let longPressGesture = try sut.inspect().emptyView().gesture(LongPressGesture.self).actualGesture()
        XCTAssertEqual(longPressGesture.minimumDuration, 5)
        XCTAssertEqual(longPressGesture.maximumDistance, 1)
    }
    #endif
    
    func testLongPressGestureWithUpdatingModifier() throws {
        guard #available(tvOS 14.0, *) else { throw XCTSkip() }
        try gestureTests().propertiesWithUpdatingModifierTest()
    }
    
    func testLongPressGestureWithOnChangedModifier() throws {
        guard #available(tvOS 14.0, *) else { throw XCTSkip() }
        try gestureTests().propertiesWithOnChangedModifierTest()
    }
    
    func testLongPressGestureWithOnEndedModifier() throws {
        guard #available(tvOS 14.0, *) else { throw XCTSkip() }
        try gestureTests().propertiesWithOnEndedModifierTest()
    }
    
    #if os(macOS)
    func testLongPressGestureWithModifiers() throws {
        try gestureTests().propertiesWithModifiersTest()
    }
    #endif
    
    func testLongPressGestureFailure() throws {
        guard #available(tvOS 14.0, *) else { throw XCTSkip() }
        try gestureTests().propertiesFailureTest("LongPressGesture")
    }

    func testLongPressGestureCallUpdating() throws {
        guard #available(tvOS 14.0, *) else { throw XCTSkip() }
        try gestureTests().callUpdatingTest()
    }
    
    func testLongPressGestureCallUpdatingNotFirst() throws {
        guard #available(tvOS 14.0, *) else { throw XCTSkip() }
        try gestureTests().callUpdatingNotFirstTest()
    }

    func testLongPressGestureCallUpdatingMultiple() throws {
        guard #available(tvOS 14.0, *) else { throw XCTSkip() }
        try gestureTests().callUpdatingMultipleTest()
    }
    
    func testLongPressGestureCallUpdatingFailure() throws {
        guard #available(tvOS 14.0, *) else { throw XCTSkip() }
        try gestureTests().callUpdatingFailureTest()
    }
    
    func testLongPressGestureCallOnChanged() throws {
        guard #available(tvOS 14.0, *) else { throw XCTSkip() }
        try gestureTests().callOnChangedTest()
    }
    
    func testLongPressGestureCallOnChangedNotFirst() throws {
        guard #available(tvOS 14.0, *) else { throw XCTSkip() }
        try gestureTests().callOnChangedNotFirstTest()
    }
    
    func testLongPressGestureCallOnChangedMultiple() throws {
        guard #available(tvOS 14.0, *) else { throw XCTSkip() }
        try gestureTests().callOnChangedMultipleTest()
    }
    
    func testLongPressGestureCallOnChangedFailure() throws {
        guard #available(tvOS 14.0, *) else { throw XCTSkip() }
        try gestureTests().callOnChangedFailureTest()
    }
    
    func testLongPressGestureCallOnEnded() throws {
        guard #available(tvOS 14.0, *) else { throw XCTSkip() }
        try gestureTests().callOnEndedTest()
    }
    
    func testLongPressGestureCallOnEndedNotFirst() throws {
        guard #available(tvOS 14.0, *) else { throw XCTSkip() }
        try gestureTests().callOnEndedNotFirstTest()
    }

    func testLongPressGestureCallOnEndedMultiple() throws {
        guard #available(tvOS 14.0, *) else { throw XCTSkip() }
        try gestureTests().callOnEndedMultipleTest()
    }
    
    func testLongPressGestureCallOnEndedFailure() throws {
        guard #available(tvOS 14.0, *) else { throw XCTSkip() }
        try gestureTests().callOnEndedFailureTest()
    }
    
    #if os(macOS)
    func testLongPressGestureModifiers() throws {
        try gestureTests().modifiersTest()
    }
        
    func testLongPressGestureModifiersNotFirst() throws {
        try gestureTests().modifiersNotFirstTest()
    }
    
    func testLongPressGestureModifiersMultiple() throws {
        try gestureTests().modifiersMultipleTest()
    }
    
    func testLongPressGestureModifiersNone() throws {
        try gestureTests().modifiersNoneTest()
    }
    #endif
    
    @available(tvOS 14.0, *)
    func assertLongPressValue(
        _ value: LongPressGesture.Value,
        file: StaticString = #filePath,
        line: UInt = #line) {
        XCTAssertEqual(value, longPressFinished!)
    }
}
