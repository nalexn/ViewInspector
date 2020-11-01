import XCTest
import SwiftUI
@testable import ViewInspector

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
    
    #if !os(macOS)
    @available(iOS 14.0, macOS 11.0, tvOS 14.0, *)
    func testTabViewStyleInspection() throws {
        let style = PageTabViewStyle(indexDisplayMode: .never)
        let view = EmptyView().tabViewStyle(style)
        let sut = try XCTUnwrap(try view.inspect().tabViewStyle() as? PageTabViewStyle)
        XCTAssertEqual(sut, style)
    }
    
    @available(iOS 14.0, macOS 11.0, tvOS 14.0, *)
    func testPageTabViewStyleEquatable() throws {
        let styles = [PageTabViewStyle(indexDisplayMode: .always),
                      PageTabViewStyle(indexDisplayMode: .automatic),
                      PageTabViewStyle(indexDisplayMode: .never)]
        (0..<styles.count).forEach { index in
            XCTAssertEqual(styles[index], styles[index])
            XCTAssertNotEqual(styles[index], styles[(index + 1) % styles.count])
        }
    }
    
    @available(iOS 14.0, tvOS 14.0, *)
    @available(macOS, unavailable)
    func testIndexViewStyleInspection() throws {
        let sut = EmptyView().indexViewStyle(PageIndexViewStyle())
        XCTAssertTrue(try sut.inspect().indexViewStyle() is PageIndexViewStyle)
    }
    #endif
}
