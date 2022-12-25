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
        let view = ConditionalView().padding().offset()
        let sut = try view.inspect().view(ConditionalView.self).group()
        XCTAssertEqual(sut.content.medium.viewModifiers.count, 1)
        let text = try sut.text(0)
        XCTAssertEqual(text.content.medium.viewModifiers.count, 0)
    }
    
    func testRetainsModifiers() throws {
        let sut = ConditionalViewWithModifier(value: true)
        let text = try sut.inspect().text()
        XCTAssertEqual(try text.string(), "True")
        XCTAssertEqual(try text.padding(), EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8))
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
private struct ConditionalView: View {
    
    @ObservedObject var viewModel = ViewModel()
    var body: some View {
        Group {
            if viewModel.flag { Text("Text")
            } else { Image("Image") }
        }.padding(8)
    }
    
    class ViewModel: ObservableObject {
        @Published var flag: Bool = true
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
private struct ConditionalViewWithModifier: View {
    
    let value: Bool
    
    var body: some View {
        content
            .padding(8)
    }
    
    @ViewBuilder private var content: some View {
        if value {
            Text("True")
        } else {
            Text("False")
        }
    }
}
