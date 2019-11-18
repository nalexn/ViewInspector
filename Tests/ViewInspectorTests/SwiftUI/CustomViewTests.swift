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
    
    func testExternalStateChanges() throws {
        let viewModel = ExternalStateTestView.ViewModel()
        let view = ExternalStateTestView(viewModel: viewModel)
        let text1 = try view.inspect().text().string()
        XCTAssertEqual(text1, "false")
        viewModel.flag = true
        let text2 = try view.inspect().text().string()
        XCTAssertEqual(text2, "true")
    }
    
    func testExtractionFromSingleViewContainer() throws {
        let view = AnyView(SimpleTestView())
        XCTAssertNoThrow(try view.inspect().view(SimpleTestView.self))
    }
    
    func testExtractionFromMultipleViewContainer() throws {
        let view = HStack { SimpleTestView(); SimpleTestView() }
        XCTAssertNoThrow(try view.inspect().view(SimpleTestView.self, 0))
        XCTAssertNoThrow(try view.inspect().view(SimpleTestView.self, 1))
    }
    
    func testContentViewTypeMismatch() {
        XCTAssertThrowsError(try ViewType.Custom<SimpleTestView>
            .content(view: "abc"))
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
    
    static var allTests = [
        ("testLocalStateChanges", testLocalStateChanges),
        ("testExternalStateChanges", testExternalStateChanges),
        ("testExtractionFromSingleViewContainer", testExtractionFromSingleViewContainer),
        ("testExtractionFromMultipleViewContainer", testExtractionFromMultipleViewContainer),
        ("testContentViewTypeMismatch", testContentViewTypeMismatch),
        ("testActualView", testActualView),
        ("testActualViewTypeMismatch", testActualViewTypeMismatch),
    ]
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

private struct ExternalStateTestView: View, Inspectable {
    
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        Text(viewModel.flag ? "true" : "false")
    }
}

extension ExternalStateTestView {
    class ViewModel: ObservableObject {
        @Published var flag = false
    }
}

extension ViewType {
    struct Test<T>: KnownViewType, GenericViewType where T: Inspectable {
        public static var typePrefix: String { "String" }
    }
}
