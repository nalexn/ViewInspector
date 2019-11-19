import XCTest
import SwiftUI
@testable import ViewInspector

#if !os(watchOS)

final class ModifiedContentTests: XCTestCase {
    
    func testEnclosedView() throws {
        let sampleView = Text("Test")
        let view = ModifiedContent(content: sampleView, modifier: TestModifier())
        let sut = try view.inspect().text().view as? Text
        XCTAssertEqual(sut, sampleView)
    }
    
    func testExtractionFromSingleViewContainer() throws {
        let view = AnyView(ModifiedContent(content: Text("Test"),
                                           modifier: TestModifier()))
        XCTAssertNoThrow(try view.inspect().text())
    }
    
    func testExtractionFromMultipleViewContainer() throws {
        let view = HStack {
            ModifiedContent(content: Text("Test"), modifier: TestModifier())
            ModifiedContent(content: Text("Test"), modifier: TestModifier())
        }
        XCTAssertNoThrow(try view.inspect().text(0))
        XCTAssertNoThrow(try view.inspect().text(1))
    }
}

private struct TestModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
    }
}

#endif
