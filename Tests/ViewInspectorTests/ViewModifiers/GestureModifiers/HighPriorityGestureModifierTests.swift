import XCTest
import SwiftUI
import Combine
@testable import ViewInspector

// MARK: - High Priority Gesture Modifier Tests

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
final class HighPriorityGestureModifierTests: XCTestCase {

    func testHighPriorityGesture() throws {
        let sut = EmptyView()
            .highPriorityGesture(DragGesture())
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testHighPriorityGestureDoesNotBlock() throws {
        let sut = EmptyView()
            .highPriorityGesture(DragGesture())
            .padding(100)
        let padding = try sut.inspect().emptyView().padding(.top)
        XCTAssertEqual(padding, 100)
    }

    func testHighPriorityGestureInspection() throws {
        let sut = EmptyView()
            .highPriorityGesture(DragGesture())
        XCTAssertNoThrow(try sut.inspect().emptyView().highPriorityGesture(DragGesture.self))
    }
    
    func testHighPriorityGestureInspectionFailureDueToNoModifier() throws {
        let sut = EmptyView()
        XCTAssertThrows(
            try sut.inspect().emptyView().highPriorityGesture(DragGesture.self),
            "EmptyView does not have 'highPriorityGesture' modifier")
    }
    
    func testHighPriorityGestureInspectionFailureDueToTypeMismatch() throws {
        let sut = EmptyView()
            .highPriorityGesture(LongPressGesture())
        XCTAssertThrows(
            try sut.inspect().emptyView().highPriorityGesture(DragGesture.self),
            "Type mismatch: LongPressGesture is not DragGesture")
    }
    
    func testHighPriorityGestureInspectionWithIndex1() throws {
        let sut = EmptyView()
            .highPriorityGesture(DragGesture())
            .highPriorityGesture(LongPressGesture())
        XCTAssertNoThrow(try sut.inspect().emptyView().highPriorityGesture(DragGesture.self, 0))
        XCTAssertNoThrow(try sut.inspect().emptyView().highPriorityGesture(LongPressGesture.self, 1))
    }
    
    func testHighPriorityGestureInspectionWithIndex2() throws {
        let sut = EmptyView()
            .highPriorityGesture(DragGesture())
            .gesture(TapGesture())
            .highPriorityGesture(LongPressGesture())
        XCTAssertNoThrow(try sut.inspect().emptyView().highPriorityGesture(DragGesture.self, 0))
        XCTAssertNoThrow(try sut.inspect().emptyView().highPriorityGesture(LongPressGesture.self, 1))
    }
    
    func testHighPriorityGestureInspectionWithIndexFailureDueToNoModifier() throws {
        let sut = EmptyView()
            .highPriorityGesture(DragGesture())
            .highPriorityGesture(LongPressGesture())
        XCTAssertThrows(
            try sut.inspect().emptyView().highPriorityGesture(DragGesture.self, 2),
            "EmptyView does not have 'highPriorityGesture' modifier")
    }
    
    func testHighPriorityGestureInspectionWithIndexFailureDueToTypeMismatch() throws {
        let sut = EmptyView()
            .highPriorityGesture(DragGesture())
            .highPriorityGesture(LongPressGesture())
        XCTAssertThrows(
            try sut.inspect().emptyView().highPriorityGesture(LongPressGesture.self, 0),
            "Type mismatch: DragGesture is not LongPressGesture")
    }
    
    func testHighPriorityGestureInspectionPathToRoot() throws {
        let sut = EmptyView()
            .padding(100)
            .highPriorityGesture(DragGesture())
        let path = try sut.inspect().emptyView().highPriorityGesture(DragGesture.self).pathToRoot
        XCTAssertEqual(path, "emptyView().highPriorityGesture(DragGesture.self)")
    }
    
    func testHighPriorityGestureInspectionWithIndexPathToRoot() throws {
        let sut = EmptyView()
            .padding(100)
            .highPriorityGesture(DragGesture())
            .highPriorityGesture(LongPressGesture())
        let path = try sut.inspect().emptyView().highPriorityGesture(LongPressGesture.self, 1).pathToRoot
        XCTAssertEqual(path, "emptyView().highPriorityGesture(LongPressGesture.self, 1)")
    }
}
