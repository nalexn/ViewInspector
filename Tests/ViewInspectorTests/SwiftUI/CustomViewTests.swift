import XCTest
import Combine
import SwiftUI

@testable import ViewInspector

final class CustomViewTests: XCTestCase {
    
    func testLocalStateChanges() throws {
        let text1 = try LocalStateTestView(flag: false).inspect().text().string()
        XCTAssertEqual(text1, "false")
        let text2 = try LocalStateTestView(flag: true).inspect().text().string()
        XCTAssertEqual(text2, "true")
    }
    
    func testObservedStateChanges() throws {
        let viewModel = ExternalState1()
        let view = ObservedStateTestView(viewModel: viewModel)
        let text1 = try view.inspect().text().string()
        XCTAssertEqual(text1, "obj1")
        viewModel.value = "abc"
        let text2 = try view.inspect().text().string()
        XCTAssertEqual(text2, "abc")
    }
    
    func testEnvironmentStateChanges1() throws {
        let viewModel = ExternalState1()
        let view = EnvironmentStateTestView1()
        let text1 = try view.inspect(viewModel).text().string()
        XCTAssertEqual(text1, "obj1")
        viewModel.value = "abc"
        let text2 = try view.inspect(viewModel).text().string()
        XCTAssertEqual(text2, "abc")
    }
    
    func testEnvironmentStateChanges2() throws {
        let object1 = ExternalState1(), object2 = ExternalState2()
        let view = EnvironmentStateTestView2()
        let text1 = try view.inspect(object1, object2).text().string()
        XCTAssertEqual(text1, "obj1obj2")
        object2.value = "abc"
        let text2 = try view.inspect(object1, object2).text().string()
        XCTAssertEqual(text2, "obj1abc")
    }
    
    func testEnvironmentStateChanges3() throws {
        let object1 = ExternalState1(), object2 = ExternalState2(), object3 = EnvironmentParameter()
        let view = EnvironmentStateTestView3()
        let text1 = try view.inspect(object1, object2, object3).text().string()
        XCTAssertEqual(text1, "obj1obj2obj3")
        object3.state.value = "abc"
        let text2 = try view.inspect(object1, object2, object3).text().string()
        XCTAssertEqual(text2, "obj1obj2abc")
    }
    
    func testEnvironmentObjectModifier() throws {
        let viewModel = ExternalState1()
        let view = EnvironmentStateTestView1().environmentObject(viewModel)
        let text = try view.inspect(EnvironmentStateTestView1.self, viewModel).text().string()
        XCTAssertEqual(text, "obj1")
    }
    
    func testInspectableViewWithEnvironmentObject() throws {
        let sut1 = IncorrectTestView().environmentObject(ExternalState1())
        XCTAssertThrowsError(try sut1.inspect(IncorrectTestView.self))
        let sut2 = IncorrectTestView()
        XCTAssertThrowsError(try sut2.inspect())
    }
    
    func testResetsModifiers() throws {
        let view = SimpleTestView().padding()
        let sut = try view.inspect().view(SimpleTestView.self).emptyView()
        XCTAssertEqual(sut.content.modifiers.count, 0)
    }
    
    func testEnvViewResetsModifiers() throws {
        let viewModel = ExternalState1()
        let view = EnvironmentStateTestView1().padding()
        let sut = try view.inspect().view(EnvironmentStateTestView1.self, viewModel).text()
        XCTAssertEqual(sut.content.modifiers.count, 0)
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
        let viewModel = ExternalState1()
        let view = AnyView(EnvironmentStateTestView1())
        XCTAssertNoThrow(try view.inspect().view(EnvironmentStateTestView1.self, viewModel))
    }
    
    func testExtractionEnvView2FromSingleViewContainer() throws {
        let object1 = ExternalState1(), object2 = ExternalState2()
        let view = AnyView(EnvironmentStateTestView2())
        XCTAssertNoThrow(try view.inspect()
            .view(EnvironmentStateTestView2.self, object1, object2))
    }
    
    func testExtractionEnvView3FromSingleViewContainer() throws {
        let object1 = ExternalState1(), object2 = ExternalState2(), object3 = EnvironmentParameter()
        let view = AnyView(EnvironmentStateTestView3())
        XCTAssertNoThrow(try view.inspect()
            .view(EnvironmentStateTestView3.self, object1, object2, object3))
    }
    
    func testExtractionEnvView1FromMultipleViewContainer() throws {
        let viewModel = ExternalState1()
        let view = HStack { EnvironmentStateTestView1(); EnvironmentStateTestView1() }
        XCTAssertNoThrow(try view.inspect().view(EnvironmentStateTestView1.self, viewModel, 0))
        XCTAssertNoThrow(try view.inspect().view(EnvironmentStateTestView1.self, viewModel, 1))
    }
    
    func testExtractionEnvView2FromMultipleViewContainer() throws {
        let object1 = ExternalState1(), object2 = ExternalState2()
        let view = HStack { EnvironmentStateTestView2() }
        XCTAssertNoThrow(try view.inspect()
            .view(EnvironmentStateTestView2.self, object1, object2, 0))
    }
    
    func testExtractionEnvView3FromMultipleViewContainer() throws {
        let object1 = ExternalState1(), object2 = ExternalState2(), object3 = EnvironmentParameter()
        let view = HStack { EnvironmentStateTestView3() }
        XCTAssertNoThrow(try view.inspect()
            .view(EnvironmentStateTestView3.self, object1, object2, object3, 0))
    }
    
    func testEnvObjectTypeMismatch() {
        XCTAssertThrowsError(try ViewType.ViewWithEnvObject<EnvironmentStateTestView1>
            .child(Content("abc"), injection: InjectionParameters([])))
    }
    
    func testContentViewTypeMismatch() {
        XCTAssertThrowsError(try ViewType.View<SimpleTestView>
            .child(Content("abc"), injection: InjectionParameters([])))
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
        XCTAssertNoThrow(ObservedStateTestView(viewModel: ExternalState1()).body)
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
    
    var body: some View {
        Text(flag ? "true" : "false")
    }
}

private struct ObservedStateTestView: View, Inspectable {
    
    @ObservedObject var viewModel: ExternalState1
    
    var body: some View {
        Text(viewModel.value)
    }
}

private struct IncorrectTestView: View, Inspectable {
    
    @EnvironmentObject var viewModel: ExternalState1
    
    var body: some View {
        EmptyView()
    }
}

private struct EnvironmentStateTestView1: View, InspectableWithOneParam {
    @EnvironmentObject var viewModel: ExternalState1
    
    var body: some View {
        body(viewModel)
    }
    
    func body(_ viewModel: ExternalState1) -> some View {
        Text(viewModel.value)
    }
}

private struct EnvironmentStateTestView2: View, InspectableWithTwoParam {
    @EnvironmentObject var object1: ExternalState1
    @EnvironmentObject var object2: ExternalState2
    
    var body: some View {
        body(object1, object2)
    }
    
    func body(_ object1: ExternalState1, _ object2: ExternalState2) -> some View {
        Text(object1.value + object2.value)
    }
}

private struct EnvironmentStateTestView3: View, InspectableWithThreeParam {
    @EnvironmentObject var object1: ExternalState1
    @EnvironmentObject var object2: ExternalState2
    @Environment(\.state3) var object3: EnvironmentParameter.EnvKey
    
    var body: some View {
        body(object1, object2, object3.state)
    }
    
    func body(_ object1: ExternalState1, _ object2: ExternalState2,
              _ object3: EnvironmentParameter) -> some View {
        Text(object1.value + object2.value + object3.state.value)
    }
}

private class ExternalState1: ObservableObject {
    @Published var value = "obj1"
}

private class ExternalState2: ObservableObject {
    @Published var value = "obj2"
}

private struct EnvironmentParameter {
    let state = CurrentValueSubject<String, Never>("obj3")
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
