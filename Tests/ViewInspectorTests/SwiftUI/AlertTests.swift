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
            https://github.com/nalexn/ViewInspector/blob/master/guide.md#alert
            """)
    }
    
    func testInspectionErrorAlertNotPresented() throws {
        let binding = Binding(wrappedValue: false)
        let sut = EmptyView().alert2(isPresented: binding) { Alert(title: Text("abc")) }
        XCTAssertThrows(try sut.inspect().emptyView().alert(),
                        "View for Alert is absent")
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
}

extension Int: Identifiable {
    public var id: Int { self }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
private extension View {
    func alert2(isPresented: Binding<Bool>,
                content: @escaping () -> SwiftUI.Alert) -> some View {
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
