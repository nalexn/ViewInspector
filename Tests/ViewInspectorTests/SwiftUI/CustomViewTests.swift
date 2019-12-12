import XCTest
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
        let viewModel = ExternalState()
        let view = ObservedStateTestView(viewModel: viewModel)
        let text1 = try view.inspect().text().string()
        XCTAssertEqual(text1, "false")
        viewModel.flag = true
        let text2 = try view.inspect().text().string()
        XCTAssertEqual(text2, "true")
    }
    
    func testEnvironmentStateChanges() throws {
        let viewModel = ExternalState()
        let view = EnvironmentStateTestView()
        let text1 = try view.inspect(viewModel).text().string()
        XCTAssertEqual(text1, "false")
        viewModel.flag = true
        let text2 = try view.inspect(viewModel).text().string()
        XCTAssertEqual(text2, "true")
    }
    
    func testEnvironmentInjectedView() throws {
        let viewModel = ExternalState()
        let view = EnvironmentStateTestView().environmentObject(viewModel)
        let text = try view.inspect(EnvironmentStateTestView.self, viewModel).text().string()
        XCTAssertEqual(text, "false")
    }
    
    func testInspectableViewWithEnvironmentObject() throws {
        let sut1 = IncorrectTestView().environmentObject(ExternalState())
        XCTAssertThrowsError(try sut1.inspect(IncorrectTestView.self))
        let sut2 = IncorrectTestView()
        XCTAssertThrowsError(try sut2.inspect())
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
    
    func testExtractionEnvViewFromSingleViewContainer() throws {
        let viewModel = ExternalState()
        let view = AnyView(EnvironmentStateTestView())
        XCTAssertNoThrow(try view.inspect().view(EnvironmentStateTestView.self, viewModel))
    }
    
    func testExtractionEnvViewFromMultipleViewContainer() throws {
        let viewModel = ExternalState()
        let view = HStack { EnvironmentStateTestView(); EnvironmentStateTestView() }
        XCTAssertNoThrow(try view.inspect().view(EnvironmentStateTestView.self, viewModel, 0))
        XCTAssertNoThrow(try view.inspect().view(EnvironmentStateTestView.self, viewModel, 1))
    }
    
    func testEnvObjectTypeMismatch() {
        XCTAssertThrowsError(try ViewType.ViewWithEnvObject<EnvironmentStateTestView>
            .content(view: "abc", envObject: Inspector.stubEnvObject))
    }
    
    func testContentViewTypeMismatch() {
        XCTAssertThrowsError(try ViewType.View<SimpleTestView>
            .content(view: "abc", envObject: Inspector.stubEnvObject))
    }
    
    func testActualView() throws {
        let sut = try LocalStateTestView(flag: true).inspect()
        let flagValue = try sut.actualView().flag
        XCTAssertTrue(flagValue)
    }
    
    func testActualViewTypeMismatch() throws {
        let sut = try InspectableView<ViewType.Test<SimpleTestView>>("")
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
    
    var body: some View {
        Text(flag ? "true" : "false")
    }
}

private struct ObservedStateTestView: View, Inspectable {
    
    @ObservedObject var viewModel: ExternalState
    
    var body: some View {
        Text(viewModel.flag ? "true" : "false")
    }
}

private struct IncorrectTestView: View, Inspectable {
    
    @EnvironmentObject var viewModel: ExternalState
    
    var body: some View {
        EmptyView()
    }
}

private struct EnvironmentStateTestView: View, InspectableWithEnvObject {
    @EnvironmentObject var viewModel: ExternalState
    
    var body: Body {
        content(viewModel)
    }
    
    func content(_ viewModel: ExternalState) -> some View {
        Text(viewModel.flag ? "true" : "false")
    }
}

class ExternalState: ObservableObject {
    @Published var flag = false
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
