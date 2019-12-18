import XCTest
import SwiftUI
@testable import ViewInspector

final class ModifiedContentTests: XCTestCase {
    
    func testEnclosedView() throws {
        let sampleView = Text("Test")
        let view = ModifiedContent(content: sampleView, modifier: TestModifier())
        let sut = try view.inspect().text().content.view as? Text
        XCTAssertEqual(sut, sampleView)
    }
    
    func testAccumulatesModifiers() throws {
        let view = ModifiedContent(content: Text("Test").padding(),
                                   modifier: TestModifier())
            .padding().padding()
        let sut = try view.inspect().text()
        XCTAssertEqual(sut.content.modifiers.count, 4)
    }
    
    func testExtractionFromSingleViewContainer() throws {
        let view = AnyView(ModifiedContent(content: Text("Test"),
                                           modifier: TestModifier()))
        XCTAssertEqual(try view.inspect().text().content.modifiers.count, 1)
    }
    
    func testExtractionFromMultipleViewContainer() throws {
        let view = HStack {
            ModifiedContent(content: Text("Test"), modifier: TestModifier())
            ModifiedContent(content: Text("Test"), modifier: TestModifier())
        }
        XCTAssertEqual(try view.inspect().text(0).content.modifiers.count, 1)
        XCTAssertEqual(try view.inspect().text(1).content.modifiers.count, 1)
    }
}

private struct TestModifier: ViewModifier {
    func body(content: Self.Content) -> some View {
        content
    }
}

// MARK: - View Modifiers

final class GlobalModifiersForModifiedContent: XCTestCase {
    
    func testModifier() throws {
        let sut = EmptyView().modifier(TestModifier())
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
}
