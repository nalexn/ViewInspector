import XCTest
import Combine
import SwiftUI

@testable import ViewInspector

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
final class CustomViewBuilderTests: XCTestCase {
    
    func testSingleEnclosedView() throws {
        let sut = TestViewBuilderView { Text("Test") }
        let string = try sut.inspect().text(0).string()
        XCTAssertEqual(string, "Test")
    }
    
    func testSingleEnclosedViewIndexOutOfBounds() throws {
        let sut = TestViewBuilderView { Text("Test") }
        XCTAssertThrows(
            try sut.inspect().text(1),
            "Enclosed view index '1' is out of bounds: '0 ..< 1'")
    }
    
    func testMultipleEnclosedViews() throws {
        let sampleView1 = Text("Test")
        let sampleView2 = Text("Abc")
        let sampleView3 = Text("XYZ")
        let view = TestViewBuilderView { sampleView1; sampleView2; sampleView3 }
        let view1 = try view.inspect().text(0).content.view as? Text
        let view2 = try view.inspect().text(1).content.view as? Text
        let view3 = try view.inspect().text(2).content.view as? Text
        XCTAssertEqual(view1, sampleView1)
        XCTAssertEqual(view2, sampleView2)
        XCTAssertEqual(view3, sampleView3)
    }
    
    func testMultipleEnclosedViewsIndexOutOfBounds() throws {
        let sampleView1 = Text("Test")
        let sampleView2 = Text("Abc")
        let view = TestViewBuilderView { sampleView1; sampleView2 }
        XCTAssertThrows(
            try view.inspect().text(2),
            "Enclosed view index '2' is out of bounds: '0 ..< 2'")
    }
    
    func testResetsModifiers() throws {
        let view1 = TestViewBuilderView { Text("Test") }.padding().offset()
        let sut1 = try view1.inspect().view(TestViewBuilderView<Text>.self).text(0)
        XCTAssertEqual(sut1.content.modifiers.count, 1)
        let view2 = TestViewBuilderView { Text("Test"); EmptyView() }.padding().offset()
        let sut2 = try view2.inspect().view(TestViewBuilderView<Text>.self).text(0)
        XCTAssertEqual(sut2.content.modifiers.count, 0)
    }
    
    func testExtractionFromSingleViewContainer() throws {
        let view = AnyView(TestViewBuilderView {
            Spacer()
            Text("Test")
        })
        XCTAssertNoThrow(try view.inspect().anyView()
            .view(TestViewBuilderView<EmptyView>.self).text(1))
    }
    
    func testExtractionFromMultipleViewContainer() throws {
        let view = HStack {
            TestViewBuilderView { Text("Test") }
            TestViewBuilderView { Text("Test") }
        }
        XCTAssertNoThrow(try view.inspect().hStack().view(TestViewBuilderView<Text>.self, 0))
        XCTAssertNoThrow(try view.inspect().hStack().view(TestViewBuilderView<Text>.self, 1))
    }
    
    func testActualView() throws {
        let sut = TestViewBuilderView { Text("Test") }
        XCTAssertNoThrow(try sut.inspect().actualView().content)
    }
    
    func testViewBody() {
        XCTAssertNoThrow(TestViewBuilderView { Text("Test") }.body)
    }
    
    func testPathToRoot() throws {
        let view = HStack {
            TestViewBuilderView { Text("Test"); EmptyView() }
        }
        let sut = try view.inspect().hStack().view(TestViewBuilderView<EmptyView>.self, 0).text(0)
            .pathToRoot
        XCTAssertEqual(sut, "hStack().view(TestViewBuilderView.self, 0).text(0)")
    }
}

// MARK: - Test Views

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
private struct TestViewBuilderView<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding()
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension TestViewBuilderView: Inspectable { }
