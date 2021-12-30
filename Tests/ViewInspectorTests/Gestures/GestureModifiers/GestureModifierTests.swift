import XCTest
import SwiftUI
import Combine
@testable import ViewInspector

// MARK: - Gesture Modifier Tests

@available(iOS 13.0, macOS 10.15, *)
@available(tvOS, unavailable)
final class GestureModifierTests: XCTestCase {
    
    func testGesture() throws {
        let sut = EmptyView().gesture(DragGesture())
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testGestureDoesNotBlock() throws {
        let sut = EmptyView().gesture(DragGesture()).padding(100)
        let padding = try sut.inspect().emptyView().padding(.top)
        XCTAssertEqual(padding, 100)
    }

    func testGestureInspection() throws {
        let sut = EmptyView()
            .gesture(DragGesture())
        XCTAssertNoThrow(try sut.inspect().emptyView().gesture(DragGesture.self))
    }
    
    func testGestureInspectionFailureDueToNoModifier() throws {
        let sut = EmptyView()
        XCTAssertThrows(
            try sut.inspect().emptyView().gesture(DragGesture.self),
            "EmptyView does not have 'gesture(DragGesture.self)' modifier")
    }
    
    func testGestureInspectionFailureDueToTypeMismatch() throws {
        guard #available(tvOS 14.0, *) else { throw XCTSkip() }
        let sut = EmptyView()
            .gesture(LongPressGesture())
        XCTAssertThrows(
            try sut.inspect().emptyView().gesture(DragGesture.self),
            "Type mismatch: LongPressGesture is not DragGesture")
    }
    
    func testGestureInspectionWithIndex1() throws {
        guard #available(tvOS 14.0, *) else { throw XCTSkip() }
        let sut = EmptyView()
            .gesture(DragGesture())
            .gesture(LongPressGesture())
        XCTAssertNoThrow(try sut.inspect().emptyView().gesture(DragGesture.self, 0))
        XCTAssertNoThrow(try sut.inspect().emptyView().gesture(LongPressGesture.self, 1))
    }
    
    func testGestureInspectionWithIndex2() throws {
        guard #available(tvOS 14.0, *) else { throw XCTSkip() }
        let sut = EmptyView()
            .gesture(DragGesture())
            .highPriorityGesture(TapGesture())
            .gesture(LongPressGesture())
        XCTAssertNoThrow(try sut.inspect().emptyView().gesture(DragGesture.self, 0))
        XCTAssertNoThrow(try sut.inspect().emptyView().gesture(LongPressGesture.self, 1))
    }
    
    func testGestureInspectionWithIndexFailureDueToNoModifier() throws {
        guard #available(tvOS 14.0, *) else { throw XCTSkip() }
        let sut = EmptyView()
            .gesture(DragGesture())
            .gesture(LongPressGesture())
        XCTAssertThrows(
            try sut.inspect().emptyView().gesture(DragGesture.self, 2),
            "EmptyView does not have 'gesture(DragGesture.self)' modifier at index 2")
    }
    
    func testGestureInspectionWithIndexFailureDueToTypeMismatch() throws {
        guard #available(tvOS 14.0, *) else { throw XCTSkip() }
        let sut = EmptyView()
            .gesture(DragGesture())
            .gesture(LongPressGesture())
        XCTAssertThrows(
            try sut.inspect().emptyView().gesture(LongPressGesture.self, 0),
            "Type mismatch: DragGesture is not LongPressGesture"
        )
    }
    
    func testGestureInspectionPathToRoot() throws {
        let sut = EmptyView()
            .padding(100)
            .gesture(DragGesture())
        let path = try sut.inspect().emptyView().gesture(DragGesture.self).pathToRoot
        XCTAssertEqual(path, "emptyView().gesture(DragGesture.self)")
    }
    
    func testGestureInspectionWithIndexPathToRoot() throws {
        guard #available(tvOS 14.0, *) else { throw XCTSkip() }
        let sut = EmptyView()
            .padding(100)
            .gesture(DragGesture())
            .gesture(LongPressGesture())
        let path = try sut.inspect().emptyView().gesture(LongPressGesture.self, 1).pathToRoot
        XCTAssertEqual(path, "emptyView().gesture(LongPressGesture.self, 1)")
    }
}
