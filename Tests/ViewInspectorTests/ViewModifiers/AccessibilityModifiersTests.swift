import XCTest
import SwiftUI
import Combine
@testable import ViewInspector

// MARK: - ViewAccessibilityTests

final class ViewAccessibilityTests: XCTestCase {
    
    func testAccessibilityLabel() throws {
        let sut = EmptyView().accessibility(label: Text(""))
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testAccessibilityValue() throws {
        let sut = EmptyView().accessibility(value: Text(""))
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testAccessibilityHint() throws {
        let sut = EmptyView().accessibility(hint: Text(""))
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testAccessibilityHidden() throws {
        let sut = EmptyView().accessibility(hidden: true)
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testAccessibilityIdentifier() throws {
        let sut = EmptyView().accessibility(identifier: "")
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testAccessibilitySelectionIdentifier() throws {
        let sut = EmptyView().accessibility(selectionIdentifier: "")
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testAccessibilityActivationPoint() throws {
        let sut = EmptyView().accessibility(activationPoint: .center)
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testAccessibilityAction() throws {
        let sut = EmptyView().accessibilityAction(.default) { }
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testAccessibilityAdjustableAction() throws {
        let sut = EmptyView().accessibilityAdjustableAction { _ in }
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testAccessibilityScrollAction() throws {
        let sut = EmptyView().accessibilityScrollAction { _ in }
        XCTAssertNoThrow(try sut.inspect().emptyView())
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
}
