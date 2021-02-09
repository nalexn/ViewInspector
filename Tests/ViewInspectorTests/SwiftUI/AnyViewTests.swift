import XCTest
import SwiftUI
@testable import ViewInspector

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
final class AnyViewTests: XCTestCase {
    
    func testEnclosedView() throws {
        let sampleView = Text("Test")
        let view = AnyView(sampleView)
        let sut = try view.inspect().anyView().text().content.view as? Text
        XCTAssertEqual(sut, sampleView)
    }
    
    func testResetsModifiers() throws {
        let view = AnyView(Text("")).padding()
        let sut = try view.inspect().anyView().text()
        XCTAssertEqual(sut.content.modifiers.count, 0)
    }
    
    func testExtractionFromSingleViewContainer() throws {
        let view = Button(action: { }, label: { AnyView(Text("")) })
        XCTAssertNoThrow(try view.inspect().button().labelView().anyView())
    }
    
    func testExtractionFromMultipleViewContainer() throws {
        let view = HStack {
            AnyView(Text(""))
            AnyView(Text(""))
        }
        XCTAssertNoThrow(try view.inspect().hStack().anyView(0))
        XCTAssertNoThrow(try view.inspect().hStack().anyView(1))
    }
    
    func testSearch() throws {
        let view = Group { AnyView(EmptyView()) }
        XCTAssertEqual(try view.inspect().find(ViewType.AnyView.self).pathToRoot,
                       "group().anyView(0)")
        XCTAssertEqual(try view.inspect().find(ViewType.EmptyView.self).pathToRoot,
                       "group().anyView(0).emptyView()")
    }
}
