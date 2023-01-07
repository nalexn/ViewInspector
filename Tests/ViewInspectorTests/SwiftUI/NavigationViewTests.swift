import XCTest
import SwiftUI
@testable import ViewInspector

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 7.0, *)
final class NavigationViewTests: XCTestCase {
    
    func testSingleEnclosedView() throws {
        let sampleView = Text("Test")
        let view = NavigationView { sampleView }
        let sut = try view.inspect().navigationView().text(0).content.view as? Text
        XCTAssertEqual(sut, sampleView)
    }
    
    func testMultipleEnclosedViews() throws {
        let sampleView1 = Text("Test")
        let sampleView2 = Text("Abc")
        let sampleView3 = Text("XYZ")
        let view = NavigationView { sampleView1; sampleView2; sampleView3 }
        let view1 = try view.inspect().navigationView().text(0).content.view as? Text
        let view2 = try view.inspect().navigationView().text(1).content.view as? Text
        let view3 = try view.inspect().navigationView().text(2).content.view as? Text
        XCTAssertEqual(view1, sampleView1)
        XCTAssertEqual(view2, sampleView2)
        XCTAssertEqual(view3, sampleView3)
    }
    
    func testResetsModifiers() throws {
        let view = NavigationView { Text("Test") }.padding()
        let sut = try view.inspect().navigationView().text(0)
        XCTAssertEqual(sut.content.medium.viewModifiers.count, 0)
    }
    
    func testExtractionFromSingleViewContainer() throws {
        let view = AnyView(NavigationView { Text("") })
        XCTAssertNoThrow(try view.inspect().anyView().navigationView())
    }
    
    func testExtractionFromMultipleViewContainer() throws {
        let view = HStack {
            NavigationView { Text("") }
            NavigationView { Text("") }
        }
        XCTAssertNoThrow(try view.inspect().hStack().navigationView(0))
        XCTAssertNoThrow(try view.inspect().hStack().navigationView(1))
    }
    
    func testSearch() throws {
        let view = AnyView(NavigationView { Text("abc") })
        XCTAssertEqual(try view.inspect().find(ViewType.NavigationView.self).pathToRoot,
                       "anyView().navigationView()")
        XCTAssertEqual(try view.inspect().find(text: "abc").pathToRoot,
                       "anyView().navigationView().text(0)")
    }
}
