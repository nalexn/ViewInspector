import XCTest
import Combine
import SwiftUI

@testable import ViewInspector

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
final class CustomViewTests: XCTestCase {
    
    func testLocalStateChanges() throws {
        let sut = LocalStateTestView(flag: false)
        let exp = sut.inspection.inspect { view in
            let text1 = try view.button().labelView().text().string()
            XCTAssertEqual(text1, "false")
            try view.button().tap()
            let text2 = try view.button().labelView().text().string()
            XCTAssertEqual(text2, "true")
        }
        ViewHosting.host(view: sut)
        wait(for: [exp], timeout: 0.5)
    }
    
    func testObservedStateChanges() throws {
        let viewModel = ExternalState()
        let view = ObservedStateTestView(viewModel: viewModel)
        let text1 = try view.inspect().text().string()
        XCTAssertEqual(text1, "obj1")
        viewModel.value = "abc"
        let text2 = try view.inspect().text().string()
        XCTAssertEqual(text2, "abc")
    }
    
    func testEnvironmentStateChanges() throws {
        let sut = EnvironmentStateTestView()
        let viewModel = ExternalState()
        let exp = sut.inspection.inspect { view in
            let text1 = try view.text().string()
            XCTAssertEqual(text1, "obj1")
            viewModel.value = "abc"
            let text2 = try view.text().string()
            XCTAssertEqual(text2, "abc")
        }
        ViewHosting.host(view: sut.environmentObject(viewModel))
        wait(for: [exp], timeout: 0.1)
    }
    
    func testEnvironmentObjectModifier() throws {
        let viewModel = ExternalState()
        let view = EnvironmentStateTestView().environmentObject(viewModel)
        XCTAssertNoThrow(try view.inspect().view(EnvironmentStateTestView.self))
    }
    
    func testResetsModifiers() throws {
        let view = SimpleTestView().padding()
        let sut = try view.inspect().view(SimpleTestView.self).emptyView()
        XCTAssertEqual(sut.content.modifiers.count, 0)
    }
    
    func testEnvViewResetsModifiers() throws {
        let sut = EnvironmentStateTestView()
        let exp = sut.inspection.inspect { view in
            let sut = try view.text()
            XCTAssertEqual(sut.content.modifiers.count, 0)
        }
        ViewHosting.host(view: sut.environmentObject(ExternalState()).padding())
        wait(for: [exp], timeout: 0.1)
    }
    
    func testExtractionOfTestViewRepresentable() throws {
        let view = AnyView(TestViewRepresentable())
        let sut = try view.inspect().anyView().view(TestViewRepresentable.self)
        XCTAssertNoThrow(try sut.actualView())
        #if os(macOS)
        XCTAssertThrows(try sut.hStack(),
        "Please use `.actualView().nsView()` for inspecting the contents of NSViewRepresentable")
        #else
        XCTAssertThrows(try sut.hStack(),
        "Please use `.actualView().uiView()` for inspecting the contents of UIViewRepresentable")
        #endif
    }
    
    func testExtractionOfViewControllerRepresentable() throws {
        let view = AnyView(TestViewControllerRepresentable())
        let sut = try view.inspect().anyView().view(TestViewControllerRepresentable.self)
        XCTAssertNoThrow(try sut.actualView())
        #if os(macOS)
        XCTAssertThrows(try sut.hStack(),
        "Please use `.actualView().viewController()` for inspecting the contents of NSViewControllerRepresentable")
        #else
        XCTAssertThrows(try sut.hStack(),
        "Please use `.actualView().viewController()` for inspecting the contents of UIViewControllerRepresentable")
        #endif
    }
    
    func testExtractionFromSingleViewContainer() throws {
        let view = AnyView(SimpleTestView())
        XCTAssertNoThrow(try view.inspect().anyView().view(SimpleTestView.self))
    }
    
    func testExtractionFromMultipleViewContainer() throws {
        let view = HStack { SimpleTestView(); SimpleTestView() }
        XCTAssertNoThrow(try view.inspect().hStack().view(SimpleTestView.self, 0))
        XCTAssertNoThrow(try view.inspect().hStack().view(SimpleTestView.self, 1))
    }
    
    func testExtractionEnvView1FromSingleViewContainer() throws {
        let viewModel = ExternalState()
        let view = AnyView(EnvironmentStateTestView().environmentObject(viewModel))
        XCTAssertNoThrow(try view.inspect().anyView().view(EnvironmentStateTestView.self))
    }
    
    func testExtractionEnvViewFromMultipleViewContainer() throws {
        let view = HStack { EnvironmentStateTestView(); EnvironmentStateTestView() }
        XCTAssertNoThrow(try view.inspect().hStack().view(EnvironmentStateTestView.self, 0))
        XCTAssertNoThrow(try view.inspect().hStack().view(EnvironmentStateTestView.self, 1))
    }
    
    func testSyncSearch() throws {
        let sut1 = AnyView(SimpleTestView())
        XCTAssertEqual(try sut1.inspect().find(ViewType.EmptyView.self).pathToRoot,
                       "anyView().view(SimpleTestView.self).emptyView()")
        let viewModel = ExternalState()
        let sut2 = AnyView(ObservedStateTestView(viewModel: viewModel))
        XCTAssertEqual(try sut2.inspect().find(text: viewModel.value).pathToRoot,
                       "anyView().view(ObservedStateTestView.self).text()")
    }
    
    func testAsyncSearch() throws {
        let view = EnvironmentStateTestView()
        let sut = AnyView(view)
        let viewModel = ExternalState()
        let exp = view.inspection.inspect { view in
            XCTAssertEqual(try view.find(text: viewModel.value).pathToRoot,
                           "view(EnvironmentStateTestView.self).text()")
        }
        ViewHosting.host(view: sut.environmentObject(viewModel))
        wait(for: [exp], timeout: 0.1)
    }
    
    func testSearchBlocker() throws {
        let sut = AnyView(NonInspectableTestView())
        XCTAssertThrows(try sut.inspect().find(ViewType.EmptyView.self),
                        "Search did not find a match. Possible blockers: NonInspectableTestView")
    }
    
    func testActualView() throws {
        let sut = LocalStateTestView(flag: true)
        let exp = sut.inspection.inspect { view in
            let value = try view.actualView().flag
            XCTAssertTrue(value)
        }
        ViewHosting.host(view: sut.environmentObject(ExternalState()).padding())
        wait(for: [exp], timeout: 0.1)
    }
    
    func testActualViewTypeMismatch() throws {
        let sut = try InspectableView<ViewType.Test<SimpleTestView>>(Content(""), parent: nil, index: nil)
        XCTAssertThrows(
            try sut.actualView(),
            "Type mismatch: String is not SimpleTestView")
    }
    
    func testPathToRoot() throws {
        let view1 = AnyView(SimpleTestView())
        let sut1 = try view1.inspect().anyView().view(SimpleTestView.self).pathToRoot
        XCTAssertEqual(sut1, "anyView().view(SimpleTestView.self)")
        let view2 = HStack { SimpleTestView() }
        let sut2 = try view2.inspect().hStack().view(SimpleTestView.self, 0).pathToRoot
        XCTAssertEqual(sut2, "hStack().view(SimpleTestView.self, 0)")
    }
    
    func testTestViews() {
        XCTAssertNoThrow(NonInspectableTestView().body)
        XCTAssertNoThrow(SimpleTestView().body)
        XCTAssertNoThrow(ObservedStateTestView(viewModel: ExternalState()).body)
    }
}

// MARK: - Test Views

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
private struct NonInspectableTestView: View {
    var body: some View {
        EmptyView()
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
private struct SimpleTestView: View, Inspectable {
    var body: some View {
        EmptyView()
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
private struct LocalStateTestView: View, Inspectable {
    
    @State private(set) var flag: Bool
    let inspection = Inspection<Self>()
    
    var body: some View {
        Button(action: {
            self.flag.toggle()
        }, label: { Text(flag ? "true" : "false") })
        .onReceive(inspection.notice) { self.inspection.visit(self, $0) }
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
private struct ObservedStateTestView: View, Inspectable {
    
    @ObservedObject var viewModel: ExternalState
    
    var body: some View {
        Text(viewModel.value)
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
private struct EnvironmentStateTestView: View, Inspectable {
    
    @EnvironmentObject var viewModel: ExternalState
    let inspection = Inspection<Self>()
    
    var body: some View {
        Text(viewModel.value)
            .onReceive(inspection.notice) { self.inspection.visit(self, $0) }
    }
}

#if os(macOS)
private struct TestViewRepresentable: NSViewRepresentable, Inspectable {
    
    func makeNSView(context: NSViewRepresentableContext<Self>) -> NSView {
        let view = NSView()
        updateNSView(view, context: context)
        return view
    }
    
    func updateNSView(_ nsView: NSView, context: NSViewRepresentableContext<Self>) {
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
private struct TestViewControllerRepresentable: NSViewControllerRepresentable, Inspectable {
    
    func makeNSViewController(context: Context) -> NSViewController {
        let vc = NSViewController()
        updateNSViewController(vc, context: context)
        return vc
    }
    
    func updateNSViewController(_ uiViewController: NSViewControllerType, context: Context) {
    }
}
#else
@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
private struct TestViewRepresentable: UIViewRepresentable, Inspectable {
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        updateUIView(view, context: context)
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
private struct TestViewControllerRepresentable: UIViewControllerRepresentable, Inspectable {
    
    func makeUIViewController(context: Context) -> UIViewController {
        let vc = UIViewController()
        updateUIViewController(vc, context: context)
        return vc
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
    }
}
#endif

// MARK: - Misc

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
private class ExternalState: ObservableObject {
    @Published var value = "obj1"
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
private struct EnvironmentParameter {
    let state = CurrentValueSubject<String, Never>("obj2")
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension EnvironmentParameter {
    struct EnvKey: EnvironmentKey {
        let state: EnvironmentParameter
        static var defaultValue: Self { .init(state: EnvironmentParameter()) }
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension EnvironmentValues {
    fileprivate var state3: EnvironmentParameter.EnvKey {
        get { self[EnvironmentParameter.EnvKey.self] }
        set { self[EnvironmentParameter.EnvKey.self] = newValue }
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension ViewType {
    struct Test<T>: KnownViewType, CustomViewType where T: Inspectable {
        public static var typePrefix: String { "String" }
    }
}
