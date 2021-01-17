import XCTest
import SwiftUI
@testable import ViewInspector

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
final class ConditionalContentTests: XCTestCase {
    
    func testConditionalView() throws {
        let view = ConditionalView()
        let string1 = try view.inspect().group().text(0).string()
        XCTAssertEqual(string1, "Text")
        view.viewModel.flag.toggle()
        let string2 = try view.inspect().group().image(0).actualImage().name()
        XCTAssertEqual(string2, "Image")
    }
    
    func testResetsModifiers() throws {
        let view = ConditionalView().padding()
        let sut = try view.inspect().view(ConditionalView.self).group()
        XCTAssertEqual(sut.content.modifiers.count, 0)
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
private struct ConditionalView: View, Inspectable {
    
    @ObservedObject var viewModel = ViewModel()
    var body: some View {
        Group {
            if viewModel.flag { Text("Text")
            } else { Image("Image") }
        }
    }
    
    class ViewModel: ObservableObject {
        @Published var flag: Bool = true
    }
}
