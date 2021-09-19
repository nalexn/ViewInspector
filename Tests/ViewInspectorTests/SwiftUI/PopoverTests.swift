import XCTest
import SwiftUI
@testable import ViewInspector

#if os(iOS) || os(macOS)

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
final class PopoverTests: XCTestCase {
    
    func testPopover() throws {
        let binding = Binding(wrappedValue: true)
        let sut = EmptyView().popover(isPresented: binding) { Text("") }
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testInspectionErrorNoModifier() throws {
        let sut = EmptyView().offset()
        XCTAssertThrows(try sut.inspect().emptyView().popover(),
                        "EmptyView does not have 'popover' modifier")
    }
    
    func testInspectionErrorCustomModifierRequired() throws {
        let binding = Binding(wrappedValue: true)
        let sut = EmptyView().popover(isPresented: binding) { Text("") }
        print("\(Inspector.print(sut) as AnyObject)")
        XCTAssertThrows(try sut.inspect().emptyView().popover(),
            """
            Please refer to the Guide for inspecting the Popover: \
            https://github.com/nalexn/ViewInspector/blob/master/guide.md#alert-sheet-actionsheet-and-fullscreencover
            """)
    }
    
    func testInspectionErrorPopoverNotPresented() throws {
        let binding = Binding(wrappedValue: false)
        let sut = EmptyView().popover2(isPresented: binding) { Text("") }
        XCTAssertThrows(try sut.inspect().emptyView().popover(),
                        "View for Popover is absent")
    }
    
    func testInspectionErrorPopoverWithItemNotPresented() throws {
        let binding = Binding<Int?>(wrappedValue: nil)
        let sut = EmptyView().popover2(item: binding) { Text("\($0)") }
        XCTAssertThrows(try sut.inspect().emptyView().popover(),
                        "View for Popover is absent")
    }
    
    func testContentInspection() throws {
        let binding = Binding(wrappedValue: true)
        let sut = EmptyView().popover2(isPresented: binding) {
            Text("abc")
        }
        let title = try sut.inspect().emptyView().popover().text()
        XCTAssertEqual(try title.string(), "abc")
        XCTAssertEqual(title.pathToRoot, "emptyView().popover().text()")
    }
    
    func testContentInteraction() throws {
        let binding = Binding(wrappedValue: true)
        let sut = EmptyView().popover2(isPresented: binding) {
            Text("abc")
            Button("xyz", action: { binding.wrappedValue = false })
        }
        let button = try sut.inspect().emptyView().popover().button(1)
        try button.tap()
        XCTAssertFalse(binding.wrappedValue)
        XCTAssertEqual(button.pathToRoot, "emptyView().popover().button(1)")
    }
    
    func testDismiss() throws {
        let binding = Binding(wrappedValue: true)
        let sut = EmptyView().popover2(isPresented: binding, content: { Text("") })
        XCTAssertTrue(binding.wrappedValue)
        try sut.inspect().popover().dismiss()
        XCTAssertFalse(binding.wrappedValue)
        XCTAssertThrows(try sut.inspect().popover(), "View for Popover is absent")
    }
    
    func testDismissForItemVersion() throws {
        let binding = Binding<Int?>(wrappedValue: 6)
        let sut = EmptyView().popover2(item: binding) { Text("\($0)") }
        let popover = try sut.inspect().emptyView().popover()
        XCTAssertEqual(try popover.text().string(), "6")
        XCTAssertEqual(binding.wrappedValue, 6)
        try popover.dismiss()
        XCTAssertNil(binding.wrappedValue)
        XCTAssertThrows(try sut.inspect().popover(), "View for Popover is absent")
    }
    
    func testMultiplePopoversInspection() throws {
        let binding1 = Binding(wrappedValue: true)
        let binding2 = Binding(wrappedValue: true)
        let binding3 = Binding(wrappedValue: true)
        let sut = PopoverFindTestView(popover1: binding1, popover2: binding2, popover3: binding3)
        let title1 = try sut.inspect().hStack().emptyView(0).popover().text(0)
        XCTAssertEqual(try title1.string(), "title_1")
        XCTAssertEqual(title1.pathToRoot,
            "view(PopoverFindTestView.self).hStack().emptyView(0).popover().text(0)")
        let title2 = try sut.inspect().hStack().emptyView(0).popover(1).text(0)
        XCTAssertEqual(try title2.string(), "title_3")
        XCTAssertEqual(title2.pathToRoot,
            "view(PopoverFindTestView.self).hStack().emptyView(0).popover(1).text(0)")
        
        XCTAssertEqual(try sut.inspect().find(ViewType.Popover.self).text(0).string(), "title_1")
        binding1.wrappedValue = false
        XCTAssertEqual(try sut.inspect().find(ViewType.Popover.self).text(0).string(), "title_3")
        binding3.wrappedValue = false
        XCTAssertThrows(try sut.inspect().find(ViewType.Popover.self),
                        "Search did not find a match")
    }
    
    func testFindAndPathToRoots() throws {
        let binding = Binding(wrappedValue: true)
        let sut = PopoverFindTestView(popover1: binding, popover2: binding, popover3: binding)
        
        // 1
        XCTAssertEqual(try sut.inspect().find(text: "title_1").pathToRoot,
            "view(PopoverFindTestView.self).hStack().emptyView(0).popover().text(0)")
        XCTAssertEqual(try sut.inspect().find(text: "button_1").pathToRoot,
            "view(PopoverFindTestView.self).hStack().emptyView(0).popover().button(1).labelView().text()")
        // 2
        XCTAssertThrows(try sut.inspect().find(text: "title_2").pathToRoot,
            "Search did not find a match")
        
        // 3
        XCTAssertEqual(try sut.inspect().find(text: "title_3").pathToRoot,
            "view(PopoverFindTestView.self).hStack().emptyView(0).popover(1).text(0)")
        
        XCTAssertThrows(try sut.inspect().find(text: "message_3").pathToRoot,
            "Search did not find a match")
        XCTAssertEqual(try sut.inspect().find(text: "button_3").pathToRoot,
            "view(PopoverFindTestView.self).hStack().emptyView(0).popover(1).button(1).labelView().text()")
    }
    
    func testArrowEdge() throws {
        guard #available(iOS 14.2, macOS 11.0, *) else { return }
        let binding = Binding(wrappedValue: true)
        let sut = EmptyView()
            .popover2(isPresented: binding, arrowEdge: .trailing) { Text("") }
        let value = try sut.inspect().emptyView().popover().arrowEdge()
        XCTAssertEqual(value, .trailing)
    }
    
    func testAttachmentAnchor() throws {
        guard #available(iOS 14.2, macOS 11.0, *) else { return }
        let binding = Binding(wrappedValue: true)
        let anchor = PopoverAttachmentAnchor.point(.bottom)
        let sut = EmptyView()
            .popover2(isPresented: binding,
                      attachmentAnchor: anchor) { Text("") }
        let value = try sut.inspect().emptyView().popover().attachmentAnchor()
        XCTAssertEqual(value, anchor)
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

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
final class PopoverDeprecatedTests: XCTestCase {
    
    @available(*, deprecated)
    func testContentView() throws {
        let binding = Binding(wrappedValue: true)
        let sut = EmptyView().popover2(isPresented: binding) { Text("") }
        let popover = try sut.inspect().emptyView().popover()
        XCTAssertNoThrow(try popover.contentView().text())
        XCTAssertNoThrow(try popover.contentView(Text.self).text())
    }
    
    @available(*, deprecated)
    func testIsPresentedAndDismiss() throws {
        let binding = Binding(wrappedValue: true)
        let sut = EmptyView().popover2(isPresented: binding) { Text("") }
        XCTAssertTrue(try sut.inspect().emptyView().popover().isPresented())
        try sut.inspect().emptyView().popover().dismiss()
        XCTAssertThrows(try sut.inspect().emptyView().popover(),
                        "View for Popover is absent")
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
private extension View {
    func popover2<Popover>(isPresented: Binding<Bool>,
                           attachmentAnchor: PopoverAttachmentAnchor = .rect(.bounds),
                           arrowEdge: Edge = .top,
                           @ViewBuilder content: @escaping () -> Popover
    ) -> some View where Popover: View {
        return self.modifier(InspectablePopover(
            isPresented: isPresented,
            attachmentAnchor: attachmentAnchor,
            arrowEdge: arrowEdge,
            popupBuilder: content))
    }
    
    func popover2<Item, Popover>(item: Binding<Item?>,
                                 attachmentAnchor: PopoverAttachmentAnchor = .rect(.bounds),
                                 arrowEdge: Edge = .top,
                                 content: @escaping (Item) -> Popover
    ) -> some View where Item: Identifiable, Popover: View {
        return self.modifier(InspectablePopoverWithItem(
            item: item,
            attachmentAnchor: attachmentAnchor,
            arrowEdge: arrowEdge,
            popupBuilder: content))
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
private struct InspectablePopover<Popover>: ViewModifier, PopupPresenter where Popover: View {
    
    let isPresented: Binding<Bool>
    let attachmentAnchor: PopoverAttachmentAnchor
    let arrowEdge: Edge
    let popupBuilder: () -> Popover
    let onDismiss: (() -> Void)? = nil
    
    func body(content: Self.Content) -> some View {
        content.popover(isPresented: isPresented, attachmentAnchor: attachmentAnchor,
                        arrowEdge: arrowEdge, content: popupBuilder)
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
private struct InspectablePopoverWithItem<Item, Popover>: ViewModifier, ItemPopupPresenter
where Item: Identifiable, Popover: View {
    
    let item: Binding<Item?>
    let attachmentAnchor: PopoverAttachmentAnchor
    let arrowEdge: Edge
    let popupBuilder: (Item) -> Popover
    let onDismiss: (() -> Void)? = nil
    
    func body(content: Self.Content) -> some View {
        content.popover(item: item, attachmentAnchor: attachmentAnchor,
                        arrowEdge: arrowEdge, content: popupBuilder)
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
private struct PopoverFindTestView: View, Inspectable {
    
    @Binding var isPopover1Presented = false
    @Binding var isPopover2Presented = false
    @Binding var isPopover3Presented = false
    
    init(popover1: Binding<Bool>, popover2: Binding<Bool>, popover3: Binding<Bool>) {
        _isPopover1Presented = popover1
        _isPopover2Presented = popover2
        _isPopover3Presented = popover3
    }
    
    var body: some View {
        HStack {
            EmptyView()
                .popover2(isPresented: $isPopover1Presented) {
                    Text("title_1")
                    Button("button_1", action: { })
                }
                .popover(isPresented: $isPopover2Presented) {
                    Text("title_2")
                }
                .popover2(isPresented: $isPopover3Presented) {
                    Text("title_3")
                    Button("button_3", action: { })
                }
        }
    }
}

#endif
