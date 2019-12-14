import XCTest
import SwiftUI
@testable import ViewInspector

#if !os(watchOS)

final class TabViewTests: XCTestCase {
    
    func testEnclosedView() throws {
        let view = TabView {
            Text("First View").tabItem({ Text("First") }).tag(0)
            Text("Second View").tabItem({ Text("Second") }).tag(1)
        }
        let text = try view.inspect().text(0).string()
        XCTAssertEqual(text, "First View")
    }
    
    func testResetsModifiers() throws {
        let view = TabView {
            Text("First View").tabItem({ Text("First") }).tag(0)
            Text("Second View").tabItem({ Text("Second") }).tag(1)
        }.padding().padding().padding()
        let sut = try view.inspect().tabView().text(0)
        XCTAssertEqual(sut.content.modifiers.count, 2)
    }
    
    func testExtractionFromSingleViewContainer() throws {
        let tabView = TabView {
            Text("First View").tabItem({ Text("First") }).tag(0)
            Text("Second View").tabItem({ Text("Second") }).tag(1)
        }
        let view = AnyView(tabView)
        XCTAssertNoThrow(try view.inspect().tabView())
    }
    
    func testExtractionFromMultipleViewContainer() throws {
        let tabView = TabView {
            Text("First View").tabItem({ Text("First") }).tag(0)
            Text("Second View").tabItem({ Text("Second") }).tag(1)
        }
        let view = HStack { tabView; tabView }
        XCTAssertNoThrow(try view.inspect().tabView(0))
        XCTAssertNoThrow(try view.inspect().tabView(1))
    }
}

#endif
