import XCTest
import SwiftUI
@testable import ViewInspector

#if !os(macOS)
@MainActor
final class FullScreenCoverTests: XCTestCase {

    func testFullScreenCover() throws {
        guard #available(iOS 14.0, tvOS 14.0, watchOS 7.0, *)
        else { throw XCTSkip() }
        let binding = Binding(wrappedValue: true)
        let sut = EmptyView().fullScreenCover(isPresented: binding) { Text("") }
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }

    func testInspectionErrorNoModifier() throws {
        guard #available(iOS 14.0, tvOS 14.0, watchOS 7.0, *)
        else { throw XCTSkip() }
        let sut = EmptyView().offset()
        XCTAssertThrows(try sut.inspect().emptyView().fullScreenCover(),
                        "EmptyView does not have 'fullScreenCover' modifier")
    }

    func testNativeFullScreenCoverNotPresented() throws {
        guard #available(iOS 14.0, tvOS 14.0, watchOS 7.0, *)
        else { throw XCTSkip() }
        let binding = Binding(wrappedValue: false)
        let sut = EmptyView().fullScreenCover(isPresented: binding) { Text("abc") }
        XCTAssertThrows(try sut.inspect().emptyView().fullScreenCover(),
                        "View for FullScreenCover is absent")
    }

    func testNativeFullScreenCoverContentInspection() throws {
        guard #available(iOS 14.0, tvOS 14.0, watchOS 7.0, *)
        else { throw XCTSkip() }
        let binding = Binding(wrappedValue: true)
        let sut = EmptyView().fullScreenCover(isPresented: binding) { Text("abc") }
        let title = try sut.inspect().emptyView().fullScreenCover().text()
        XCTAssertEqual(try title.string(), "abc")
        XCTAssertEqual(title.pathToRoot, "emptyView().fullScreenCover().text()")
    }

    func testNativeFullScreenCoverContentInteraction() throws {
        guard #available(iOS 14.0, tvOS 14.0, watchOS 7.0, *)
        else { throw XCTSkip() }
        let binding = Binding(wrappedValue: true)
        let sut = EmptyView().fullScreenCover(isPresented: binding) {
            Text("abc")
            Button("xyz", action: { binding.wrappedValue = false })
        }
        let button = try sut.inspect().emptyView().fullScreenCover().button(1)
        try button.tap()
        XCTAssertFalse(binding.wrappedValue)
        XCTAssertEqual(button.pathToRoot, "emptyView().fullScreenCover().button(1)")
    }

    func testNativeFullScreenCoverDismiss() throws {
        guard #available(iOS 14.0, tvOS 14.0, watchOS 7.0, *)
        else { throw XCTSkip() }
        let exp = XCTestExpectation(description: #function)
        let binding = Binding(wrappedValue: true)
        let sut = EmptyView().fullScreenCover(isPresented: binding, onDismiss: {
            exp.fulfill()
        }, content: { Text("") })
        try sut.inspect().emptyView().fullScreenCover().dismiss()
        XCTAssertFalse(binding.wrappedValue)
        XCTAssertThrows(try sut.inspect().emptyView().fullScreenCover(),
                        "View for FullScreenCover is absent")
        wait(for: [exp], timeout: 0.1)
    }

    func testNativeFullScreenCoverWithItemDismiss() throws {
        guard #available(iOS 14.0, tvOS 14.0, watchOS 7.0, *)
        else { throw XCTSkip() }
        let binding = Binding<Int?>(wrappedValue: 6)
        let sut = EmptyView().fullScreenCover(item: binding) { Text("\($0)") }
        let cover = try sut.inspect().emptyView().fullScreenCover()
        XCTAssertEqual(try cover.text().string(), "6")
        try cover.dismiss()
        XCTAssertNil(binding.wrappedValue)
        XCTAssertThrows(try sut.inspect().emptyView().fullScreenCover(),
                        "View for FullScreenCover is absent")
    }

    func testInspectionErrorFullScreenCoverNotPresented() throws {
        guard #available(iOS 14.0, tvOS 14.0, watchOS 7.0, *)
        else { throw XCTSkip() }
        let binding = Binding(wrappedValue: false)
        let sut = EmptyView().fullScreenCover2(isPresented: binding) { Text("") }
        XCTAssertThrows(try sut.inspect().implicitAnyView().emptyView().fullScreenCover(),
                        "View for FullScreenCover is absent")
    }

    func testInspectionErrorFullScreenCoverWithItemNotPresented() throws {
        guard #available(iOS 14.0, tvOS 14.0, watchOS 7.0, *)
        else { throw XCTSkip() }
        let binding = Binding<Int?>(wrappedValue: nil)
        let sut = EmptyView().fullScreenCover2(item: binding) { Text("\($0)") }
        XCTAssertThrows(try sut.inspect().implicitAnyView().emptyView().fullScreenCover(),
                        "View for FullScreenCover is absent")
    }

    func testContentInspection() throws {
        guard #available(iOS 14.0, tvOS 14.0, watchOS 7.0, *)
        else { throw XCTSkip() }
        let binding = Binding(wrappedValue: true)
        let sut = EmptyView().fullScreenCover2(isPresented: binding) {
            Text("abc")
        }
        let title = try sut.inspect().implicitAnyView().emptyView().fullScreenCover().text()
        XCTAssertEqual(try title.string(), "abc")
        #if compiler(<6) || compiler(>=6.1)
        XCTAssertEqual(title.pathToRoot, "emptyView().fullScreenCover().text()")
        #else
        XCTAssertEqual(title.pathToRoot, "anyView().emptyView().fullScreenCover().text()")
        #endif
    }

    func testContentInteraction() throws {
        guard #available(iOS 14.0, tvOS 14.0, watchOS 7.0, *)
        else { throw XCTSkip() }
        let binding = Binding(wrappedValue: true)
        let sut = EmptyView().fullScreenCover2(isPresented: binding) {
            Text("abc")
            Button("xyz", action: { binding.wrappedValue = false })
        }
        let button = try sut.inspect().implicitAnyView().emptyView().fullScreenCover().button(1)
        try button.tap()
        XCTAssertFalse(binding.wrappedValue)
        #if compiler(<6) || compiler(>=6.1)
        XCTAssertEqual(button.pathToRoot, "emptyView().fullScreenCover().button(1)")
        #else
        XCTAssertEqual(button.pathToRoot, "anyView().emptyView().fullScreenCover().button(1)")
        #endif
    }

    func testDismiss() throws {
        guard #available(iOS 14.0, tvOS 14.0, watchOS 7.0, *)
        else { throw XCTSkip() }
        let exp = XCTestExpectation(description: #function)
        let binding = Binding(wrappedValue: true)
        let sut = EmptyView().fullScreenCover2(isPresented: binding, onDismiss: {
            exp.fulfill()
        }, content: { Text("") })
        XCTAssertTrue(binding.wrappedValue)
        #if compiler(<6) || compiler(>=6.1)
        try sut.inspect().fullScreenCover().dismiss()
        XCTAssertFalse(binding.wrappedValue)
        XCTAssertThrows(try sut.inspect().fullScreenCover(), "View for FullScreenCover is absent")
        #else
        try sut.inspect().implicitAnyView().emptyView().fullScreenCover().dismiss()
        XCTAssertFalse(binding.wrappedValue)
        XCTAssertThrows(try sut.inspect().implicitAnyView().emptyView().fullScreenCover(), "View for FullScreenCover is absent")
        #endif
        wait(for: [exp], timeout: 0.1)
    }

    func testDismissForItemVersion() throws {
        guard #available(iOS 14.0, tvOS 14.0, watchOS 7.0, *)
        else { throw XCTSkip() }
        let binding = Binding<Int?>(wrappedValue: 6)
        let sut = EmptyView().fullScreenCover2(item: binding) { Text("\($0)") }
        let fullScreenCover = try sut.inspect().implicitAnyView().emptyView().fullScreenCover()
        XCTAssertEqual(try fullScreenCover.text().string(), "6")
        XCTAssertEqual(binding.wrappedValue, 6)
        try fullScreenCover.dismiss()
        XCTAssertNil(binding.wrappedValue)
        XCTAssertThrows(try sut.inspect().implicitAnyView().emptyView().fullScreenCover(), "View for FullScreenCover is absent")
    }

    func testMultipleFullScreenCoversInspection() throws {
        guard #available(iOS 14.0, tvOS 14.0, watchOS 7.0, *)
        else { throw XCTSkip() }
        let binding1 = Binding(wrappedValue: true)
        let binding2 = Binding(wrappedValue: true)
        let binding3 = Binding(wrappedValue: true)
        let sut = FullScreenCoverFindTestView(
            fullScreenCover1: binding1, fullScreenCover2: binding2, fullScreenCover3: binding3)
        #if compiler(<6) || compiler(>=6.1)
        let title1 = try sut.inspect().hStack().emptyView(0).fullScreenCover().text(0)
        XCTAssertEqual(try title1.string(), "title_1")
        XCTAssertEqual(title1.pathToRoot,
            "view(FullScreenCoverFindTestView.self).hStack().emptyView(0).fullScreenCover().text(0)")
        #else
        let title1 = try sut.inspect().implicitAnyView().hStack().anyView(0).anyView().emptyView().fullScreenCover().text(0)
        XCTAssertEqual(try title1.string(), "title_1")
        XCTAssertEqual(title1.pathToRoot,
            """
            view(FullScreenCoverFindTestView.self).anyView().hStack().anyView(0)\
            .anyView().emptyView().fullScreenCover().text(0)
            """)
        #endif
        #if compiler(<6) || compiler(>=6.1)
        let title2 = try sut.inspect().implicitAnyView().hStack().emptyView(0).fullScreenCover(1).text(0)
        XCTAssertEqual(try title2.string(), "title_2")
        XCTAssertEqual(title2.pathToRoot,
            "view(FullScreenCoverFindTestView.self).hStack().emptyView(0).fullScreenCover(1).text(0)")
        let title3 = try sut.inspect().implicitAnyView().hStack().emptyView(0).fullScreenCover(2).text(0)
        XCTAssertEqual(try title3.string(), "title_3")
        XCTAssertEqual(title3.pathToRoot,
            "view(FullScreenCoverFindTestView.self).hStack().emptyView(0).fullScreenCover(2).text(0)")
        XCTAssertEqual(try sut.inspect().find(ViewType.FullScreenCover.self).text(0).string(), "title_1")
        #else
        let title2 = try sut.inspect().implicitAnyView().hStack().anyView(0).anyView().fullScreenCover(1).text(0)
        XCTAssertEqual(try title2.string(), "title_2")
        XCTAssertEqual(title2.pathToRoot,
            "view(FullScreenCoverFindTestView.self).anyView().hStack().anyView(0).anyView().fullScreenCover(1).text(0)")
        let title3 = try sut.inspect().implicitAnyView().hStack().anyView(0).anyView().fullScreenCover(2).text(0)
        XCTAssertEqual(try title3.string(), "title_3")
        XCTAssertEqual(title3.pathToRoot,
            "view(FullScreenCoverFindTestView.self).anyView().hStack().anyView(0).anyView().fullScreenCover(2).text(0)")
        XCTAssertEqual(try sut.inspect().find(ViewType.FullScreenCover.self, skipFound: 1).text(0).string(), "title_1")
        #endif
        binding1.wrappedValue = false
        XCTAssertEqual(try sut.inspect().find(ViewType.FullScreenCover.self).text(0).string(), "title_2")
        binding2.wrappedValue = false
        XCTAssertEqual(try sut.inspect().find(ViewType.FullScreenCover.self).text(0).string(), "title_3")
        binding3.wrappedValue = false
        XCTAssertThrows(try sut.inspect().find(ViewType.FullScreenCover.self),
                        "Search did not find a match")
    }

    func testFindAndPathToRoots() throws {
        guard #available(iOS 14.0, tvOS 14.0, watchOS 7.0, *)
        else { throw XCTSkip() }
        let binding = Binding(wrappedValue: true)
        let sut = FullScreenCoverFindTestView(
            fullScreenCover1: binding, fullScreenCover2: binding, fullScreenCover3: binding)

        // 1
        #if compiler(<6) || compiler(>=6.1)
        XCTAssertEqual(try sut.inspect().find(text: "title_1").pathToRoot,
            "view(FullScreenCoverFindTestView.self).hStack().emptyView(0).sheet().text(0)")
        XCTAssertEqual(try sut.inspect().find(text: "button_1").pathToRoot,
            """
            view(FullScreenCoverFindTestView.self).hStack().emptyView(0)\
            .sheet().button(1).labelView().text()
            """)
        #else
        XCTAssertEqual(try sut.inspect().find(text: "title_1").pathToRoot,
            """
            view(FullScreenCoverFindTestView.self).anyView().hStack().anyView(0)\
            .anyView().emptyView().sheet().text(0)
            """)
        XCTAssertEqual(try sut.inspect().find(text: "button_1").pathToRoot,
            """
            view(FullScreenCoverFindTestView.self).anyView().hStack().anyView(0)\
            .anyView().emptyView().sheet().button(1).labelView().text()
            """)
        #endif
        // 2
        #if compiler(<6) || compiler(>=6.1)
        XCTAssertEqual(try sut.inspect().find(text: "title_2").pathToRoot,
            "view(FullScreenCoverFindTestView.self).hStack().emptyView(0).sheet(1).text()")
        #else
        XCTAssertEqual(try sut.inspect().find(text: "title_2").pathToRoot,
            """
            view(FullScreenCoverFindTestView.self).anyView().hStack().anyView(0)\
            .anyView().sheet(1).text()
            """)
        #endif
    }

    func testFindAndPathToRootsForThirdCover() throws {
        guard #available(iOS 14.0, tvOS 14.0, watchOS 7.0, *)
        else { throw XCTSkip() }
        let binding = Binding(wrappedValue: true)
        let sut = FullScreenCoverFindTestView(
            fullScreenCover1: binding, fullScreenCover2: binding, fullScreenCover3: binding)

        XCTAssertThrows(try sut.inspect().find(text: "message_3").pathToRoot,
            "Search did not find a match")
        #if compiler(<6) || compiler(>=6.1)
        XCTAssertEqual(try sut.inspect().find(text: "title_3").pathToRoot,
            "view(FullScreenCoverFindTestView.self).hStack().emptyView(0).sheet(2).text(0)")
        XCTAssertEqual(try sut.inspect().find(text: "button_3").pathToRoot,
            """
            view(FullScreenCoverFindTestView.self).hStack().emptyView(0)\
            .sheet(2).button(1).labelView().text()
            """)
        #else
        XCTAssertEqual(try sut.inspect().find(text: "title_3").pathToRoot,
            "view(FullScreenCoverFindTestView.self).anyView().hStack().anyView(0).anyView().sheet(2).text(0)")
        XCTAssertEqual(try sut.inspect().find(text: "button_3").pathToRoot,
            """
            view(FullScreenCoverFindTestView.self).anyView().hStack().anyView(0)\
            .anyView().sheet(2).button(1).labelView().text()
            """)
        #endif
    }
}

@available(iOS 14.0, tvOS 14.0, watchOS 7.0, *)
@available(macOS, unavailable)
private extension View {
    @MainActor
    func fullScreenCover2<FullScreenCover>(isPresented: Binding<Bool>,
                                           onDismiss: (() -> Void)? = nil,
                                           @ViewBuilder content: @escaping () -> FullScreenCover
    ) -> some View where FullScreenCover: View {
        return self.modifier(InspectableFullScreenCover(
            isPresented: isPresented, onDismiss: onDismiss, popupBuilder: content))
    }

    func fullScreenCover2<Item, FullScreenCover>(item: Binding<Item?>,
                                                 onDismiss: (() -> Void)? = nil,
                                                 content: @escaping (Item) -> FullScreenCover
    ) -> some View where Item: Identifiable, FullScreenCover: View {
        return self.modifier(InspectableFullScreenCoverWithItem(
            item: item, onDismiss: onDismiss, popupBuilder: content))
    }
}

@available(iOS 14.0, tvOS 14.0, watchOS 7.0, *)
@available(macOS, unavailable)
private struct InspectableFullScreenCover<FullScreenCover>: ViewModifier, PopupPresenter
where FullScreenCover: View {

    let isPresented: Binding<Bool>
    let onDismiss: (() -> Void)?
    let popupBuilder: () -> FullScreenCover

    func body(content: Self.Content) -> some View {
        content.fullScreenCover(isPresented: isPresented, onDismiss: onDismiss, content: popupBuilder)
    }
}

@available(iOS 14.0, tvOS 14.0, watchOS 7.0, *)
@available(macOS, unavailable)
private struct InspectableFullScreenCoverWithItem<Item, FullScreenCover>: ViewModifier, ItemPopupPresenter
where Item: Identifiable, FullScreenCover: View {

    let item: Binding<Item?>
    let onDismiss: (() -> Void)?
    let popupBuilder: (Item) -> FullScreenCover

    func body(content: Self.Content) -> some View {
        content.fullScreenCover(item: item, onDismiss: onDismiss, content: popupBuilder)
    }
}

@available(iOS 14.0, tvOS 14.0, watchOS 7.0, *)
@available(macOS, unavailable)
private struct FullScreenCoverFindTestView: View {

    @Binding var isFullScreenCover1Presented = false
    @Binding var isFullScreenCover2Presented = false
    @Binding var isFullScreenCover3Presented = false

    init(fullScreenCover1: Binding<Bool>, fullScreenCover2: Binding<Bool>, fullScreenCover3: Binding<Bool>) {
        _isFullScreenCover1Presented = fullScreenCover1
        _isFullScreenCover2Presented = fullScreenCover2
        _isFullScreenCover3Presented = fullScreenCover3
    }

    var body: some View {
        HStack {
            EmptyView()
                .fullScreenCover2(isPresented: $isFullScreenCover1Presented) {
                    Text("title_1")
                    Button("button_1", action: { })
                }
                .fullScreenCover(isPresented: $isFullScreenCover2Presented) {
                    Text("title_2")
                }
                .fullScreenCover2(isPresented: $isFullScreenCover3Presented) {
                    Text("title_3")
                    Button("button_3", action: { })
                }
        }
    }
}
#endif
