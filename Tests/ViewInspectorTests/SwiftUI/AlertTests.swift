import XCTest
import SwiftUI
@testable import ViewInspector

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
final class AlertTests: XCTestCase {
    
    func testInspectionNotBlocked() throws {
        let binding = Binding(wrappedValue: true)
        let sut = EmptyView().alert(isPresented: binding) { Alert(title: Text("abc")) }
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testInspectionErrorNoModifier() throws {
        let sut = EmptyView().offset()
        XCTAssertThrows(try sut.inspect().emptyView().alert(),
                        "EmptyView does not have 'alert' modifier")
    }
    
    func testInspectionErrorCustomModifierRequired() throws {
        let binding = Binding(wrappedValue: true)
        let sut = EmptyView().alert(isPresented: binding) { Alert(title: Text("abc")) }
        XCTAssertThrows(try sut.inspect().emptyView().alert(),
            """
            Please refer to the Guide for inspecting the Alert: \
            https://github.com/nalexn/ViewInspector/blob/master/guide.md#alert-sheet-and-actionsheet
            """)
    }
    
    func testInspectionErrorAlertNotPresented() throws {
        let binding = Binding(wrappedValue: false)
        let sut = EmptyView().alert2(isPresented: binding) { Alert(title: Text("abc")) }
        XCTAssertThrows(try sut.inspect().emptyView().alert(),
                        "View for Alert is absent")
        XCTAssertThrows(try sut.inspect().find(text: "abc"), "Search did not find a match")
    }
    
    func testInspectionErrorAlertWithItemNotPresented() throws {
        let binding = Binding<Int?>(wrappedValue: nil)
        let sut = EmptyView().alert2(item: binding) { value in
            Alert(title: Text("\(value)"))
        }
        XCTAssertThrows(try sut.inspect().emptyView().alert(),
                        "View for Alert is absent")
    }
    
    func testTitleInspection() throws {
        let binding = Binding(wrappedValue: true)
        let sut = EmptyView().alert2(isPresented: binding) { Alert(title: Text("abc")) }
        let title = try sut.inspect().emptyView().alert().title()
        XCTAssertEqual(try title.string(), "abc")
        XCTAssertEqual(title.pathToRoot, "emptyView().alert().title()")
    }
    
    func testMessageInspection() throws {
        let binding = Binding(wrappedValue: true)
        let sut = EmptyView().alert2(isPresented: binding) {
            Alert(title: Text("abc"), message: Text("123"), dismissButton: nil)
        }
        let message = try sut.inspect().emptyView().alert().message()
        XCTAssertEqual(try message.string(), "123")
        XCTAssertEqual(message.pathToRoot, "emptyView().alert().message()")
    }
    
    func testNoMessageError() throws {
        let binding = Binding(wrappedValue: true)
        let sut = EmptyView().alert2(isPresented: binding) { Alert(title: Text("abc")) }
        XCTAssertThrows(try sut.inspect().emptyView().alert().message(),
                        "View for message is absent")
    }
    
    func testPrimaryButtonInspection() throws {
        let binding = Binding(wrappedValue: true)
        let sut = EmptyView().alert2(isPresented: binding) {
            Alert(title: Text("abc"), message: Text("123"),
                  dismissButton: .default(Text("xyz")))
        }
        let label = try sut.inspect().emptyView().alert().primaryButton().labelView()
        XCTAssertEqual(try label.string(), "xyz")
        XCTAssertEqual(label.pathToRoot, "emptyView().alert().primaryButton().labelView()")
    }
    
    func testSecondaryButtonInspection() throws {
        let binding = Binding(wrappedValue: true)
        let sut = EmptyView().alert2(isPresented: binding) {
            Alert(title: Text(""), primaryButton: .cancel(),
                  secondaryButton: .default(Text("xyz")))
        }
        let label = try sut.inspect().emptyView().alert().secondaryButton().labelView()
        XCTAssertEqual(try label.string(), "xyz")
        XCTAssertEqual(label.pathToRoot, "emptyView().alert().secondaryButton().labelView()")
    }
    
    func testNoSecondaryButtonError() throws {
        let binding = Binding(wrappedValue: true)
        let sut = EmptyView().alert2(isPresented: binding) { Alert(title: Text("abc")) }
        XCTAssertThrows(try sut.inspect().emptyView().alert().secondaryButton(),
                        "View for secondaryButton is absent")
    }
    
    func testTapOnPrimaryButtonWithoutCallback() throws {
        let binding = Binding(wrappedValue: true)
        let sut = EmptyView().alert2(isPresented: binding) {
            Alert(title: Text("abc"), message: Text("123"),
                  dismissButton: .default(Text("xyz")))
        }
        XCTAssertTrue(binding.wrappedValue)
        try sut.inspect().emptyView().alert().primaryButton().tap()
        XCTAssertFalse(binding.wrappedValue)
    }
    
    func testTapOnPrimaryButtonWithCallback() throws {
        let exp = XCTestExpectation(description: #function)
        let binding = Binding(wrappedValue: true)
        let sut = EmptyView().alert2(isPresented: binding) {
            Alert(title: Text("abc"), message: Text("123"),
                  dismissButton: .destructive(Text("xyz"), action: {
                    exp.fulfill()
                  }))
        }
        XCTAssertTrue(binding.wrappedValue)
        try sut.inspect().emptyView().alert().primaryButton().tap()
        XCTAssertFalse(binding.wrappedValue)
        wait(for: [exp], timeout: 0.1)
    }
    
    func testTapOnSecondaryButtonWithoutCallback() throws {
        let binding = Binding(wrappedValue: true)
        let sut = EmptyView().alert2(isPresented: binding) {
            Alert(title: Text("abc"), primaryButton: .default(Text("xyz")),
                  secondaryButton: .default(Text("123")))
        }
        XCTAssertTrue(binding.wrappedValue)
        try sut.inspect().emptyView().alert().secondaryButton().tap()
        XCTAssertFalse(binding.wrappedValue)
    }
    
    func testTapOnSecondaryButtonWithCallback() throws {
        let exp = XCTestExpectation(description: #function)
        let binding = Binding(wrappedValue: true)
        let sut = EmptyView().alert2(isPresented: binding) {
            Alert(title: Text("abc"), primaryButton: .default(Text("xyz")),
                  secondaryButton: .default(Text("123"), action: {
                    exp.fulfill()
                  }))
        }
        XCTAssertTrue(binding.wrappedValue)
        try sut.inspect().emptyView().alert().secondaryButton().tap()
        XCTAssertFalse(binding.wrappedValue)
        wait(for: [exp], timeout: 0.1)
    }
    
    func testAlertButtonStyle() throws {
        let binding = Binding(wrappedValue: true)
        let sut1 = EmptyView().alert2(isPresented: binding) {
            Alert(title: Text(""), primaryButton: .default(Text("")),
                  secondaryButton: .cancel(Text("")))
        }
        let sut2 = EmptyView().alert2(isPresented: binding) {
            Alert(title: Text(""), message: nil, dismissButton: .destructive(Text("")))
        }
        XCTAssertEqual(
            try sut1.inspect().emptyView().alert().primaryButton().style(), .default)
        XCTAssertEqual(
            try sut1.inspect().emptyView().alert().secondaryButton().style(), .cancel)
        XCTAssertEqual(
            try sut2.inspect().emptyView().alert().primaryButton().style(), .destructive)
    }
    
    func testAlertWithItem() throws {
        let binding = Binding<Int?>(wrappedValue: 6)
        let sut = EmptyView().alert2(item: binding) { value in
            Alert(title: Text("\(value)"))
        }
        XCTAssertEqual(try sut.inspect().emptyView().alert().title().string(), "6")
        XCTAssertEqual(binding.wrappedValue, 6)
        try sut.inspect().emptyView().alert().primaryButton().tap()
        XCTAssertNil(binding.wrappedValue)
    }
    
    func testMultipleAlertsInspection() throws {
        let binding1 = Binding(wrappedValue: true)
        let binding2 = Binding(wrappedValue: true)
        let binding3 = Binding(wrappedValue: true)
        let sut = AlertFindTestView(alert1: binding1, alert2: binding2, alert3: binding3)
        let title1 = try sut.inspect().hStack().emptyView(0).alert().title()
        XCTAssertEqual(try title1.string(), "title_1")
        XCTAssertEqual(title1.pathToRoot,
            "view(AlertFindTestView.self).hStack().emptyView(0).alert().title()")
        let title2 = try sut.inspect().hStack().emptyView(0).alert(1).title()
        XCTAssertEqual(try title2.string(), "title_3")
        XCTAssertEqual(title2.pathToRoot,
            "view(AlertFindTestView.self).hStack().emptyView(0).alert(1).title()")
        
        XCTAssertEqual(try sut.inspect().find(ViewType.Alert.self).title().string(), "title_1")
        binding1.wrappedValue = false
        XCTAssertEqual(try sut.inspect().find(ViewType.Alert.self).title().string(), "title_3")
        binding3.wrappedValue = false
        XCTAssertThrows(try sut.inspect().find(ViewType.Alert.self), "Search did not find a match")
    }
    
    func testFindAndPathToRoots() throws {
        let binding = Binding(wrappedValue: true)
        let sut = AlertFindTestView(alert1: binding, alert2: binding, alert3: binding)
        
        // 1
        XCTAssertEqual(try sut.inspect().find(text: "title_1").pathToRoot,
            "view(AlertFindTestView.self).hStack().emptyView(0).alert().title()")
        XCTAssertEqual(try sut.inspect().find(text: "message_1").pathToRoot,
            "view(AlertFindTestView.self).hStack().emptyView(0).alert().message()")
        XCTAssertEqual(try sut.inspect().find(text: "primary_1").pathToRoot,
            "view(AlertFindTestView.self).hStack().emptyView(0).alert().primaryButton().labelView()")
        XCTAssertEqual(try sut.inspect().find(text: "secondary_1").pathToRoot,
            "view(AlertFindTestView.self).hStack().emptyView(0).alert().secondaryButton().labelView()")
        // 2
        XCTAssertThrows(try sut.inspect().find(text: "title_2").pathToRoot,
            "Search did not find a match")
        
        // 3
        XCTAssertEqual(try sut.inspect().find(text: "title_3").pathToRoot,
            "view(AlertFindTestView.self).hStack().emptyView(0).alert(1).title()")
        XCTAssertThrows(try sut.inspect().find(text: "message_3").pathToRoot,
            "Search did not find a match")
        XCTAssertEqual(try sut.inspect().find(text: "primary_3").pathToRoot,
            "view(AlertFindTestView.self).hStack().emptyView(0).alert(1).primaryButton().labelView()")
    }
}

extension Int: Identifiable {
    public var id: Int { self }
}

extension String: Identifiable {
    public var id: String { self }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
private extension View {
    func alert2(isPresented: Binding<Bool>,
                content: @escaping () -> Alert) -> some View {
        return self.modifier(InspectableAlert(isPresented: isPresented, alertBuilder: content))
    }
    
    func alert2<Item>(item: Binding<Item?>,
                      content: @escaping (Item) -> Alert
    ) -> some View where Item: Identifiable {
        return self.modifier(InspectableAlertWithItem(item: item, alertBuilder: content))
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
private struct InspectableAlert: ViewModifier, AlertProvider {
    
    let isPresented: Binding<Bool>
    let alertBuilder: () -> Alert
    
    func body(content: Self.Content) -> some View {
        content.alert(isPresented: isPresented, content: alertBuilder)
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
private struct InspectableAlertWithItem<Item: Identifiable>: ViewModifier, AlertItemProvider {
    
    let item: Binding<Item?>
    let alertBuilder: (Item) -> Alert
    
    func body(content: Self.Content) -> some View {
        content.alert(item: item, content: alertBuilder)
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
private struct AlertFindTestView: View, Inspectable {
    
    @Binding var isAlert1Presented = false
    @Binding var isAlert2Presented = false
    @Binding var isAlert3Presented = false
    
    init(alert1: Binding<Bool>, alert2: Binding<Bool>, alert3: Binding<Bool>) {
        _isAlert1Presented = alert1
        _isAlert2Presented = alert2
        _isAlert3Presented = alert3
    }
    
    var body: some View {
        HStack {
            EmptyView()
                .alert2(isPresented: $isAlert1Presented) {
                    Alert(title: Text("title_1"),
                          message: Text("message_1"),
                          primaryButton: .default(Text("primary_1")),
                          secondaryButton: .destructive(Text("secondary_1")))
                }
                .alert(isPresented: $isAlert2Presented) {
                    Alert(title: Text("title_2"))
                }
                .alert2(isPresented: $isAlert3Presented) {
                    Alert(title: Text("title_3"), message: nil,
                          dismissButton: .cancel(Text("primary_3")))
                }
        }
    }
}
