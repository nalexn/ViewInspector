import XCTest
import SwiftUI
import UIKit
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
