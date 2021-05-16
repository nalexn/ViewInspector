import XCTest
import SwiftUI
@testable import ViewInspector

#if !os(macOS)
@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
final class ActionSheetTests: XCTestCase {
    
    func testInspectionNotBlocked() throws {
        let binding = Binding(wrappedValue: true)
        let sut = EmptyView().actionSheet(isPresented: binding) { ActionSheet(title: Text("abc")) }
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testInspectionErrorNoModifier() throws {
        let sut = EmptyView().offset()
        XCTAssertThrows(try sut.inspect().emptyView().actionSheet(),
                        "EmptyView does not have 'actionSheet' modifier")
    }
    
    func testInspectionErrorCustomModifierRequired() throws {
        let binding = Binding(wrappedValue: true)
        let sut = EmptyView().actionSheet(isPresented: binding) { ActionSheet(title: Text("abc")) }
        XCTAssertThrows(try sut.inspect().emptyView().actionSheet(),
            """
            Please refer to the Guide for inspecting the ActionSheet: \
            https://github.com/nalexn/ViewInspector/blob/master/guide.md#actionsheet
            """)
    }
    
    func testInspectionErrorSheetNotPresented() throws {
        let binding = Binding(wrappedValue: false)
        let sut = EmptyView().actionSheet2(isPresented: binding) { ActionSheet(title: Text("abc")) }
        XCTAssertThrows(try sut.inspect().emptyView().actionSheet(),
                        "View for ActionSheet is absent")
    }
    
    func testInspectionErrorSheetWithItemNotPresented() throws {
        let binding = Binding<Int?>(wrappedValue: nil)
        let sut = EmptyView().actionSheet2(item: binding) { value in
            ActionSheet(title: Text("\(value)"))
        }
        XCTAssertThrows(try sut.inspect().emptyView().actionSheet(),
                        "View for ActionSheet is absent")
    }
    
    func testTitleInspection() throws {
        let binding = Binding(wrappedValue: true)
        let sut = EmptyView().actionSheet2(isPresented: binding) {
            ActionSheet(title: Text("abc"))
        }
        let title = try sut.inspect().emptyView().actionSheet().title()
        XCTAssertEqual(try title.string(), "abc")
        XCTAssertEqual(title.pathToRoot, "emptyView().actionSheet().title()")
    }
    
    func testMessageInspection() throws {
        let binding = Binding(wrappedValue: true)
        let sut = EmptyView().actionSheet2(isPresented: binding) {
            ActionSheet(title: Text("abc"), message: Text("123"))
        }
        let message = try sut.inspect().emptyView().actionSheet().message()
        XCTAssertEqual(try message.string(), "123")
        XCTAssertEqual(message.pathToRoot, "emptyView().actionSheet().message()")
    }
    
    func testNoMessageError() throws {
        let binding = Binding(wrappedValue: true)
        let sut = EmptyView().actionSheet2(isPresented: binding) {
            ActionSheet(title: Text("abc"))
        }
        XCTAssertThrows(try sut.inspect().emptyView().actionSheet().message(),
                        "View for message is absent")
    }
    
    func testButtonsInspection() throws {
        let binding = Binding(wrappedValue: true)
        let sut = EmptyView().actionSheet2(isPresented: binding) {
            ActionSheet(title: Text("abc"), message: Text("123"),
                        buttons: [.default(Text("b1")),
                                  .destructive(Text("b2")),
                                  .cancel(Text("b3"))])
        }
        let btn1 = try sut.inspect().emptyView().actionSheet().button(0)
        let btn2 = try sut.inspect().emptyView().actionSheet().button(1)
        let btn3 = try sut.inspect().emptyView().actionSheet().button(2)
        XCTAssertEqual(try btn1.labelView().string(), "b1")
        XCTAssertEqual(try btn2.labelView().string(), "b2")
        XCTAssertEqual(try btn3.labelView().string(), "b3")
        XCTAssertEqual(try btn1.labelView().pathToRoot, "emptyView().actionSheet().button(0).labelView()")
        XCTAssertEqual(try btn2.labelView().pathToRoot, "emptyView().actionSheet().button(1).labelView()")
        XCTAssertEqual(try btn3.labelView().pathToRoot, "emptyView().actionSheet().button(2).labelView()")
        XCTAssertEqual(try btn1.style(), .default)
        XCTAssertEqual(try btn2.style(), .destructive)
        XCTAssertEqual(try btn3.style(), .cancel)
        XCTAssertThrows(try sut.inspect().emptyView().actionSheet().button(3),
            "View for button at index 3 is absent")
    }
    
    func testTapOnButtonWithoutCallback() throws {
        let binding = Binding(wrappedValue: true)
        let sut = EmptyView().actionSheet2(isPresented: binding) {
            ActionSheet(title: Text("abc"), message: Text("123"),
                        buttons: [.default(Text("xyz"))])
        }
        XCTAssertTrue(binding.wrappedValue)
        try sut.inspect().emptyView().actionSheet().button(0).tap()
        XCTAssertFalse(binding.wrappedValue)
    }
    
    func testTapOnButtonWithCallback() throws {
        let exp = XCTestExpectation(description: #function)
        let binding = Binding(wrappedValue: true)
        let sut = EmptyView().actionSheet2(isPresented: binding) {
            ActionSheet(title: Text("abc"), message: Text("123"),
                  buttons: [.destructive(Text("xyz"), action: {
                    exp.fulfill()
                  })])
        }
        XCTAssertTrue(binding.wrappedValue)
        try sut.inspect().emptyView().actionSheet().button(0).tap()
        XCTAssertFalse(binding.wrappedValue)
        wait(for: [exp], timeout: 0.1)
    }
    
    func testActionSheetWithItem() throws {
        let binding = Binding<Int?>(wrappedValue: 6)
        let sut = EmptyView().actionSheet2(item: binding) { value in
            ActionSheet(title: Text("\(value)"))
        }
        XCTAssertEqual(try sut.inspect().emptyView().actionSheet().title().string(), "6")
        XCTAssertEqual(binding.wrappedValue, 6)
        try sut.inspect().emptyView().actionSheet().button(0).tap()
        XCTAssertNil(binding.wrappedValue)
    }
    
    func testMultipleSheetsInspection() throws {
        let binding1 = Binding(wrappedValue: true)
        let binding2 = Binding(wrappedValue: true)
        let binding3 = Binding(wrappedValue: true)
        let sut = ActionSheetFindTestView(sheet1: binding1, sheet2: binding2, sheet3: binding3)
        let title1 = try sut.inspect().hStack().emptyView(0).actionSheet().title()
        XCTAssertEqual(try title1.string(), "title_1")
        XCTAssertEqual(title1.pathToRoot,
            "view(ActionSheetFindTestView.self).hStack().emptyView(0).actionSheet().title()")
        let title2 = try sut.inspect().hStack().emptyView(0).actionSheet(1).title()
        XCTAssertEqual(try title2.string(), "title_3")
        XCTAssertEqual(title2.pathToRoot,
            "view(ActionSheetFindTestView.self).hStack().emptyView(0).actionSheet(1).title()")
        
        XCTAssertEqual(try sut.inspect().find(ViewType.ActionSheet.self)
                        .title().string(), "title_1")
        binding1.wrappedValue = false
        XCTAssertEqual(try sut.inspect().find(ViewType.ActionSheet.self)
                        .title().string(), "title_3")
        binding3.wrappedValue = false
        XCTAssertThrows(try sut.inspect().find(ViewType.ActionSheet.self),
                        "Search did not find a match")
    }
    
    func testFindAndPathToRoots() throws {
        let binding = Binding(wrappedValue: true)
        let sut = ActionSheetFindTestView(sheet1: binding, sheet2: binding, sheet3: binding)
        
        // 1
        XCTAssertEqual(try sut.inspect().find(text: "title_1").pathToRoot,
            "view(ActionSheetFindTestView.self).hStack().emptyView(0).actionSheet().title()")
        XCTAssertEqual(try sut.inspect().find(text: "message_1").pathToRoot,
            "view(ActionSheetFindTestView.self).hStack().emptyView(0).actionSheet().message()")
        XCTAssertEqual(try sut.inspect().find(text: "button_1_0").pathToRoot,
            "view(ActionSheetFindTestView.self).hStack().emptyView(0).actionSheet().button(0).labelView()")
        XCTAssertEqual(try sut.inspect().find(text: "button_1_1").pathToRoot,
            "view(ActionSheetFindTestView.self).hStack().emptyView(0).actionSheet().button(1).labelView()")
        // 2
        XCTAssertThrows(try sut.inspect().find(text: "title_2").pathToRoot,
            "Search did not find a match")
        
        // 3
        XCTAssertEqual(try sut.inspect().find(text: "title_3").pathToRoot,
            "view(ActionSheetFindTestView.self).hStack().emptyView(0).actionSheet(1).title()")
        
        XCTAssertThrows(try sut.inspect().find(text: "message_3").pathToRoot,
            "Search did not find a match")
        XCTAssertEqual(try sut.inspect().find(text: "button_3_0").pathToRoot,
            "view(ActionSheetFindTestView.self).hStack().emptyView(0).actionSheet(1).button(0).labelView()")
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
private extension View {
    func actionSheet2(isPresented: Binding<Bool>,
                      content: @escaping () -> ActionSheet) -> some View {
        return self.modifier(InspectableActionSheet(isPresented: isPresented, sheetBuilder: content))
    }
    
    func actionSheet2<Item>(item: Binding<Item?>,
                            content: @escaping (Item) -> ActionSheet
    ) -> some View where Item: Identifiable {
        return self.modifier(InspectableActionSheetWithItem(item: item, sheetBuilder: content))
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
private struct InspectableActionSheet: ViewModifier, ActionSheetProvider {
    
    let isPresented: Binding<Bool>
    let sheetBuilder: () -> ActionSheet
    
    func body(content: Self.Content) -> some View {
        content.actionSheet(isPresented: isPresented, content: sheetBuilder)
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
private struct InspectableActionSheetWithItem<Item: Identifiable>: ViewModifier, ActionSheetItemProvider {
    
    let item: Binding<Item?>
    let sheetBuilder: (Item) -> ActionSheet
    
    func body(content: Self.Content) -> some View {
        content.actionSheet(item: item, content: sheetBuilder)
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
private struct ActionSheetFindTestView: View, Inspectable {
    
    @Binding var isSheet1Presented = false
    @Binding var isSheet2Presented = false
    @Binding var isSheet3Presented = false
    
    init(sheet1: Binding<Bool>, sheet2: Binding<Bool>, sheet3: Binding<Bool>) {
        _isSheet1Presented = sheet1
        _isSheet2Presented = sheet2
        _isSheet3Presented = sheet3
    }
    
    var body: some View {
        HStack {
            EmptyView()
                .actionSheet2(isPresented: $isSheet1Presented) {
                    ActionSheet(title: Text("title_1"), message: Text("message_1"),
                                buttons: [.default(Text("button_1_0"), action: nil),
                                          .destructive(Text("button_1_1"))])
                }
                .actionSheet(isPresented: $isSheet2Presented) {
                    ActionSheet(title: Text("title_2"))
                }
                .actionSheet2(isPresented: $isSheet3Presented) {
                    ActionSheet(title: Text("title_3"), message: nil,
                                buttons: [.cancel(Text("button_3_0"), action: nil)])
                }
        }
    }
}
#endif
