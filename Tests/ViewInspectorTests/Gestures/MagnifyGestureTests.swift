#if !os(watchOS) && !os(tvOS)
import XCTest
import SwiftUI
@testable import ViewInspector

// MARK: - Magnify Gesture Tests
@MainActor
@available(iOS 17.0, macOS 14.0, *)
@available(watchOS, unavailable)
@available(tvOS, unavailable)
final class MagnifyGestureTests: XCTestCase {
    var magnifyTime: Date?
    var magnifyMagnification: CGFloat?
    var magnifyVelocity: CGFloat?
    var magnifyStartAnchor: UnitPoint?
    var magnifyStartLocation: CGPoint?
    var magnifyValue: MagnifyGesture.Value?
    
    var gestureTests: CommonGestureTests<MagnifyGesture>?
    
    override func setUpWithError() throws {
        MainActor.assumeIsolated {
            magnifyTime = Date()
            magnifyMagnification = 10
            magnifyVelocity = 2.5
            magnifyStartAnchor = .center
            magnifyStartLocation = CGPoint(x: 5, y: 5)
            magnifyValue = MagnifyGesture.Value(
                time: magnifyTime!,
                magnification: magnifyMagnification!,
                velocity: magnifyVelocity!,
                startAnchor: magnifyStartAnchor!,
                startLocation: magnifyStartLocation!
            )
            gestureTests = CommonGestureTests<MagnifyGesture>(testCase: self,
                                                              gesture: MagnifyGesture(),
                                                              value: magnifyValue!,
                                                              assert: assertMagnifyValue)
        }
    }
    
    override func tearDownWithError() throws {
        MainActor.assumeIsolated {
            magnifyTime = nil
            magnifyMagnification = nil
            magnifyVelocity = nil
            magnifyStartAnchor = nil
            magnifyStartLocation = nil
            magnifyValue = nil
            gestureTests = nil
        }
    }
    
    func testMagnifyGestureValueAllocator() throws {
        let date = Date(timeIntervalSince1970: 53513627)
        let magnification: CGFloat = 2.5
        let velocity: CGFloat = 1.2
        let startAnchor = UnitPoint(x: 0.3, y: 0.7)
        let startLocation = CGPoint(x: 123, y: -456)
        let sut = MagnifyGesture.Value(
            time: date,
            magnification: magnification,
            velocity: velocity,
            startAnchor: startAnchor,
            startLocation: startLocation
        )
        XCTAssertEqual(sut.time, date)
        XCTAssertEqual(sut.magnification, magnification)
        XCTAssertEqual(sut.velocity, velocity)
        XCTAssertEqual(sut.startAnchor, startAnchor)
        XCTAssertEqual(sut.startLocation, startLocation)
    }

    func testCreateMagnifyGestureValue() throws {
        XCTAssertNotNil(magnifyTime)
        XCTAssertNotNil(magnifyMagnification)
        XCTAssertNotNil(magnifyVelocity)
        XCTAssertNotNil(magnifyStartAnchor)
        XCTAssertNotNil(magnifyStartLocation)
        let value = try XCTUnwrap(magnifyValue)
        assertMagnifyValue(value)
    }
    
    func testMagnifyGestureMask() throws {
        try gestureTests!.maskTest()
    }
    
    func testMagnifyGesture() throws {
        let sut = EmptyView()
            .gesture(MagnifyGesture(minimumScaleDelta: 1.5))
        let magnificationGesture = try sut.inspect().emptyView().gesture(MagnifyGesture.self).actualGesture()
        XCTAssertEqual(magnificationGesture.minimumScaleDelta, 1.5)
    }

    func testMagnifyGestureWithUpdatingModifier() throws {
        try gestureTests!.propertiesWithUpdatingModifierTest()
    }
    
    func testMagnifyGestureWithOnChangedModifier() throws {
        try gestureTests!.propertiesWithOnChangedModifierTest()
    }
    
    func testMagnifyGestureWithOnEndedModifier() throws {
        try gestureTests!.propertiesWithOnEndedModifierTest()
    }
    
    #if os(macOS)
    func testMagnifyGestureWithModifiers() throws {
        try gestureTests!.propertiesWithModifiersTest()
    }
    #endif
    
    func testMagnifyGestureFailure() throws {
        try gestureTests!.propertiesFailureTest("MagnifyGesture")
    }

    func testMagnifyGestureCallUpdating() throws {
        try gestureTests!.callUpdatingTest()
    }
    
    func testMagnifyGestureCallUpdatingNotFirst() throws {
        try gestureTests!.callUpdatingNotFirstTest()
    }

    func testMagnifyGestureCallUpdatingMultiple() throws {
        try gestureTests!.callUpdatingMultipleTest()
    }
    
    func testMagnifyGestureCallUpdatingFailure() throws {
        try gestureTests!.callUpdatingFailureTest()
    }
    
    func testMagnifyGestureCallOnChanged() throws {
        try gestureTests!.callOnChangedTest()
    }
    
    func testMagnifyGestureCallOnChangedNotFirst() throws {
        try gestureTests!.callOnChangedNotFirstTest()
    }
    
    func testMagnifyGestureCallOnChangedMultiple() throws {
        try gestureTests!.callOnChangedMultipleTest()
    }
    
    func testMagnifyGestureCallOnChangedFailure() throws {
        try gestureTests!.callOnChangedFailureTest()
    }
    
    func testMagnifyGestureCallOnEnded() throws {
        try gestureTests!.callOnEndedTest()
    }
    
    func testMagnifyGestureCallOnEndedNotFirst() throws {
        try gestureTests!.callOnEndedNotFirstTest()
    }

    func testMagnifyGestureCallOnEndedMultiple() throws {
        try gestureTests!.callOnEndedMultipleTest()
    }
    
    func testMagnifyGestureCallOnEndedFailure() throws {
        try gestureTests!.callOnEndedFailureTest()
    }
    
    #if os(macOS)
    func testMagnifyGestureModifiers() throws {
        try gestureTests!.modifiersTest()
    }
        
    func testMagnifyGestureModifiersNotFirst() throws {
        try gestureTests!.modifiersNotFirstTest()
    }
    
    func testMagnifyGestureModifiersMultiple() throws {
        try gestureTests!.modifiersMultipleTest()
    }
    
    func testMagnifyGestureModifiersNone() throws {
        try gestureTests!.modifiersNoneTest()
    }
    #endif

    func assertMagnifyValue(
        _ value: MagnifyGesture.Value,
        file: StaticString = #filePath,
        line: UInt = #line) {
        XCTAssertEqual(value.time, magnifyTime, file: file, line: line)
        XCTAssertEqual(value.magnification, magnifyMagnification, file: file, line: line)
        XCTAssertEqual(value.velocity, magnifyVelocity, file: file, line: line)
        XCTAssertEqual(value.startAnchor, magnifyStartAnchor, file: file, line: line)
        XCTAssertEqual(value.startLocation, magnifyStartLocation, file: file, line: line)
    }
}

@available(iOS 17.0, macOS 14.0, *)
extension MagnifyGestureTests: @unchecked Sendable { }
#endif
