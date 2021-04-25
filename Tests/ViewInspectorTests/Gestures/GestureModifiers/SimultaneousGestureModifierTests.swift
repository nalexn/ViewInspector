import XCTest
import SwiftUI
import Combine
@testable import ViewInspector

// MARK: - Simultaneous Gesture Modifier Tests

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
final class SimultaneousGestureModifierTests: XCTestCase {
    
    func testSimultaneousGesture() throws {
        let sut = EmptyView()
            .simultaneousGesture(DragGesture())
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testSimultaneousGestureDoesNotBlock() throws {
        let sut = EmptyView()
            .simultaneousGesture(DragGesture())
            .padding(100)
        let padding = try sut.inspect().emptyView().padding(.top)
        XCTAssertEqual(padding, 100)
    }

    func testSimultaneousGestureInspection() throws {
        let sut = EmptyView()
            .simultaneousGesture(DragGesture())
        XCTAssertNoThrow(try sut.inspect().emptyView().simultaneousGesture(DragGesture.self))
    }
    
    func testSimultaneousGestureInspectionFailureDueToNoModifier() throws {
        let sut = EmptyView()
        XCTAssertThrows(
            try sut.inspect().emptyView().simultaneousGesture(DragGesture.self),
            "EmptyView does not have 'simultaneousGesture(DragGesture.self)' modifier")
    }
    
    func testSimultaneousGestureInspectionFailureDueToTypeMismatch() throws {
        let sut = EmptyView()
            .simultaneousGesture(LongPressGesture())
        XCTAssertThrows(
            try sut.inspect().emptyView().simultaneousGesture(DragGesture.self),
            "Type mismatch: LongPressGesture is not DragGesture")
    }
    
    func testSimultaneousGestureInspectionWithIndex1() throws {
        let sut = EmptyView()
            .simultaneousGesture(DragGesture())
            .simultaneousGesture(LongPressGesture())
        XCTAssertNoThrow(try sut.inspect().emptyView().simultaneousGesture(DragGesture.self, 0))
        XCTAssertNoThrow(try sut.inspect().emptyView().simultaneousGesture(LongPressGesture.self, 1))
    }
    
    func testSimultaneousGestureInspectionWithIndex2() throws {
        let sut = EmptyView()
            .simultaneousGesture(DragGesture())
            .gesture(TapGesture())
            .simultaneousGesture(LongPressGesture())
        XCTAssertNoThrow(try sut.inspect().emptyView().simultaneousGesture(DragGesture.self, 0))
        XCTAssertNoThrow(try sut.inspect().emptyView().simultaneousGesture(LongPressGesture.self, 1))
    }
    
    func testSimultaneousGestureInspectionWithIndexFailureDueToNoModifier() throws {
        let sut = EmptyView()
            .simultaneousGesture(DragGesture())
            .simultaneousGesture(LongPressGesture())
        XCTAssertThrows(
            try sut.inspect().emptyView().simultaneousGesture(DragGesture.self, 2),
            "EmptyView does not have 'simultaneousGesture(DragGesture.self)' modifier at index 2")
    }
    
    func testSimultaneousGestureInspectionWithIndexFailureDueToTypeMismatch() throws {
        let sut = EmptyView()
            .simultaneousGesture(DragGesture())
            .simultaneousGesture(LongPressGesture())
        XCTAssertThrows(
            try sut.inspect().emptyView().simultaneousGesture(LongPressGesture.self, 0),
            "Type mismatch: DragGesture is not LongPressGesture")
    }
    
    func testSimultaneousGestureInspectionPathToRoot() throws {
        let sut = EmptyView()
            .padding(100)
            .simultaneousGesture(DragGesture())
        let path = try sut.inspect().emptyView().simultaneousGesture(DragGesture.self).pathToRoot
        XCTAssertEqual(path, "emptyView().simultaneousGesture(DragGesture.self)")
    }
    
    func testSimultaneousGestureInspectionWithIndexPathToRoot() throws {
        let sut = EmptyView()
            .padding(100)
            .simultaneousGesture(DragGesture())
            .simultaneousGesture(LongPressGesture())
        let path = try sut.inspect().emptyView().simultaneousGesture(LongPressGesture.self, 1).pathToRoot
        XCTAssertEqual(path, "emptyView().simultaneousGesture(LongPressGesture.self, 1)")
    }
}
