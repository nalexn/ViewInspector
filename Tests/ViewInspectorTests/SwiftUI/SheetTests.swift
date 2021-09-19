import XCTest
import SwiftUI
@testable import ViewInspector

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
final class SheetTests: XCTestCase {
    
    func testSheet() throws {
        let binding = Binding(wrappedValue: true)
        let sut = EmptyView().sheet(isPresented: binding) { Text("") }
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testInspectionErrorNoModifier() throws {
        let sut = EmptyView().offset()
        XCTAssertThrows(try sut.inspect().emptyView().sheet(),
                        "EmptyView does not have 'sheet' modifier")
    }
    
    func testInspectionErrorCustomModifierRequired() throws {
        let binding = Binding(wrappedValue: true)
        let sut = EmptyView().sheet(isPresented: binding) { Text("") }
        XCTAssertThrows(try sut.inspect().emptyView().sheet(),
            """
            Please refer to the Guide for inspecting the Sheet: \
            https://github.com/nalexn/ViewInspector/blob/master/guide_popups.md#sheet
            """)
    }
    
    func testInspectionErrorSheetNotPresented() throws {
        let binding = Binding(wrappedValue: false)
        let sut = EmptyView().sheet2(isPresented: binding) { Text("") }
        XCTAssertThrows(try sut.inspect().emptyView().sheet(),
                        "View for Sheet is absent")
    }
    
    func testInspectionErrorSheetWithItemNotPresented() throws {
        let binding = Binding<Int?>(wrappedValue: nil)
        let sut = EmptyView().sheet2(item: binding) { Text("\($0)") }
        XCTAssertThrows(try sut.inspect().emptyView().sheet(),
                        "View for Sheet is absent")
    }
    
    func testContentInspection() throws {
        let binding = Binding(wrappedValue: true)
        let sut = EmptyView().sheet2(isPresented: binding) {
            Text("abc")
        }
        let title = try sut.inspect().emptyView().sheet().text()
        XCTAssertEqual(try title.string(), "abc")
        XCTAssertEqual(title.pathToRoot, "emptyView().sheet().text()")
    }
    
    func testContentInteraction() throws {
        let binding = Binding(wrappedValue: true)
        let sut = EmptyView().sheet2(isPresented: binding) {
            Text("abc")
            Button("xyz", action: { binding.wrappedValue = false })
        }
        let button = try sut.inspect().emptyView().sheet().button(1)
        try button.tap()
        XCTAssertFalse(binding.wrappedValue)
        XCTAssertEqual(button.pathToRoot, "emptyView().sheet().button(1)")
    }
    
    func testDismiss() throws {
        let exp = XCTestExpectation(description: #function)
        let binding = Binding(wrappedValue: true)
        let sut = EmptyView().sheet2(isPresented: binding, onDismiss: {
            exp.fulfill()
        }, content: { Text("") })
        XCTAssertTrue(binding.wrappedValue)
        try sut.inspect().sheet().dismiss()
        XCTAssertFalse(binding.wrappedValue)
        XCTAssertThrows(try sut.inspect().sheet(), "View for Sheet is absent")
        wait(for: [exp], timeout: 0.1)
    }
    
    func testDismissForItemVersion() throws {
        let binding = Binding<Int?>(wrappedValue: 6)
        let sut = EmptyView().sheet2(item: binding) { Text("\($0)") }
        let sheet = try sut.inspect().emptyView().sheet()
        XCTAssertEqual(try sheet.text().string(), "6")
        XCTAssertEqual(binding.wrappedValue, 6)
        try sheet.dismiss()
        XCTAssertNil(binding.wrappedValue)
        XCTAssertThrows(try sut.inspect().sheet(), "View for Sheet is absent")
    }
    
    func testMultipleSheetsInspection() throws {
        let binding1 = Binding(wrappedValue: true)
        let binding2 = Binding(wrappedValue: true)
        let binding3 = Binding(wrappedValue: true)
        let sut = SheetFindTestView(sheet1: binding1, sheet2: binding2, sheet3: binding3)
        let title1 = try sut.inspect().hStack().emptyView(0).sheet().text(0)
        XCTAssertEqual(try title1.string(), "title_1")
        XCTAssertEqual(title1.pathToRoot,
            "view(SheetFindTestView.self).hStack().emptyView(0).sheet().text(0)")
        let title2 = try sut.inspect().hStack().emptyView(0).sheet(1).text(0)
        XCTAssertEqual(try title2.string(), "title_3")
        XCTAssertEqual(title2.pathToRoot,
            "view(SheetFindTestView.self).hStack().emptyView(0).sheet(1).text(0)")
        
        XCTAssertEqual(try sut.inspect().find(ViewType.Sheet.self).text(0).string(), "title_1")
        binding1.wrappedValue = false
        XCTAssertEqual(try sut.inspect().find(ViewType.Sheet.self).text(0).string(), "title_3")
        binding3.wrappedValue = false
        XCTAssertThrows(try sut.inspect().find(ViewType.Sheet.self),
                        "Search did not find a match")
    }
    
    func testFindAndPathToRoots() throws {
        let binding = Binding(wrappedValue: true)
        let sut = SheetFindTestView(sheet1: binding, sheet2: binding, sheet3: binding)
        
        // 1
        XCTAssertEqual(try sut.inspect().find(text: "title_1").pathToRoot,
            "view(SheetFindTestView.self).hStack().emptyView(0).sheet().text(0)")
        XCTAssertEqual(try sut.inspect().find(text: "button_1").pathToRoot,
            "view(SheetFindTestView.self).hStack().emptyView(0).sheet().button(1).labelView().text()")
        // 2
        XCTAssertThrows(try sut.inspect().find(text: "title_2").pathToRoot,
            "Search did not find a match")
        
        // 3
        XCTAssertEqual(try sut.inspect().find(text: "title_3").pathToRoot,
            "view(SheetFindTestView.self).hStack().emptyView(0).sheet(1).text(0)")
        
        XCTAssertThrows(try sut.inspect().find(text: "message_3").pathToRoot,
            "Search did not find a match")
        XCTAssertEqual(try sut.inspect().find(text: "button_3").pathToRoot,
            "view(SheetFindTestView.self).hStack().emptyView(0).sheet(1).button(1).labelView().text()")
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
private extension View {
    func sheet2<Sheet>(isPresented: Binding<Bool>,
                       onDismiss: (() -> Void)? = nil,
                       @ViewBuilder content: @escaping () -> Sheet
    ) -> some View where Sheet: View {
        return self.modifier(InspectableSheet(isPresented: isPresented, onDismiss: onDismiss, popupBuilder: content))
    }
    
    func sheet2<Item, Sheet>(item: Binding<Item?>,
                             onDismiss: (() -> Void)? = nil,
                             content: @escaping (Item) -> Sheet
    ) -> some View where Item: Identifiable, Sheet: View {
        return self.modifier(InspectableSheetWithItem(item: item, onDismiss: onDismiss, popupBuilder: content))
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
private struct InspectableSheet<Sheet>: ViewModifier, PopupPresenter where Sheet: View {
    
    let isPresented: Binding<Bool>
    let onDismiss: (() -> Void)?
    let popupBuilder: () -> Sheet
    
    func body(content: Self.Content) -> some View {
        content.sheet(isPresented: isPresented, onDismiss: onDismiss, content: popupBuilder)
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
private struct InspectableSheetWithItem<Item, Sheet>: ViewModifier, ItemPopupPresenter
where Item: Identifiable, Sheet: View {
    
    let item: Binding<Item?>
    let onDismiss: (() -> Void)?
    let popupBuilder: (Item) -> Sheet
    
    func body(content: Self.Content) -> some View {
        content.sheet(item: item, onDismiss: onDismiss, content: popupBuilder)
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
private struct SheetFindTestView: View, Inspectable {
    
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
                .sheet2(isPresented: $isSheet1Presented) {
                    Text("title_1")
                    Button("button_1", action: { })
                }
                .sheet(isPresented: $isSheet2Presented) {
                    Text("title_2")
                }
                .sheet2(isPresented: $isSheet3Presented) {
                    Text("title_3")
                    Button("button_3", action: { })
                }
        }
    }
}
