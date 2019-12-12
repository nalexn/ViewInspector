import XCTest
import SwiftUI
@testable import ViewInspector

final class ConditionalContentTests: XCTestCase {
    
    func testConditionalView() throws {
        let view = ConditionalView()
        let string1 = try view.inspect().group().text(0).string()
        XCTAssertEqual(string1, "Text")
        view.viewModel.flag.toggle()
        let string2 = try view.inspect().group().image(0).imageName()
        XCTAssertEqual(string2, "Image")
    }
}

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
