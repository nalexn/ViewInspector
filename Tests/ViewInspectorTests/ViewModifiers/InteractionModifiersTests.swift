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
    
    func testOnTapGestureInspection() throws {
        let exp = XCTestExpectation(description: "onAppear")
        let sut = EmptyView().onTapGesture {
            exp.fulfill()
        }.onLongPressGesture { }
        try sut.inspect().emptyView().callOnTapGesture()
        wait(for: [exp], timeout: 0.1)
    }
    
    func testOnLongPressGesture() throws {
        let sut = EmptyView().onLongPressGesture { }
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testOnLongPressGestureInspection() throws {
        let exp = XCTestExpectation(description: "onLongPressGesture")
        let sut = EmptyView().onLongPressGesture {
            exp.fulfill()
        }.onTapGesture { }
        try sut.inspect().emptyView().callOnLongPressGesture()
        wait(for: [exp], timeout: 0.1)
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
    
    func testTransactionInspection() throws {
        let exp = XCTestExpectation(description: "transaction")
        let sut = EmptyView().transaction { _ in
            exp.fulfill()
        }
        try sut.inspect().emptyView().callTransaction()
        wait(for: [exp], timeout: 0.1)
    }
}

// MARK: - ViewEventsTests

final class ViewEventsTests: XCTestCase {
    
    func testOnAppear() throws {
        let sut = EmptyView().onAppear { }
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testOnAppearInspection() throws {
        let exp = XCTestExpectation(description: "onAppear")
        let sut = EmptyView().padding().onAppear {
            exp.fulfill()
        }.padding().onDisappear(perform: { })
        try sut.inspect().emptyView().callOnAppear()
        wait(for: [exp], timeout: 0.1)
    }
    
    func testOnDisappear() throws {
        let sut = EmptyView().onDisappear { }
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testOnDisappearInspection() throws {
        let exp = XCTestExpectation(description: "onDisappear")
        let sut = EmptyView().onAppear(perform: { }).padding()
            .onDisappear {
                exp.fulfill()
            }.padding()
        try sut.inspect().emptyView().callOnDisappear()
        wait(for: [exp], timeout: 0.1)
    }
    
    #if os(macOS)
    func testOnCutCommand() throws {
        let sut = EmptyView().onCutCommand { [] }
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testOnCutCommandInspection() throws {
        let exp = XCTestExpectation(description: "onCutCommand")
        let sut = EmptyView().onCutCommand {
            exp.fulfill()
            return []
        }.onCopyCommand { [] }
        try sut.inspect().emptyView().callOnCutCommand()
        wait(for: [exp], timeout: 0.1)
    }
    
    func testOnCopyCommand() throws {
        let sut = EmptyView().onCopyCommand { [] }
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testOnCopyCommandInspection() throws {
        let exp = XCTestExpectation(description: "onCopyCommand")
        let sut = EmptyView().onCopyCommand {
            exp.fulfill()
            return []
        }.onCutCommand { [] }
        try sut.inspect().emptyView().callOnCopyCommand()
        wait(for: [exp], timeout: 0.1)
    }
    
    func testOnPasteCommand() throws {
        let sut = EmptyView().onPasteCommand(of: []) { _ in }
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    /* Not Supported:
     
    func testOnPasteCommandInspection() throws {
        let exp = XCTestExpectation(description: "onPasteCommand")
        let sut = EmptyView().onPasteCommand(of: []) { _ in
            exp.fulfill()
        }
        try sut.inspect().emptyView().callOnPasteCommand()
        wait(for: [exp], timeout: 0.1)
    }
    */
    
    func testOnPasteCommandPayload() throws {
        let sut = EmptyView()
            .onPasteCommand(of: [], validator: { _ in nil as Void? }, perform: { _ in })
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testOnDeleteCommand() throws {
        let sut = EmptyView().onDeleteCommand { }
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testOnDeleteCommandInspection() throws {
        let exp = XCTestExpectation(description: "onDeleteCommand")
        let sut = EmptyView().onDeleteCommand {
            exp.fulfill()
        }.onCutCommand { [] }
        try sut.inspect().emptyView().callOnDeleteCommand()
        wait(for: [exp], timeout: 0.1)
    }
    #endif
    
    #if os(tvOS) || os(macOS)
    func testOnMoveCommand() throws {
        let sut = EmptyView().onMoveCommand { _ in }
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testOnMoveCommandInspection() throws {
        let exp = XCTestExpectation(description: "onMoveCommand")
        let directions: [MoveCommandDirection] = [.left, .right, .up, .down]
        var moves: [MoveCommandDirection] = []
        let sut = EmptyView().onMoveCommand { move in
            moves.append(move)
            if moves.count == directions.count {
                XCTAssertEqual(moves, directions)
                exp.fulfill()
            }
        }
        let view = try sut.inspect().emptyView()
        try directions.forEach {
            try view.callOnMoveCommand($0)
        }
        wait(for: [exp], timeout: 0.1)
    }
    
    func testOnExitCommand() throws {
        let sut = EmptyView().onExitCommand { }
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testOnExitCommandInspection() throws {
        let exp = XCTestExpectation(description: "onExitCommand")
        let sut = EmptyView().onExitCommand {
            exp.fulfill()
        }
        try sut.inspect().emptyView().callOnExitCommand()
        wait(for: [exp], timeout: 0.1)
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
    
    func testOnCommandInspection() throws {
        let exp = XCTestExpectation(description: "onCommand")
        let sut = EmptyView().onCommand(#selector(setUp)) {
            exp.fulfill()
        }
        try sut.inspect().emptyView().callOnCommand(#selector(setUp))
        wait(for: [exp], timeout: 0.1)
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

// MARK: - ViewHitTestingTests

final class ViewHitTestingTests: XCTestCase {
    
    func testAllowsHitTesting() throws {
        let sut = EmptyView().allowsHitTesting(true)
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testContentShape() throws {
        let sut = EmptyView().contentShape(Capsule(), eoFill: true)
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
}
