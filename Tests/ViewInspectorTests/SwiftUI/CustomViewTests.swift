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
    
    #if !os(macOS)
    func testToupleView() throws {
        let view = ToupleTestView().padding()
        let sut = try view.inspect().view(ToupleTestView.self)
        XCTAssertNoThrow(try sut.emptyView(0))
        XCTAssertNoThrow(try sut.text(1))
    }
    
    func testToupleViewError() throws {
        let view = ToupleTestView().padding()
        let sut = try view.inspect().view(ToupleTestView.self)
        XCTAssertThrows(try sut.emptyView(),
                        "Unable to extract EmptyView: please specify its index inside parent view")
    }
    #endif
    
    func testEnvViewResetsModifiers() throws {
        let sut = EnvironmentStateTestView()
        let exp = sut.inspection.inspect { view in
            let sut = try view.text()
            XCTAssertEqual(sut.content.modifiers.count, 0)
        }
        ViewHosting.host(view: sut.environmentObject(ExternalState()).padding())
        wait(for: [exp], timeout: 0.1)
    }
    
    #if os(macOS)
    func testExtractionOfNSTestView() throws {
        let view = AnyView(NSTestView())
        let sut = try view.inspect().anyView().view(NSTestView.self)
        XCTAssertNoThrow(try sut.actualView())
    }
    #else
    func testExtractionOfUITestView() throws {
        let view = AnyView(UITestView())
        let sut = try view.inspect().anyView().view(UITestView.self)
        XCTAssertNoThrow(try sut.actualView())
    }
    #endif
    
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
    
    func testActualView() throws {
        let sut = try LocalStateTestView(flag: true).inspect()
        let flagValue = try sut.actualView().flag
        XCTAssertTrue(flagValue)
    }
    
    func testActualViewTypeMismatch() throws {
        let sut = try InspectableView<ViewType.Test<SimpleTestView>>(Content(""))
        XCTAssertThrows(
            try sut.actualView(),
            "Type mismatch: String is not SimpleTestView")
    }
    
    func testTestViews() {
        XCTAssertNoThrow(SimpleTestView().body)
        XCTAssertNoThrow(LocalStateTestView(flag: true).body)
        XCTAssertNoThrow(ObservedStateTestView(viewModel: ExternalState()).body)
    }
}

// MARK: - Test Views

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
private struct SimpleTestView: View, Inspectable {
    var body: some View {
        EmptyView()
    }
}

#if !os(macOS)
@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
private struct ToupleTestView: View, Inspectable {
    var body: some View {
        EmptyView()
        Text("abc")
    }
}
#endif

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
private struct NSTestView: NSViewRepresentable, Inspectable {
    
    func makeNSView(context: NSViewRepresentableContext<Self>) -> NSView {
        let view = NSView()
        updateNSView(view, context: context)
        return view
    }
    
    func updateNSView(_ nsView: NSView, context: NSViewRepresentableContext<Self>) {
    }
}
#else
@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
private struct UITestView: UIViewRepresentable, Inspectable {
    
    func makeUIView(context: UIViewRepresentableContext<Self>) -> UIView {
        let view = UIView()
        updateUIView(view, context: context)
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<Self>) {
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

extension ViewType {
    struct Test<T>: KnownViewType, CustomViewType where T: Inspectable {
        public static var typePrefix: String { "String" }
    }
}
