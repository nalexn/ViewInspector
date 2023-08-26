import XCTest
import SwiftUI
@testable import ViewInspector

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
final class LabeledContentTests: XCTestCase {
    
    func testSingleEnclosedView() throws {
        guard #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
        else { throw XCTSkip() }
        let view = LabeledContent { Text("1") }
            label: { Label("2", image: "3") }
        let sut = try view.inspect().labeledContent().text(0).string()
        XCTAssertEqual(sut, "1")
    }
    
    func testSingleEnclosedViewIndexOutOfBounds() throws {
        guard #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
        else { throw XCTSkip() }
        let view = LabeledContent { Text("1") }
            label: { Label("2", image: "3") }
        XCTAssertThrows(
            try view.inspect().labeledContent().text(1),
            "Enclosed view index '1' is out of bounds: '0 ..< 1'")
    }
    
    func testMultipleEnclosedViews() throws {
        guard #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
        else { throw XCTSkip() }
        let view = LabeledContent { Text("1"); Text("2"); Text("3") }
            label: { Label("4", image: "5") }
        let sut = try view.inspect().labeledContent()
        let view1 = try sut.text(0).string()
        let view2 = try sut.text(1).string()
        let view3 = try sut.text(2).string()
        XCTAssertEqual(view1, "1")
        XCTAssertEqual(view2, "2")
        XCTAssertEqual(view3, "3")
    }
    
    func testMultipleEnclosedViewsIndexOutOfBounds() throws {
        guard #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
        else { throw XCTSkip() }
        let view = LabeledContent { Text("1"); Text("2") }
            label: { Label("3", image: "4") }
        XCTAssertThrows(
            try view.inspect().labeledContent().text(2),
            "Enclosed view index '2' is out of bounds: '0 ..< 2'")
    }
    
    func testResetsModifiers() throws {
        guard #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
        else { throw XCTSkip() }
        let view = LabeledContent { Text("1") }
            label: { Label("2", image: "3") }
            .padding()
        let sut = try view.inspect().labeledContent().text(0)
        XCTAssertEqual(sut.content.medium.viewModifiers.count, 0)
    }
    
    func testExtractionFromSingleViewContainer() throws {
        guard #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
        else { throw XCTSkip() }
        let view = AnyView(LabeledContent { Text("1") }
                           label: { Label("2", image: "3") })
        XCTAssertNoThrow(try view.inspect().anyView().labeledContent())
    }
    
    func testExtractionFromMultipleViewContainer() throws {
        guard #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
        else { throw XCTSkip() }
        let view = HStack {
            LabeledContent { Text("1") }
                label: { Label("2", image: "3") }
            LabeledContent { Text("1") }
                label: { Label("2", image: "3") }
        }
        XCTAssertNoThrow(try view.inspect().hStack().labeledContent(0))
        XCTAssertNoThrow(try view.inspect().hStack().labeledContent(1))
    }
    
    func testSearch() throws {
        guard #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
        else { throw XCTSkip() }
        let view = AnyView(LabeledContent { EmptyView(); AnyView(Text("1")) }
                           label: { Label("2", image: "3") })
        XCTAssertEqual(try view.inspect().find(text: "1").pathToRoot,
                       "anyView().labeledContent().anyView(1).text()")
        XCTAssertEqual(try view.inspect().find(text: "2").pathToRoot,
                       "anyView().labeledContent().labelView().label().title().text()")
    }
    
    func testLabelInspection() throws {
        guard #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
        else { throw XCTSkip() }
        let view = LabeledContent { Text("1") }
            label: { Label("2", image: "3") }
        let sut = try view.inspect().labeledContent().labelView().label().title().text().string()
        XCTAssertEqual(sut, "2")
    }
    
    func testLabelHidden() throws {
        guard #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
        else { throw XCTSkip() }
        let view = LabeledContent { Text("1") }
            label: { Label("2", image: "3") }
            .labelsHidden()
        let label = try view.inspect().labeledContent().labelView().label()
        XCTAssertTrue(label.isHidden())
        let text = try view.inspect().find(text: "2")
        XCTAssertTrue(text.labelsHidden())
        XCTAssertTrue(text.isHidden())
    }
}
