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
    
    func testActualView() throws {
        let sut = try LocalStateTestView(flag: true).inspect()
        let flagValue = try sut.actualView().flag
        XCTAssertTrue(flagValue)
    }
    
    static var allTests = [
        ("testLocalStateChanges", testLocalStateChanges),
        ("testExternalStateChanges", testExternalStateChanges),
        ("testActualView", testActualView),
    ]
}

// MARK: - LocalStateTestView

private struct LocalStateTestView: View, Inspectable {
    
    @State private(set) var flag: Bool
    
    var body: some View {
        Text(flag ? "true" : "false")
    }
}

// MARK: - ExternalStateTestView

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
