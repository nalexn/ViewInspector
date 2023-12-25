#if !os(visionOS)

import XCTest
import SwiftUI
import Combine
@testable import ViewInspector

// MARK: - Spatial Tap Gesture Tests

@available(iOS 16.0, macOS 13.0, watchOS 9.0, *)
@available(tvOS, unavailable)
final class SpatialTapGestureTests: XCTestCase {

    var spatialTapLocation: CGPoint?
    var spatialTapValue: SpatialTapGesture.Value?

    var gestureTests: CommonGestureTests<SpatialTapGesture>?

    override func setUpWithError() throws {
        spatialTapLocation = CGPoint(x: 100, y: 100)
        spatialTapValue = SpatialTapGesture.Value(location: spatialTapLocation!)

        gestureTests = CommonGestureTests<SpatialTapGesture>(testCase: self,
                                                             gesture: SpatialTapGesture(),
                                                             value: spatialTapValue!,
                                                             assert: assertSpatialTapValue)
    }

    override func tearDownWithError() throws {
        spatialTapLocation = nil
        spatialTapValue = nil
        gestureTests = nil
    }

    func testCreateSpatialTapGestureValue() throws {
        XCTAssertNotNil(spatialTapLocation)
        let value = try XCTUnwrap(spatialTapValue)
        assertSpatialTapValue(value)
    }

    func testSpatialTapGestureMask() throws {
        try gestureTests!.maskTest()
    }

    func testSpatialTapGesture() throws {
        let sut = EmptyView().gesture(SpatialTapGesture(count: 2, coordinateSpace: .global))
        let spatialTapGesture = try sut.inspect().emptyView().gesture(SpatialTapGesture.self).actualGesture()
        XCTAssertEqual(spatialTapGesture.count, 2)
        XCTAssertEqual(spatialTapGesture.coordinateSpace, .global)
    }

    func testSpatialTapGestureWithUpdatingModifier() throws {
        try gestureTests!.propertiesWithUpdatingModifierTest()
    }

    func testSpatialTapGestureWithOnChangedModifier() throws {
        try gestureTests!.propertiesWithOnChangedModifierTest()
    }

    func testSpatialTapGestureWithOnEndedModifier() throws {
        try gestureTests!.propertiesWithOnEndedModifierTest()
    }

    #if os(macOS)
    func testSpatialTapGestureWithModifiers() throws {
        try gestureTests!.propertiesWithModifiersTest()
    }
    #endif

    func testSpatialTapGestureFailure() throws {
        try gestureTests!.propertiesFailureTest("SpatialTapGesture")
    }

    func testSpatialTapGestureCallUpdating() throws {
        try gestureTests!.callUpdatingTest()
    }

    func testSpatialTapGestureCallUpdatingNotFirst() throws {
        try gestureTests!.callUpdatingNotFirstTest()
    }

    func testSpatialTapGestureCallUpdatingMultiple() throws {
        try gestureTests!.callUpdatingMultipleTest()
    }

    func testSpatialTapGestureCallUpdatingFailure() throws {
        try gestureTests!.callUpdatingFailureTest()
    }

    func testSpatialTapGestureCallOnChanged() throws {
        try gestureTests!.callOnChangedTest()
    }

    func testSpatialTapGestureCallOnChangedNotFirst() throws {
        try gestureTests!.callOnChangedNotFirstTest()
    }

    func testSpatialTapGestureCallOnChangedMultiple() throws {
        try gestureTests!.callOnChangedMultipleTest()
    }

    func testSpatialTapGestureCallOnChangedFailure() throws {
        try gestureTests!.callOnChangedFailureTest()
    }

    func testSpatialTapGestureCallOnEnded() throws {
        try gestureTests!.callOnEndedTest()
    }

    func testSpatialTapGestureCallOnEndedNotFirst() throws {
        try gestureTests!.callOnEndedNotFirstTest()
    }

    func testSpatialTapGestureCallOnEndedMultiple() throws {
        try gestureTests!.callOnEndedMultipleTest()
    }

    func testSpatialTapGestureCallOnEndedFailure() throws {
        try gestureTests!.callOnEndedFailureTest()
    }

    #if os(macOS)
    func testSpatialTapGestureModifiers() throws {
        try gestureTests!.modifiersTest()
    }

    func testSpatialTapGestureModifiersNotFirst() throws {
        try gestureTests!.modifiersNotFirstTest()
    }

    func testSpatialTapGestureModifiersMultiple() throws {
        try gestureTests!.modifiersMultipleTest()
    }

    func testSpatialTapGestureModifiersNone() throws {
        try gestureTests!.modifiersNoneTest()
    }
    #endif

    func assertSpatialTapValue(
        _ value: SpatialTapGesture.Value,
        file: StaticString = #filePath,
        line: UInt = #line) {
        XCTAssertEqual(value, SpatialTapGesture.Value(location: spatialTapLocation!))
    }
}
#endif
