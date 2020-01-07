import XCTest
import Combine
import SwiftUI

@testable import ViewInspector

final class CustomViewTests: XCTestCase {
    
    func testLocalStateChangesOnView() throws {
        var sut = LocalStateTestView(flag: false)
        let exp = sut.on(\.didAppear) { view in
            XCTAssertFalse(view.flag)
            try view.inspect().button().tap()
            XCTAssertTrue(view.flag)
        }
        ViewHosting.host(view: sut)
        wait(for: [exp], timeout: 0.1)
    }
    
    func testLocalStateChangesOnMirror() throws {
        var sut = LocalStateTestView(flag: false)
        let exp = sut.on(\.didAppear) { view in
            let mirror = try view.inspect()
            let text1 = try mirror.button().text().string()
            XCTAssertEqual(text1, "false")
            try mirror.button().tap()
            let text2 = try mirror.button().text().string()
            XCTAssertEqual(text2, "true")
        }
        ViewHosting.host(view: sut)
        wait(for: [exp], timeout: 0.1)
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
    
    func testEnvironmentStateChanges1() throws {
        var sut = EnvironmentStateTestView()
        let viewModel = ExternalState()
        let exp = sut.on(\.didAppear) { view in
            let text1 = try view.inspect().text().string()
            XCTAssertEqual(text1, "obj1")
            viewModel.value = "abc"
            let text2 = try view.inspect().text().string()
            XCTAssertEqual(text2, "abc")
        }
        ViewHosting.host(view: sut.environmentObject(viewModel))
        wait(for: [exp], timeout: 0.1)
    }
    
    func testEnvironmentObjectModifier() throws {
        let viewModel = ExternalState()
        let view = EnvironmentStateTestView().environmentObject(viewModel)
        XCTAssertNoThrow(try view.inspect(EnvironmentStateTestView.self))
    }
    
    func testResetsModifiers() throws {
        let view = SimpleTestView().padding()
        let sut = try view.inspect().view(SimpleTestView.self).emptyView()
        XCTAssertEqual(sut.content.modifiers.count, 0)
    }
    
    func testEnvViewResetsModifiers() throws {
        var sut = EnvironmentStateTestView()
        let exp = sut.on(\.didAppear) { view in
            let sut = try view.inspect().text()
            // There is an inner 1 modifier "onAppear"
            XCTAssertEqual(sut.content.modifiers.count, 1)
        }
        ViewHosting.host(view: sut.environmentObject(ExternalState()).padding())
        wait(for: [exp], timeout: 0.1)
    }
    
    #if os(iOS) || os(tvOS)
    func testExtractionOfUIKitView() throws {
        let view = AnyView(UIKitTestView())
        let sut = try view.inspect().view(UIKitTestView.self)
        XCTAssertNoThrow(try sut.actualView())
    }
    #endif
    
    func testExtractionFromSingleViewContainer() throws {
        let view = AnyView(SimpleTestView())
        XCTAssertNoThrow(try view.inspect().view(SimpleTestView.self))
    }
    
    func testExtractionFromMultipleViewContainer() throws {
        let view = HStack { SimpleTestView(); SimpleTestView() }
        XCTAssertNoThrow(try view.inspect().view(SimpleTestView.self, 0))
        XCTAssertNoThrow(try view.inspect().view(SimpleTestView.self, 1))
    }
    
    func testExtractionEnvView1FromSingleViewContainer() throws {
        let viewModel = ExternalState()
        let view = AnyView(EnvironmentStateTestView().environmentObject(viewModel))
        XCTAssertNoThrow(try view.inspect().view(EnvironmentStateTestView.self))
    }
    
    func testExtractionEnvViewFromMultipleViewContainer() throws {
        let view = HStack { EnvironmentStateTestView(); EnvironmentStateTestView() }
        XCTAssertNoThrow(try view.inspect().view(EnvironmentStateTestView.self, 0))
        XCTAssertNoThrow(try view.inspect().view(EnvironmentStateTestView.self, 1))
    }
    
    func testContentViewTypeMismatch() {
        XCTAssertThrowsError(try ViewType.View<SimpleTestView>
            .child(Content("abc"), injection: InjectionParameters()))
    }
    
    func testActualView() throws {
        let sut = try LocalStateTestView(flag: true).inspect()
        let flagValue = try sut.actualView().flag
        XCTAssertTrue(flagValue)
    }
    
    func testActualViewTypeMismatch() throws {
        let sut = try InspectableView<ViewType.Test<SimpleTestView>>(Content(""))
        XCTAssertThrowsError(try sut.actualView())
    }
    
    func testTestViews() {
        XCTAssertNoThrow(SimpleTestView().body)
        XCTAssertNoThrow(LocalStateTestView(flag: true).body)
        XCTAssertNoThrow(ObservedStateTestView(viewModel: ExternalState()).body)
        XCTAssertNoThrow(IncorrectTestView().body)
    }
}

private struct SimpleTestView: View, Inspectable {
    var body: some View {
        EmptyView()
    }
}

private struct LocalStateTestView: View, Inspectable {
    
    @State private(set) var flag: Bool
    var didAppear: ((Self) -> Void)?
    
    var body: some View {
        Button(action: {
            self.flag.toggle()
        }, label: { Text(flag ? "true" : "false") })
        .onAppear { self.didAppear?(self) }
    }
}

private struct ObservedStateTestView: View, Inspectable {
    
    @ObservedObject var viewModel: ExternalState
    
    var body: some View {
        Text(viewModel.value)
    }
}

private struct IncorrectTestView: View, Inspectable {
    
    @EnvironmentObject var viewModel: ExternalState
    
    var body: some View {
        EmptyView()
    }
}

private struct EnvironmentStateTestView: View, Inspectable {
    
    @EnvironmentObject var viewModel: ExternalState
    var didAppear: ((Self) -> Void)?
    
    var body: some View {
        Text(viewModel.value)
            .onAppear { self.didAppear?(self) }
    }
}

private class ExternalState: ObservableObject {
    @Published var value = "obj1"
}

private struct EnvironmentParameter {
    let state = CurrentValueSubject<String, Never>("obj2")
}

extension EnvironmentParameter {
    struct EnvKey: EnvironmentKey {
        let state: EnvironmentParameter
        static var defaultValue: Self { .init(state: EnvironmentParameter()) }
    }
}

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

#if os(iOS) || os(tvOS)
struct UIKitTestView: UIViewRepresentable, Inspectable {
    func makeUIView(context: UIViewRepresentableContext<UIKitTestView>) -> UIView {
        return UIView()
    }
    
    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<UIKitTestView>) {
        
    }
}
#endif
