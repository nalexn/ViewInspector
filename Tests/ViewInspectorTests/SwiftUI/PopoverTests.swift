import XCTest
import SwiftUI
@testable import ViewInspector

#if !os(tvOS)

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
final class PopoverTests: XCTestCase {
    
    func testBaseView() throws {
        let binding = Binding(wrappedValue: true)
        let sut = EmptyView().popover(isPresented: binding, content: { Text("") })
        if #available(iOS 14.2, macOS 11.0, *) {
            XCTAssertNoThrow(try sut.inspect().emptyView())
        } else if #available(iOS 14, macOS 10.16, *) {
            XCTAssertThrows(try sut.inspect().emptyView(),
                            "Unwrapping the view under popover is not supported on iOS 14.0 and 14.1")
        } else {
            XCTAssertNoThrow(try sut.inspect().emptyView())
        }
    }
    
    func testPopoverUnwrapping() throws {
        guard #available(iOS 14.2, macOS 11.0, *) else { return }
        let binding = Binding(wrappedValue: true)
        let sut = EmptyView().popover(isPresented: binding, content: { Text("") })
        XCTAssertNoThrow(try sut.inspect().emptyView().popover())
    }
    
    func testPopoverContentView() throws {
        guard #available(iOS 14.2, macOS 11.0, *) else { return }
        let binding = Binding(wrappedValue: true)
        let sut = EmptyView().popover(isPresented: binding, content: { Text("test") })
        let popover = try sut.inspect().emptyView().popover()
        XCTAssertThrows(try popover.contentView(),
                        "Please substitute 'Text.self' as the parameter for 'contentView()' inspection call")
        let value = try popover.contentView(Text.self).text().string()
        XCTAssertEqual(value, "test")
    }
    
    func testSearchBlocker() throws {
        guard #available(iOS 14.2, macOS 11.0, *) else { return }
        let binding = Binding(wrappedValue: true)
        let sut = EmptyView().popover(isPresented: binding, content: { Text("abc") })
        XCTAssertThrows(try sut.inspect().find(text: "abc"),
                        "Search did not find a match. Possible blockers: popover")
    }
    
    func testArrowEdge() throws {
        guard #available(iOS 14.2, macOS 11.0, *) else { return }
        let binding = Binding(wrappedValue: true)
        let sut = EmptyView()
            .popover(isPresented: binding, arrowEdge: .top) { Text("") }
        let value = try sut.inspect().emptyView().popover().arrowEdge()
        XCTAssertEqual(value, .top)
    }
    
    func testAttachmentAnchor() throws {
        guard #available(iOS 14.2, macOS 11.0, *) else { return }
        let binding = Binding(wrappedValue: true)
        let anchor = PopoverAttachmentAnchor.point(.bottom)
        let sut = EmptyView()
            .popover(isPresented: binding,
                     attachmentAnchor: anchor) { Text("") }
        let value = try sut.inspect().emptyView().popover().attachmentAnchor()
        XCTAssertEqual(value, anchor)
    }
    
    func testIsPresentedAndDismiss() throws {
        guard #available(iOS 14.2, macOS 11.0, *) else { return }
        let binding = Binding(wrappedValue: true)
        let sut = EmptyView().popover(isPresented: binding) { Text("") }
        let popover = try sut.inspect().emptyView().popover()
        XCTAssertTrue(try popover.isPresented())
        try popover.dismiss()
        XCTAssertFalse(try popover.isPresented())
    }
    
    func testPathToRoot() throws {
        guard #available(iOS 14.2, macOS 11.0, *) else { return }
        let binding = Binding(wrappedValue: true)
        let view = EmptyView().popover(isPresented: binding) { Text("") }
        let sut = try view.inspect().emptyView().popover().pathToRoot
        XCTAssertEqual(sut, "emptyView().popover()")
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
final class PopoverAttachmentAnchorTests: XCTestCase {
    func testEquatable() {
        let values = [
            PopoverAttachmentAnchor.point(.bottom),
            .point(.bottomLeading),
            .rect(.bounds),
            .rect(.rect(.zero))
        ]
        for index in 0 ..< values.count {
            let next = (index + 1) % values.count
            XCTAssertEqual(values[index], values[index])
            XCTAssertNotEqual(values[index], values[next])
        }
    }
}

#endif
