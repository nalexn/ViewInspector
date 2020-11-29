import XCTest
import SwiftUI
@testable import ViewInspector

@available(iOS 13.0, macOS 10.15, *)
@available(tvOS, unavailable)
final class GroupBoxTests: XCTestCase {
    
    func testSingleEnclosedView() throws {
        guard #available(iOS 14, *) else { return }
        let sampleView = Text("Test")
        let view = GroupBox { sampleView }
        let sut = try view.inspect().groupBox().text(0).content.view as? Text
        XCTAssertEqual(sut, sampleView)
    }
    
    func testSingleEnclosedViewIndexOutOfBounds() throws {
        guard #available(iOS 14, *) else { return }
        let sampleView = Text("Test")
        let view = GroupBox { sampleView }
        XCTAssertThrows(
            try view.inspect().groupBox().text(1),
            "Enclosed view index '1' is out of bounds: '0 ..< 1'")
    }
    
    func testMultipleEnclosedViews() throws {
        guard #available(iOS 14, *) else { return }
        let sampleView1 = Text("Test")
        let sampleView2 = Text("Abc")
        let sampleView3 = Text("XYZ")
        let view = GroupBox { sampleView1; sampleView2; sampleView3 }
        let view1 = try view.inspect().groupBox().text(0).content.view as? Text
        let view2 = try view.inspect().groupBox().text(1).content.view as? Text
        let view3 = try view.inspect().groupBox().text(2).content.view as? Text
        XCTAssertEqual(view1, sampleView1)
        XCTAssertEqual(view2, sampleView2)
        XCTAssertEqual(view3, sampleView3)
    }
    
    func testMultipleEnclosedViewsIndexOutOfBounds() throws {
        guard #available(iOS 14, *) else { return }
        let sampleView1 = Text("Test")
        let sampleView2 = Text("Abc")
        let view = GroupBox { sampleView1; sampleView2 }
        XCTAssertThrows(
            try view.inspect().groupBox().text(2),
            "Enclosed view index '2' is out of bounds: '0 ..< 2'")
    }
    
    func testResetsModifiers() throws {
        guard #available(iOS 14, *) else { return }
        let view = GroupBox { Text("Test") }.padding()
        let sut = try view.inspect().groupBox().text(0)
        XCTAssertEqual(sut.content.modifiers.count, 0)
    }
    
    func testExtractionFromSingleViewContainer() throws {
        guard #available(iOS 14, *) else { return }
        let view = AnyView(GroupBox { Text("Test") })
        XCTAssertNoThrow(try view.inspect().anyView().groupBox())
    }
    
    func testExtractionFromMultipleViewContainer() throws {
        guard #available(iOS 14, *) else { return }
        let view = GroupBox {
            GroupBox { Text("Test") }
            GroupBox { Text("Test") }
        }
        XCTAssertNoThrow(try view.inspect().groupBox().groupBox(0))
        XCTAssertNoThrow(try view.inspect().groupBox().groupBox(1))
    }
    
    func testLabelInspection() throws {
        guard #available(iOS 14, *) else { return }
        let view = GroupBox(
            label: HStack { Text("abc") },
            content: { Text("test") })
        let sut = try view.inspect().groupBox().labelView().hStack().text(0).string()
        XCTAssertEqual(sut, "abc")
    }
    
    #if !os(macOS) && !targetEnvironment(macCatalyst)
    func testGroupBoxStyleInspection() throws {
        guard #available(iOS 14, *) else { return }
        let sut = EmptyView().groupBoxStyle(DefaultGroupBoxStyle())
        XCTAssertTrue(try sut.inspect().groupBoxStyle() is DefaultGroupBoxStyle)
    }
    
    func testCustomGroupBoxStyleInspection() throws {
        guard #available(iOS 14, *) else { return }
        let sut = TestGroupBoxStyle()
        XCTAssertEqual(try sut.inspect().vStack().styleConfigurationContent(0).blur().radius, 5)
        XCTAssertEqual(try sut.inspect().vStack().styleConfigurationLabel(1).brightness(), 3)
        XCTAssertThrows(try EmptyView().inspect().styleConfigurationContent(),
            "inspect().styleConfigurationContent() found EmptyView instead of Content")
    }
    #endif
}

@available(iOS 14.0, macOS 11.0, *)
@available(tvOS, unavailable)
private struct TestGroupBoxStyle: GroupBoxStyle {
    func makeBody(configuration: Configuration) -> some View {
        VStack {
            configuration.content
                .blur(radius: 5)
            configuration.label
                .brightness(3)
        }
    }
}
