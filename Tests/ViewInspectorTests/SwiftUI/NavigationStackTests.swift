import XCTest
import SwiftUI
@testable import ViewInspector

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 7.0, *)
final class NavigationStackTests: XCTestCase {
    
    func testSingleEnclosedView() throws {
        guard #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
        else { throw XCTSkip() }
        let sampleView = Text("Test")
        let view = NavigationStack { sampleView }
        let sut = try view.inspect().navigationStack().text().content.view as? Text
        XCTAssertEqual(sut, sampleView)
    }
    
    func testMultipleEnclosedViews() throws {
        guard #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
        else { throw XCTSkip() }
        let sampleView1 = Text("Test")
        let sampleView2 = Text("Abc")
        let sampleView3 = Text("XYZ")
        let view = NavigationStack { sampleView1; sampleView2; sampleView3 }
        let view1 = try view.inspect().navigationStack().text().content.view as? Text
        let view2 = try view.inspect().navigationStack().text(1).content.view as? Text
        let view3 = try view.inspect().navigationStack().text(2).content.view as? Text
        XCTAssertEqual(view1, sampleView1)
        XCTAssertEqual(view2, sampleView2)
        XCTAssertEqual(view3, sampleView3)
    }
    
    func testResetsModifiers() throws {
        guard #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
        else { throw XCTSkip() }
        let view = NavigationStack { Text("Test") }.padding()
        let sut = try view.inspect().navigationStack().text()
        XCTAssertEqual(sut.content.medium.viewModifiers.count, 0)
    }
    
    func testExtractionFromSingleViewContainer() throws {
        guard #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
        else { throw XCTSkip() }
        let view = AnyView(NavigationStack { Text("") })
        XCTAssertNoThrow(try view.inspect().anyView().navigationStack())
    }
    
    func testExtractionFromMultipleViewContainer() throws {
        guard #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
        else { throw XCTSkip() }
        let view = HStack {
            NavigationStack { Text("") }
            NavigationStack { Text("") }
        }
        XCTAssertNoThrow(try view.inspect().hStack().navigationStack(0))
        XCTAssertNoThrow(try view.inspect().hStack().navigationStack(1))
    }
    
    func testSearch() throws {
        guard #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
        else { throw XCTSkip() }
        let view = AnyView(NavigationStack { Text("abc") })
        XCTAssertEqual(try view.inspect().find(ViewType.NavigationStack.self).pathToRoot,
                       "anyView().navigationStack()")
        XCTAssertEqual(try view.inspect().find(text: "abc").pathToRoot,
                       "anyView().navigationStack().text()")
    }
}
