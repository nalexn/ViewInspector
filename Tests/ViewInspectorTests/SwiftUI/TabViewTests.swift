import XCTest
import SwiftUI
@testable import ViewInspector

#if !os(watchOS)

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
final class TabViewTests: XCTestCase {
    
    func testEnclosedView() throws {
        let view = TabView {
            Text("First View").tabItem({ Text("First") }).tag(0)
            Text("Second View").tabItem({ Text("Second") }).tag(1)
        }
        let text = try view.inspect().tabView().text(0).string()
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
        XCTAssertNoThrow(try view.inspect().anyView().tabView())
    }
    
    func testExtractionFromMultipleViewContainer() throws {
        let tabView = TabView {
            Text("First View").tabItem({ Text("First") }).tag(0)
            Text("Second View").tabItem({ Text("Second") }).tag(1)
        }
        let view = HStack { tabView; tabView }
        XCTAssertNoThrow(try view.inspect().hStack().tabView(0))
        XCTAssertNoThrow(try view.inspect().hStack().tabView(1))
    }
}

#endif

// MARK: - View Modifiers

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
final class GlobalModifiersForTabView: XCTestCase {
    
    func testTag() throws {
        let sut = EmptyView().tag(0)
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testTagInspection() throws {
        let tag = "abc"
        let sut = try EmptyView().tag(tag).inspect().emptyView().tag()
        XCTAssertEqual(sut, tag)
    }
    
    #if !os(watchOS)
    func testTabItem() throws {
        let sut = EmptyView().tabItem { Text("") }
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testTabItemInspection() throws {
        let string = "abc"
        let tabItem = try EmptyView().tabItem { Text(string) }
            .inspect().emptyView().tabItem()
        let sut = try tabItem.text().string()
        XCTAssertEqual(sut, string)
    }
    #endif
}
