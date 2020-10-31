import XCTest
import SwiftUI
@testable import ViewInspector

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
final class NavigationLinkTests: XCTestCase {
    
    func testEnclosedView() throws {
        let view = NavigationLink(
            destination: Text("Screen 1")) { Text("GoTo 1") }
        let text = try view.inspect().navigationLink().text().string()
        XCTAssertEqual(text, "Screen 1")
    }
    
    func testLabelView() throws {
        let view = NavigationLink(
            destination: Text("Screen 1")) { Text("GoTo 1") }
        let text = try view.inspect().navigationLink().labelView().text().string()
        XCTAssertEqual(text, "GoTo 1")
    }
    
    func testDeprecatedLabelInspection() throws {
        let view = NavigationLink(
            destination: Text("Screen 1")) { Text("GoTo 1") }
        XCTAssertNoThrow(try view.inspect().navigationLink().label())
    }
    
    func testResetsModifiers() throws {
        let view = NavigationLink(
            destination: Text("Screen 1")) { Text("GoTo 1") }.padding()
        let sut1 = try view.inspect().navigationLink().text()
        XCTAssertEqual(sut1.content.modifiers.count, 0)
        let sut2 = try view.inspect().navigationLink().labelView().text()
        XCTAssertEqual(sut2.content.modifiers.count, 0)
    }
    
    func testExtractionFromSingleViewContainer() throws {
        let view = AnyView(NavigationLink(
            destination: Text("Screen 1")) { Text("GoTo 1") })
        XCTAssertNoThrow(try view.inspect().anyView().navigationLink())
    }
    
    func testExtractionFromMultipleViewContainer() throws {
        let view = NavigationView {
            NavigationLink(
                destination: Text("Screen 1")) { Text("GoTo 1") }
            NavigationLink(
                destination: Text("Screen 2")) { Text("GoTo 2") }
        }
        XCTAssertNoThrow(try view.inspect().navigationView().navigationLink(0))
        XCTAssertNoThrow(try view.inspect().navigationView().navigationLink(1))
    }
    
    func testNavigationWithoutBindingAndState() throws {
        let view = NavigationView {
            NavigationLink(
                destination: Text("Screen 1")) { Text("GoTo 1") }
        }
        let isActive = try view.inspect().navigationView().navigationLink(0).isActive()
        XCTAssertFalse(isActive)
        XCTAssertThrows(
            try view.inspect().navigationView().navigationLink(0).activate(),
            "Enable programmatic navigation by using `NavigationLink(destination:, tag:, selection:)`")
    }
    
    func testNavigationWithStateActivation() throws {
        let view = TestViewState()
        XCTAssertNil(view.state.selection)
        let isActive1 = try view.inspect().navigationView().navigationLink(0).isActive()
        let isActive2 = try view.inspect().navigationView().navigationLink(1).isActive()
        XCTAssertFalse(isActive1)
        XCTAssertFalse(isActive2)
        try view.inspect().navigationView().navigationLink(0).activate()
        XCTAssertEqual(view.state.selection, view.tag1)
        let isActiveAfter1 = try view.inspect().navigationView().navigationLink(0).isActive()
        let isActiveAfter2 = try view.inspect().navigationView().navigationLink(1).isActive()
        XCTAssertTrue(isActiveAfter1)
        XCTAssertFalse(isActiveAfter2)
    }
    
    func testNavigationWithBindingActivation() throws {
        let selection = Binding<String?>(wrappedValue: nil)
        let view = TestViewBinding(selection: selection)
        XCTAssertNil(view.$selection.wrappedValue)
        let isActive1 = try view.inspect().navigationView().navigationLink(0).isActive()
        let isActive2 = try view.inspect().navigationView().navigationLink(1).isActive()
        XCTAssertFalse(isActive1)
        XCTAssertFalse(isActive2)
        try view.inspect().navigationView().navigationLink(0).activate()
        XCTAssertEqual(view.$selection.wrappedValue, view.tag1)
        let isActiveAfter1 = try view.inspect().navigationView().navigationLink(0).isActive()
        let isActiveAfter2 = try view.inspect().navigationView().navigationLink(1).isActive()
        XCTAssertTrue(isActiveAfter1)
        XCTAssertFalse(isActiveAfter2)
    }
    
    func testNavigationWithStateDeactivation() throws {
        let view = TestViewState()
        view.state.selection = view.tag2
        let isActive1 = try view.inspect().navigationView().navigationLink(0).isActive()
        let isActive2 = try view.inspect().navigationView().navigationLink(1).isActive()
        XCTAssertFalse(isActive1)
        XCTAssertTrue(isActive2)
        try view.inspect().navigationView().navigationLink(1).deactivate()
        XCTAssertNil(view.state.selection)
        let isActiveAfter1 = try view.inspect().navigationView().navigationLink(0).isActive()
        let isActiveAfter2 = try view.inspect().navigationView().navigationLink(1).isActive()
        XCTAssertFalse(isActiveAfter1)
        XCTAssertFalse(isActiveAfter2)
    }
    
    func testNavigationWithBindingDeactivation() throws {
        let selection = Binding<String?>(wrappedValue: nil)
        let view = TestViewBinding(selection: selection)
        view.selection = view.tag2
        let isActive1 = try view.inspect().navigationView().navigationLink(0).isActive()
        let isActive2 = try view.inspect().navigationView().navigationLink(1).isActive()
        XCTAssertFalse(isActive1)
        XCTAssertTrue(isActive2)
        try view.inspect().navigationView().navigationLink(1).deactivate()
        XCTAssertNil(view.selection)
        let isActiveAfter1 = try view.inspect().navigationView().navigationLink(0).isActive()
        let isActiveAfter2 = try view.inspect().navigationView().navigationLink(1).isActive()
        XCTAssertFalse(isActiveAfter1)
        XCTAssertFalse(isActiveAfter2)
    }
    
    func testNavigationWithStateReactivation() throws {
        let view = TestViewState()
        try view.inspect().navigationView().navigationLink(1).activate()
        XCTAssertEqual(view.state.selection, view.tag2)
        try view.inspect().navigationView().navigationLink(0).activate()
        XCTAssertEqual(view.state.selection, view.tag1)
        let isActiveAfter1 = try view.inspect().navigationView().navigationLink(0).isActive()
        let isActiveAfter2 = try view.inspect().navigationView().navigationLink(1).isActive()
        XCTAssertTrue(isActiveAfter1)
        XCTAssertFalse(isActiveAfter2)
    }
    
    func testNavigationWithBindingReactivation() throws {
        let selection = Binding<String?>(wrappedValue: nil)
        let view = TestViewBinding(selection: selection)
        try view.inspect().navigationView().navigationLink(1).activate()
        XCTAssertEqual(view.selection, view.tag2)
        try view.inspect().navigationView().navigationLink(0).activate()
        XCTAssertEqual(view.selection, view.tag1)
        let isActiveAfter1 = try view.inspect().navigationView().navigationLink(0).isActive()
        let isActiveAfter2 = try view.inspect().navigationView().navigationLink(1).isActive()
        XCTAssertTrue(isActiveAfter1)
        XCTAssertFalse(isActiveAfter2)
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
private struct TestViewState: View, Inspectable {
    @ObservedObject var state = NavigationState()
    
    var tag1: String { "tag1" }
    var tag2: String { "tag2" }
    
    var body: some View {
        NavigationView {
            NavigationLink(destination: Text("Screen 1"), tag: tag1,
                           selection: self.$state.selection) { Text("GoTo 1") }
            NavigationLink(destination: Text("Screen 2"), tag: tag2,
                           selection: self.$state.selection) { Text("GoTo 2") }
        }
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
private struct TestViewBinding: View, Inspectable {

    @Binding var selection: String?
    
    var tag1: String { "tag1" }
    var tag2: String { "tag2" }
    
    var body: some View {
        NavigationView {
            NavigationLink(destination: Text("Screen 1"), tag: tag1,
                           selection: self.$selection) { Text("GoTo 1") }
            NavigationLink(destination: Text("Screen 2"), tag: tag2,
                           selection: self.$selection) { Text("GoTo 2") }
        }
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension TestViewState {
    class NavigationState: ObservableObject {
        @Published var selection: String?
    }
}
