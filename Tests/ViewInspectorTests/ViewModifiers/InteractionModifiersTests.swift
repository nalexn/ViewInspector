import XCTest
import SwiftUI
import Combine
@testable import ViewInspector

// MARK: - ViewGesturesTests

final class ViewGesturesTests: XCTestCase {
    
    @State private var floatValue: Float = 0
    
    #if !os(tvOS)
    func testOnTapGesture() throws {
        let sut = EmptyView().onTapGesture(count: 5, perform: { })
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testOnLongPressGesture() throws {
        let sut = EmptyView().onLongPressGesture { }
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testGesture() throws {
        let sut = EmptyView().gesture(MagnificationGesture(), including: .subviews)
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testHighPriorityGesture() throws {
        let sut = EmptyView().highPriorityGesture(MagnificationGesture(), including: .subviews)
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testSimultaneousGesture() throws {
        let sut = EmptyView().simultaneousGesture(MagnificationGesture(), including: .subviews)
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    #endif
    
    #if os(watchOS)
    func testDigitalCrownRotation() throws {
        let sut = EmptyView().digitalCrownRotation(self.$floatValue)
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testDigitalCrownRotationExtended() throws {
        let sut = EmptyView().digitalCrownRotation(
            self.$floatValue, from: 5, through: 5, by: 5, sensitivity: .low,
            isContinuous: true, isHapticFeedbackEnabled: true)
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    #endif
    
    func testTransaction() throws {
        let sut = EmptyView().transaction { _ in }
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
}

// MARK: - ViewEventsTests

final class ViewEventsTests: XCTestCase {
    
    func testOnAppear() throws {
        let sut = EmptyView().onAppear { }
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testOnDisappear() throws {
        let sut = EmptyView().onDisappear { }
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    #if os(macOS)
    func testOnCutCommand() throws {
        let sut = EmptyView().onCutCommand { [] }
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testOnCopyCommand() throws {
        let sut = EmptyView().onCopyCommand { [] }
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testOnPasteCommand() throws {
        let sut = EmptyView().onPasteCommand(of: []) { _ in }
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testOnPasteCommandPayload() throws {
        let sut = EmptyView()
            .onPasteCommand(of: [], validator: { _ in nil as Void? }, perform: { _ in })
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testOnDeleteCommand() throws {
        let sut = EmptyView().onDeleteCommand { }
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    #endif
    
    #if os(tvOS) || os(macOS)
    func testOnMoveCommand() throws {
        let sut = EmptyView().onMoveCommand { _ in }
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testOnExitCommand() throws {
        let sut = EmptyView().onExitCommand { }
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    #endif
    
    #if os(tvOS)
    func testOnPlayPauseCommand() throws {
        let sut = EmptyView().onPlayPauseCommand { }
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    #endif
    
    #if os(macOS)
    func testOnCommand() throws {
        let sut = EmptyView().onCommand(#selector(setUp)) { }
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    #endif
    
    func testDeleteDisabled() throws {
        let sut = EmptyView().deleteDisabled(true)
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testMoveDisabled() throws {
        let sut = EmptyView().moveDisabled(true)
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
}

// MARK: - ViewPublisherEventsTests

final class ViewPublisherEventsTests: XCTestCase {
    
    func testOnReceive() throws {
        let publisher = Just<Void>(())
        let sut = EmptyView().onReceive(publisher) { _ in }
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
}

// MARK: - ViewHoverTests

final class ViewHoverTests: XCTestCase {
    
    #if os(macOS)
    func testOnHover() throws {
        let sut = EmptyView().onHover { _ in }
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    #endif
    
    #if !os(iOS)
    func testFocusable() throws {
        let sut = EmptyView().focusable(true) { _ in }
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    #endif
}

// MARK: - ViewDragDropTests

final class ViewDragDropTests: XCTestCase {
    
    @State private var value: Bool = false
    
    #if os(macOS)
    func testOnDrag() throws {
        let sut = EmptyView().onDrag { NSItemProvider() }
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testOnDropDelegate() throws {
        let sut = EmptyView().onDrop(of: [], delegate: DummyDropDelegate())
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testOnDropCallback() throws {
        let sut = EmptyView().onDrop(of: [], isTargeted: $value, perform: { _ in false })
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    #endif
    
    func testItemProvider() throws {
        let sut = EmptyView().itemProvider { nil }
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    #if os(macOS)
    struct DummyDropDelegate: DropDelegate {
        func performDrop(info: DropInfo) -> Bool { false }
    }
    #endif
}

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
