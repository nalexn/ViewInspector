import XCTest
import SwiftUI
import Combine
@testable import ViewInspector

// MARK: - ViewAccessibilityTests

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
final class ViewAccessibilityTests: XCTestCase {
    
    func testAccessibilityLabel() throws {
        let sut = EmptyView().accessibility(label: Text(""))
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testAccessibilityLabelInspection() throws {
        let string = "abc"
        let sut = try EmptyView().accessibility(label: Text(string))
            .inspect().emptyView().accessibilityLabel().string()
        XCTAssertEqual(sut, string)
    }
    
    func testAccessibilityValue() throws {
        let sut = EmptyView().accessibility(value: Text(""))
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testAccessibilityValueInspection() throws {
        let string = "abc"
        let sut = try EmptyView().accessibility(value: Text(string))
            .inspect().emptyView().accessibilityValue().string()
        XCTAssertEqual(sut, string)
    }
    
    func testAccessibilityHint() throws {
        let sut = EmptyView().accessibility(hint: Text(""))
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testAccessibilityHintInspection() throws {
        let string = "abc"
        let sut = try EmptyView().accessibility(hint: Text(string))
            .inspect().emptyView().accessibilityHint().string()
        XCTAssertEqual(sut, string)
    }
    
    func testAccessibilityHidden() throws {
        let sut = EmptyView().accessibility(hidden: false)
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testAccessibilityHiddenInspection() throws {
        let sut1 = try EmptyView().accessibility(hidden: true)
            .inspect().emptyView().accessibilityHidden()
        XCTAssertTrue(sut1)
        let sut2 = try EmptyView().accessibility(hidden: false)
            .inspect().emptyView().accessibilityHidden()
        XCTAssertFalse(sut2)
    }
    
    func testAccessibilityIdentifier() throws {
        let sut = EmptyView().accessibility(identifier: "")
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testAccessibilityIdentifierInspection() throws {
        let string = "abc"
        let sut = try EmptyView().accessibility(identifier: string)
            .inspect().emptyView().accessibilityIdentifier()
        XCTAssertEqual(sut, string)
    }
    
    @available(iOS, deprecated, introduced: 13.0)
    @available(tvOS, deprecated, introduced: 13.0)
    @available(macOS, deprecated, introduced: 10.15)
    @available(watchOS, deprecated, introduced: 6)
    func testAccessibilitySelectionIdentifier() throws {
        guard #available(iOS 13.2, macOS 10.17, tvOS 13.2, *) else { return }
        let sut = EmptyView().accessibility(selectionIdentifier: "")
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    @available(iOS, deprecated, introduced: 13.0)
    @available(tvOS, deprecated, introduced: 13.0)
    @available(macOS, deprecated, introduced: 10.15)
    @available(watchOS, deprecated, introduced: 6)
    func testAccessibilitySelectionIdentifierInspection() throws {
        guard #available(iOS 13.2, macOS 10.17, tvOS 13.2, *) else { return }
        let string = "abc"
        let sut = try EmptyView().accessibility(selectionIdentifier: string)
            .inspect().emptyView().accessibilitySelectionIdentifier()
        XCTAssertEqual(sut, string)
    }
    
    func testAccessibilityActivationPoint() throws {
        let sut = EmptyView().accessibility(activationPoint: .center)
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testAccessibilityActivationPointInspection() throws {
        let point: UnitPoint = .bottomTrailing
        let sut = try EmptyView().accessibility(activationPoint: point)
            .inspect().emptyView().accessibilityActivationPoint()
        XCTAssertEqual(sut, point)
    }
    
    func testAccessibilityAction() throws {
        let sut = EmptyView().accessibilityAction(.default) { }
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testAccessibilityActionInspection() throws {
        let exp = XCTestExpectation(description: "accessibilityAction")
        let sut = EmptyView().accessibilityAction(.default) {
            exp.fulfill()
        }
        try sut.inspect().emptyView().callAccessibilityAction(.default)
        wait(for: [exp], timeout: 0.1)
    }
    
    func testAccessibilityActionInspectionError() throws {
        let sut = EmptyView().accessibilityAction(.escape) { }
        XCTAssertThrows(
            try sut.inspect().emptyView().callAccessibilityAction(.default),
            "EmptyView does not have 'accessibilityAction(.default)' modifier")
    }
    
    func testAccessibilityActionInspectionMultipleCallbacks() throws {
        let exp1 = XCTestExpectation(description: "accessibilityAction1")
        let exp2 = XCTestExpectation(description: "accessibilityAction2")
        exp1.assertForOverFulfill = true
        exp2.assertForOverFulfill = true
        exp1.expectedFulfillmentCount = 1
        exp2.expectedFulfillmentCount = 2
        let sut = EmptyView().accessibilityAction(.default) {
            exp1.fulfill()
        }.accessibilityAction(.escape) {
            exp2.fulfill()
        }
        let view = try sut.inspect().emptyView()
        try view.callAccessibilityAction(.escape)
        try view.callAccessibilityAction(.default)
        try view.callAccessibilityAction(.escape)
        wait(for: [exp1, exp2], timeout: 0.1)
    }
    
    func testAccessibilityAdjustableAction() throws {
        let sut = EmptyView().accessibilityAdjustableAction { _ in }
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testAccessibilityAdjustableActionInspection() throws {
        let exp = XCTestExpectation(description: "accessibilityAdjustableAction")
        let sut = EmptyView().accessibilityAdjustableAction { direction in
            XCTAssertEqual(direction, .decrement)
            exp.fulfill()
        }
        try sut.inspect().emptyView().callAccessibilityAdjustableAction(.decrement)
        wait(for: [exp], timeout: 0.1)
    }
    
    func testAccessibilityScrollAction() throws {
        let sut = EmptyView().accessibilityScrollAction { _ in }
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testAccessibilityScrollActionInspection() throws {
        let exp = XCTestExpectation(description: "accessibilityScrollAction")
        let sut = EmptyView().accessibilityScrollAction { edge in
            XCTAssertEqual(edge, .leading)
            exp.fulfill()
        }
        try sut.inspect().emptyView().callAccessibilityScrollAction(.leading)
        wait(for: [exp], timeout: 0.1)
    }
    
    func testAccessibilityElement() throws {
        let sut = EmptyView().accessibilityElement(children: .contain)
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testAccessibilityAddTraits() throws {
        let sut = EmptyView().accessibility(addTraits: AccessibilityTraits())
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testAccessibilityRemoveTraits() throws {
        let sut = EmptyView().accessibility(removeTraits: AccessibilityTraits())
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testAccessibilitySortPriority() throws {
        let sut = EmptyView().accessibility(sortPriority: 5)
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testAccessibilitySortPriorityInspection() throws {
        let sut = try EmptyView().accessibility(sortPriority: 6)
            .inspect().emptyView().accessibilitySortPriority()
        XCTAssertEqual(sut, 6)
    }

    func testAccessibilityMultipleAttributes() throws {
        let label = "abc"
        let value = "xyz"
        let sut = try EmptyView()
            .accessibility(label: Text(label))
            .accessibility(value: Text(value))
            .accessibility(addTraits: [.isImage])
            .inspect().emptyView()

        XCTAssertEqual(try sut.accessibilityLabel().string(), label)
        XCTAssertEqual(try sut.accessibilityValue().string(), value)
    }
    
    func testMissingAccessibilityAttribute() throws {
        let sut = try EmptyView()
            .accessibility(label: Text("test"))
            .accessibility(addTraits: [.isImage])
            .inspect().emptyView()
        XCTAssertThrows(
            try sut.accessibilityValue(),
            "EmptyView does not have 'accessibilityValue' modifier")
    }
}
