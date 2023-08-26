import XCTest
import SwiftUI
@testable import ViewInspector

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
final class ViewThatFitsTests: XCTestCase {
    
    func testSingleEnclosedView() throws {
        guard #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
        else { throw XCTSkip() }
        let view = ViewThatFits { Text("Test") }
        let sut = try view.inspect().viewThatFits().text(0).string()
        XCTAssertEqual(sut, "Test")
    }

    func testResetsModifiers() throws {
        guard #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
        else { throw XCTSkip() }
        let view = ViewThatFits { Text("Test") }.padding()
        let sut = try view.inspect().viewThatFits().text(0)
        XCTAssertEqual(sut.content.medium.viewModifiers.count, 0)
    }

    func testSingleEnclosedViewIndexOutOfBounds() throws {
        guard #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
        else { throw XCTSkip() }
        let view = ViewThatFits { Text("Test") }
        XCTAssertThrows(
            try view.inspect().viewThatFits().text(1),
            "Enclosed view index '1' is out of bounds: '0 ..< 1'")
    }

    func testMultipleEnclosedViews() throws {
        guard #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
        else { throw XCTSkip() }
        let sampleView1 = Text("Test")
        let sampleView2 = Text("Abc")
        let sampleView3 = Text("XYZ")
        let view = ViewThatFits { sampleView1; sampleView2; sampleView3 }
        let view1 = try view.inspect().viewThatFits().text(0).content.view as? Text
        let view2 = try view.inspect().viewThatFits().text(1).content.view as? Text
        let view3 = try view.inspect().viewThatFits().text(2).content.view as? Text
        XCTAssertEqual(view1, sampleView1)
        XCTAssertEqual(view2, sampleView2)
        XCTAssertEqual(view3, sampleView3)
    }

    func testMultipleEnclosedViewsIndexOutOfBounds() throws {
        guard #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
        else { throw XCTSkip() }
        let sampleView1 = Text("Test")
        let sampleView2 = Text("Abc")
        let view = ViewThatFits { sampleView1; sampleView2 }
        XCTAssertThrows(
            try view.inspect().viewThatFits().text(2),
            "Enclosed view index '2' is out of bounds: '0 ..< 2'")
    }

    func testExtractionFromSingleViewContainer() throws {
        guard #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
        else { throw XCTSkip() }
        let view = AnyView(ViewThatFits { Text("Test") })
        XCTAssertNoThrow(try view.inspect().anyView().viewThatFits())
    }

    func testExtractionFromMultipleViewContainer() throws {
        guard #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
        else { throw XCTSkip() }
        let view = VStack {
            ViewThatFits { Text("Test1") }
            ViewThatFits { Text("Test2") }
        }
        XCTAssertNoThrow(try view.inspect().vStack().viewThatFits(0))
        XCTAssertNoThrow(try view.inspect().vStack().viewThatFits(1))
    }

    func testSearch() throws {
        guard #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
        else { throw XCTSkip() }
        let view = AnyView(TestViewThatFits())
        XCTAssertEqual(try view.inspect().find(text: TestViewThatFits.longString).pathToRoot,
            "anyView().view(TestViewThatFits.self).viewThatFits().text(0)")
        XCTAssertEqual(try view.inspect().find(text: TestViewThatFits.shortString).pathToRoot,
            "anyView().view(TestViewThatFits.self).viewThatFits().anyView(1).text()")
    }
}

// MARK: - TestViewThatFits

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
private struct TestViewThatFits: View {
    
    static var longString: String {
        "Very long text that will only get picked if there is available space."
    }
    
    static var shortString: String {
        "Short text"
    }
    
    var body: some View {
        ViewThatFits {
            Text(Self.longString)
            AnyView(Text(Self.shortString))
        }
    }
}
