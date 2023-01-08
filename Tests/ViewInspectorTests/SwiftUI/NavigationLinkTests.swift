import XCTest
import SwiftUI
@testable import ViewInspector

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
final class NavigationLinkTests: XCTestCase {
    
    func testEnclosedView() throws {
        let view = NavigationLink(destination: {
            Text("1"); Text("2")
        }, label: { Text("label") })
        let sut = try view.inspect().navigationLink()
        XCTAssertEqual(try sut.text(0).string(), "1")
        XCTAssertEqual(try sut.text(1).string(), "2")
    }
    
    func testLabelView() throws {
        let view = NavigationLink(
            destination: TestView(parameter: "Screen 1")) { Text("GoTo 1") }
        let text = try view.inspect().navigationLink().labelView().text().string()
        XCTAssertEqual(text, "GoTo 1")
    }
    
    func testResetsModifiers() throws {
        let view = NavigationLink(
            destination: TestView(parameter: "Screen 1")) { Text("GoTo 1") }.padding()
        let sut1 = try view.inspect().navigationLink().view((TestView.self))
        XCTAssertEqual(sut1.content.medium.viewModifiers.count, 0)
        let sut2 = try view.inspect().navigationLink().labelView().text()
        XCTAssertEqual(sut2.content.medium.viewModifiers.count, 0)
    }
    
    func testExtractionFromSingleViewContainer() throws {
        let view = AnyView(NavigationLink(
            destination: TestView(parameter: "Screen 1")) { Text("GoTo 1") })
        XCTAssertNoThrow(try view.inspect().anyView().navigationLink())
    }
    
    @available(watchOS 7.0, *)
    func testExtractionFromMultipleViewContainer() throws {
        let view = NavigationView {
            NavigationLink(
                destination: TestView(parameter: "Screen 1")) { Text("GoTo 1") }
            NavigationLink(
                destination: TestView(parameter: "Screen 1")) { Text("GoTo 2") }
        }
        XCTAssertNoThrow(try view.inspect().navigationView().navigationLink(0))
        XCTAssertNoThrow(try view.inspect().navigationView().navigationLink(1))
    }
    
    @available(watchOS 7.0, *)
    func testSearch() throws {
        let view = AnyView(NavigationView {
            NavigationLink(
                destination: TestView(parameter: "Screen 1")) { Text("GoTo 1") }
            NavigationLink(
                destination: TestView(parameter: "Screen 2")) { Text("GoTo 2") }
        })
        XCTAssertEqual(try view.inspect().find(ViewType.NavigationLink.self).pathToRoot,
                       "anyView().navigationView().navigationLink(0)")
        XCTAssertEqual(try view.inspect().find(navigationLink: "GoTo 1").pathToRoot,
                       "anyView().navigationView().navigationLink(0)")
        XCTAssertEqual(try view.inspect().find(navigationLink: "Screen 2").pathToRoot,
                       "anyView().navigationView().navigationLink(1)")
        XCTAssertEqual(try view.inspect().find(text: "Screen 1").pathToRoot,
                       "anyView().navigationView().navigationLink(0).view(TestView.self).text()")
        XCTAssertEqual(try view.inspect().find(text: "GoTo 2").pathToRoot,
                       "anyView().navigationView().navigationLink(1).labelView().text()")
    }
    
    @available(watchOS 7.0, *)
    func testNavigationWithoutBindingParameter() throws {
        guard #available(iOS 13.1, macOS 10.16, tvOS 13.1, *)
        else { throw XCTSkip() }
        let view = NavigationView {
            NavigationLink(
                destination: TestView(parameter: "Screen 1")) { Text("GoTo 1") }
        }
        let sut = try view.inspect().navigationView().navigationLink(0)
        let errorMessage = """
            Please use `NavigationLink(destination:, tag:, selection:)` \
            if you need to access the state value for reading or writing.
            """
        XCTAssertThrows(try sut.isActive(), errorMessage)
        XCTAssertThrows(try sut.activate(), errorMessage)
        XCTAssertThrows(try sut.deactivate(), errorMessage)
    }
    
    @available(watchOS 7.0, *)
    func testNavigationWithStateActivation() throws {
        let view = TestViewState()
        XCTAssertNil(view.state.selection)
        let sut0 = try view.inspect().navigationView().navigationLink(0)
        let sut1 = try view.inspect().navigationView().navigationLink(1)
        XCTAssertFalse(try sut0.isActive())
        XCTAssertFalse(try sut1.isActive())
        try sut0.activate()
        XCTAssertEqual(view.state.selection, view.tag1)
        XCTAssertTrue(try sut0.isActive())
        XCTAssertFalse(try sut1.isActive())
    }
    
    @available(watchOS 7.0, *)
    func testNavigationWithBindingActivation() throws {
        let selection = Binding<String?>(wrappedValue: nil)
        let view = TestViewBinding(selection: selection)
        XCTAssertNil(view.$selection.wrappedValue)
        let sut0 = try view.inspect().navigationView().navigationLink(0)
        let sut1 = try view.inspect().navigationView().navigationLink(1)
        XCTAssertFalse(try sut0.isActive())
        XCTAssertFalse(try sut1.isActive())
        try sut0.activate()
        XCTAssertEqual(view.$selection.wrappedValue, view.tag1)
        XCTAssertTrue(try sut0.isActive())
        XCTAssertFalse(try sut1.isActive())
    }
    
    @available(watchOS 7.0, *)
    func testNavigationWithStateDeactivation() throws {
        let view = TestViewState()
        view.state.selection = view.tag2
        let sut0 = try view.inspect().navigationView().navigationLink(0)
        let sut1 = try view.inspect().navigationView().navigationLink(1)
        XCTAssertFalse(try sut0.isActive())
        XCTAssertTrue(try sut1.isActive())
        try sut1.deactivate()
        XCTAssertNil(view.state.selection)
        XCTAssertFalse(try sut0.isActive())
        XCTAssertFalse(try sut1.isActive())
    }
    
    @available(watchOS 7.0, *)
    func testNavigationWithBindingDeactivation() throws {
        let selection = Binding<String?>(wrappedValue: nil)
        let view = TestViewBinding(selection: selection)
        view.selection = view.tag2
        let sut0 = try view.inspect().navigationView().navigationLink(0)
        let sut1 = try view.inspect().navigationView().navigationLink(1)
        XCTAssertFalse(try sut0.isActive())
        XCTAssertTrue(try sut1.isActive())
        try sut1.deactivate()
        XCTAssertNil(view.selection)
        XCTAssertFalse(try sut0.isActive())
        XCTAssertFalse(try sut1.isActive())
    }
    
    @available(watchOS 7.0, *)
    func testNavigationWithStateReactivation() throws {
        let view = TestViewState()
        let sut0 = try view.inspect().navigationView().navigationLink(0)
        let sut1 = try view.inspect().navigationView().navigationLink(1)
        try sut1.activate()
        XCTAssertEqual(view.state.selection, view.tag2)
        try sut0.activate()
        XCTAssertEqual(view.state.selection, view.tag1)
        XCTAssertTrue(try sut0.isActive())
        XCTAssertFalse(try sut1.isActive())
    }
    
    @available(watchOS 7.0, *)
    func testNavigationWithBindingReactivation() throws {
        let selection = Binding<String?>(wrappedValue: nil)
        let view = TestViewBinding(selection: selection)
        let sut0 = try view.inspect().navigationView().navigationLink(0)
        let sut1 = try view.inspect().navigationView().navigationLink(1)
        try sut1.activate()
        XCTAssertEqual(view.selection, view.tag2)
        try sut0.activate()
        XCTAssertEqual(view.selection, view.tag1)
        XCTAssertTrue(try sut0.isActive())
        XCTAssertFalse(try sut1.isActive())
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
private struct TestView: View {
    let parameter: String
    
    var body: some View {
        Text(parameter)
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 7.0, *)
private struct TestViewState: View {
    @ObservedObject var state = NavigationState()
    
    var tag1: String { "tag1" }
    var tag2: String { "tag2" }
    
    var body: some View {
        NavigationView {
            NavigationLink(destination: TestView(parameter: "Screen 1"), tag: tag1,
                           selection: self.$state.selection) { Text("GoTo 1") }
            NavigationLink(destination: TestView(parameter: "Screen 2"), tag: tag2,
                           selection: self.$state.selection) { Text("GoTo 2") }
        }
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 7.0, *)
private struct TestViewBinding: View {

    @Binding var selection: String?
    
    var tag1: String { "tag1" }
    var tag2: String { "tag2" }
    
    var body: some View {
        NavigationView {
            NavigationLink(destination: TestView(parameter: "Screen 1"), tag: tag1,
                           selection: self.$selection) { Text("GoTo 1") }
            NavigationLink(destination: TestView(parameter: "Screen 2"), tag: tag2,
                           selection: self.$selection) { Text("GoTo 2") }
        }
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 7.0, *)
extension TestViewState {
    class NavigationState: ObservableObject {
        @Published var selection: String?
    }
}
