import XCTest
import Combine
import SwiftUI

@testable import ViewInspector

final class CustomViewBuilderTests: XCTestCase {
    
    func testSingleEnclosedView() throws {
        let sut = TestViewBuilderView { Text("Test") }
        let string = try sut.inspect().viewBuilder().text(0).string()
        XCTAssertEqual(string, "Test")
    }
    
    func testSingleEnclosedViewIndexOutOfBounds() throws {
        let sut = TestViewBuilderView { Text("Test") }
        XCTAssertThrows(
            try sut.inspect().viewBuilder().text(1),
            "Enclosed view index '1' is out of bounds: '0 ..< 1'")
    }
    
    func testMultipleEnclosedViews() throws {
        let sampleView1 = Text("Test")
        let sampleView2 = Text("Abc")
        let sampleView3 = Text("XYZ")
        let view = TestViewBuilderView { sampleView1; sampleView2; sampleView3 }
        let view1 = try view.inspect().viewBuilder().text(0).content.view as? Text
        let view2 = try view.inspect().viewBuilder().text(1).content.view as? Text
        let view3 = try view.inspect().viewBuilder().text(2).content.view as? Text
        XCTAssertEqual(view1, sampleView1)
        XCTAssertEqual(view2, sampleView2)
        XCTAssertEqual(view3, sampleView3)
    }
    
    func testMultipleEnclosedViewsIndexOutOfBounds() throws {
        let sampleView1 = Text("Test")
        let sampleView2 = Text("Abc")
        let view = TestViewBuilderView { sampleView1; sampleView2 }
        XCTAssertThrows(
            try view.inspect().viewBuilder().text(2),
            "Enclosed view index '2' is out of bounds: '0 ..< 2'")
    }
    
    func testResetsModifiers() throws {
        let view = TestViewBuilderView { Text("Test") }.padding()
        let sut = try view.inspect().view(TestViewBuilderView<Text>.self).viewBuilder().text(0)
        XCTAssertEqual(sut.content.modifiers.count, 0)
    }
    
    func testExtractionFromSingleViewContainer() throws {
        let view = AnyView(TestViewBuilderView { Text("Test") })
        XCTAssertNoThrow(try view.inspect().anyView()
            .view(TestViewBuilderView<Text>.self).viewBuilder().text(0))
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
        XCTAssertNoThrow(try sut.inspect().viewBuilder().actualView().content)
    }
    
    func testViewBody() {
        XCTAssertNoThrow(TestViewBuilderView { Text("Test") }.body)
    }
}

// MARK: - Test Views

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

extension TestViewBuilderView: Inspectable { }
