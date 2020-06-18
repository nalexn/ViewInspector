import XCTest
import SwiftUI
import Combine
@testable import ViewInspector

// MARK: - InteractionTests

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
final class InteractionTests: XCTestCase {
    
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
    #endif
    
    #if os(macOS)
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
    #endif
    
    #if os(tvOS) || os(macOS)
    func testOnExitCommand() throws {
        let sut = EmptyView().onExitCommand { }
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    #endif
    
    #if os(macOS)
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

// MARK: - ViewHoverTests

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
final class ViewHoverTests: XCTestCase {
    
    #if os(macOS)
    func testOnHover() throws {
        let sut = EmptyView().onHover { _ in }
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }

    /* Not supported
    func testOnHoverInspection() throws {
        let exp = XCTestExpectation(description: "onHover")
        let sut = EmptyView().onHover { value in
            XCTAssertTrue(value)
            exp.fulfill()
        }
        try sut.inspect().emptyView().callOnHover()
        wait(for: [exp], timeout: 0.1)
    }
    */
    #endif
    
    #if !os(iOS)
    func testFocusable() throws {
        let sut = EmptyView().focusable(true) { _ in }
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testFocusableInspection() throws {
        let exp = XCTestExpectation(description: "focusable")
        let sut = EmptyView().focusable(true) { value in
            // value is always false
            // XCTAssertTrue(value)
            exp.fulfill()
        }
        try sut.inspect().emptyView().callOnFocusChange()
        wait(for: [exp], timeout: 0.1)
    }
    #endif
}

// MARK: - ViewDragDropTests

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
final class ViewDragDropTests: XCTestCase {
    
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
        let binding = Binding(wrappedValue: true)
        let sut = EmptyView().onDrop(of: [], isTargeted: binding, perform: { _ in false })
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
