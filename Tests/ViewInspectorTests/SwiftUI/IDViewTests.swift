import XCTest
import SwiftUI
@testable import ViewInspector

final class IDViewTests: XCTestCase {
    
    func testEnclosedView() throws {
        let sampleView = Text("Test")
        let view = sampleView.id(0)
        let sut = try view.inspect().text().content.view as? Text
        XCTAssertEqual(sut, sampleView)
    }
    
    func testAccumulatesModifiers() throws {
        let view = Text("Test")
            .padding().id(0).padding().padding()
        let sut = try view.inspect().text()
        XCTAssertEqual(sut.content.modifiers.count, 4)
    }
    
    func testExtractionFromSingleViewContainer() throws {
        let view = AnyView(Text("").id(""))
        XCTAssertNoThrow(try view.inspect().text())
    }
    
    func testExtractionFromMultipleViewContainer() throws {
        let view = HStack {
            Text("").id(5)
            Text("").id("test")
        }
        XCTAssertNoThrow(try view.inspect().text(0))
        XCTAssertNoThrow(try view.inspect().text(1))
    }
    
    func testID() throws {
        let id = "abc"
        let sut = try EmptyView().id(id).inspect().emptyView().id()
        XCTAssertEqual(sut, id)
    }
}

// MARK: - View Modifiers

final class GlobalModifiersForIDView: XCTestCase {
    
    func testID() throws {
        let sut = EmptyView().id(5)
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
}
