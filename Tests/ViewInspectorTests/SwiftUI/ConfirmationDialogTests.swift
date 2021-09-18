import XCTest
import SwiftUI
@testable import ViewInspector

#if !os(macOS) // requires macOS SDK 12.0
@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
final class ConfirmationDialogTests: XCTestCase {
    
    func testInspectionNotBlocked() throws {
        guard #available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
        else { return }
        let binding = Binding(wrappedValue: true)
        let sut = EmptyView().confirmationDialog(Text("title"), isPresented: binding, actions: { EmptyView() })
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testInspectionErrorNoModifier() throws {
        guard #available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
        else { return }
        let sut = EmptyView().offset()
        XCTAssertThrows(try sut.inspect().emptyView().confirmationDialog(),
                        "EmptyView does not have 'confirmationDialog' modifier")
    }
    
    func testInspectionErrorWhenNotPresented() throws {
        guard #available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
        else { return }
        let binding = Binding(wrappedValue: false)
        let sut = EmptyView().confirmationDialog(Text("title"), isPresented: binding, actions: { EmptyView() })
        XCTAssertThrows(try sut.inspect().emptyView().confirmationDialog(),
                        "View for ConfirmationDialog is absent")
    }
    
    func testSimpleUnwrap() throws {
        guard #available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
        else { return }
        let binding = Binding(wrappedValue: true)
        let sut = EmptyView().confirmationDialog(Text("title"), isPresented: binding, actions: { EmptyView() })
        XCTAssertEqual(try sut.inspect().emptyView().confirmationDialog().pathToRoot,
                       "emptyView().confirmationDialog()")
    }
    
    func testTitleVisibility() throws {
        guard #available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
        else { return }
        let binding = Binding(wrappedValue: true)
        let sut = EmptyView().confirmationDialog(
            Text("abc"), isPresented: binding,
            titleVisibility: .visible, actions: { EmptyView() })
        let visibility = try sut.inspect().emptyView().confirmationDialog().titleVisibility()
        XCTAssertEqual(visibility, .visible)
    }
    
    func testTitleInspection() throws {
        guard #available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
        else { return }
        let binding = Binding(wrappedValue: true)
        let sut = EmptyView().confirmationDialog(Text("abc"), isPresented: binding, actions: { EmptyView() })
        let title = try sut.inspect().emptyView().confirmationDialog().title()
        XCTAssertEqual(try title.string(), "abc")
        XCTAssertEqual(title.pathToRoot, "emptyView().confirmationDialog().title()")
    }
    
    func testMessageInspection() throws {
        guard #available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
        else { return }
        let binding = Binding(wrappedValue: true)
        let sut = EmptyView().confirmationDialog(
            Text("title"), isPresented: binding, actions: { EmptyView() },
            message: { AnyView(Text("abc")) })
        let message = try sut.inspect().emptyView().confirmationDialog().message().anyView().text()
        XCTAssertEqual(try message.string(), "abc")
        XCTAssertEqual(message.pathToRoot,
                       "emptyView().confirmationDialog().message().anyView().text()")
    }
    
    func testActionsInspection() throws {
        guard #available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
        else { return }
        let binding = Binding(wrappedValue: true)
        let sut = EmptyView().confirmationDialog(
            Text(""), isPresented: binding, presenting: "abc") { AnyView(Text($0)) }
        let message = try sut.inspect().emptyView().confirmationDialog().actions().anyView().text()
        XCTAssertEqual(try message.string(), "abc")
        XCTAssertEqual(message.pathToRoot,
                       "emptyView().confirmationDialog().actions().anyView().text()")
    }
    
    func testDismiss() throws {
        guard #available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
        else { return }
        let binding = Binding(wrappedValue: true)
        let sut = EmptyView().confirmationDialog(
            Text("abc"), isPresented: binding, actions: { EmptyView() })
        try sut.inspect().emptyView().confirmationDialog().dismiss()
        XCTAssertThrows(try sut.inspect().emptyView().confirmationDialog(),
                        "View for ConfirmationDialog is absent")
    }
    
    func testSearch() throws {
        guard #available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
        else { return }
        let binding = Binding(wrappedValue: true)
        let sut = Group {
            EmptyView()
            Text("")
                .confirmationDialog(Text("1"), isPresented: binding,
                                    actions: { EmptyView() }, message: { Text("2") })
                .padding()
                .confirmationDialog(Text("3"), isPresented: binding,
                                    actions: { Text("4") })
        }
        XCTAssertEqual(try sut.inspect().find(text: "1").pathToRoot,
                       "group().text(1).confirmationDialog().title()")
        XCTAssertEqual(try sut.inspect().find(text: "2").pathToRoot,
                       "group().text(1).confirmationDialog().message().text()")
        XCTAssertEqual(try sut.inspect().find(text: "3").pathToRoot,
                       "group().text(1).confirmationDialog(1).title()")
        XCTAssertEqual(try sut.inspect().find(text: "4").pathToRoot,
                       "group().text(1).confirmationDialog(1).actions().text()")
    }
}
#endif
