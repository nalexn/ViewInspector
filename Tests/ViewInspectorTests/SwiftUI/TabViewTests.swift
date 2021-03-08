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
        XCTAssertEqual(sut.content.medium.viewModifiers.count, 2)
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
    
    func testSearch() throws {
        let view = AnyView(TabView {
            Text("abc").tabItem({ Text("xyz") })
        })
        XCTAssertEqual(try view.inspect().find(ViewType.TabView.self).pathToRoot,
                       "anyView().tabView()")
        XCTAssertEqual(try view.inspect().find(text: "abc").pathToRoot,
                       "anyView().tabView().text(0)")
        XCTAssertEqual(try view.inspect().find(text: "xyz").pathToRoot,
                       "anyView().tabView().text(0).tabItem().text()")
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
        let tabItem = try EmptyView().tabItem { Text(string).blur(radius: 3) }
            .inspect().emptyView().tabItem()
        let sut = try tabItem.text()
        XCTAssertEqual(try sut.string(), string)
        XCTAssertEqual(try sut.blur().radius, 3)
    }
    
    func testTabItemSearch() throws {
        let view = EmptyView().tabItem { Text("abc") }
        XCTAssertNoThrow(try view.inspect().find(text: "abc"))
    }
    
    #if !os(macOS) && !targetEnvironment(macCatalyst)
    func testTabViewStyleInspection() throws {
        guard #available(iOS 14, macOS 11.0, tvOS 14.0, *) else { return }
        let style = PageTabViewStyle(indexDisplayMode: .never)
        let view = EmptyView().tabViewStyle(style)
        let sut = try XCTUnwrap(try view.inspect().tabViewStyle() as? PageTabViewStyle)
        XCTAssertEqual(sut, style)
    }
    
    func testPageTabViewStyleEquatable() throws {
        guard #available(iOS 14, macOS 11.0, tvOS 14.0, *) else { return }
        let styles = [PageTabViewStyle(indexDisplayMode: .always),
                      PageTabViewStyle(indexDisplayMode: .automatic),
                      PageTabViewStyle(indexDisplayMode: .never)]
        (0..<styles.count).forEach { index in
            XCTAssertEqual(styles[index], styles[index])
            XCTAssertNotEqual(styles[index], styles[(index + 1) % styles.count])
        }
    }
    #endif
    
    @available(macOS, unavailable)
    func testIndexViewStyleInspection() throws {
        guard #available(iOS 14, tvOS 14, *) else { return }
        let sut = EmptyView().indexViewStyle(PageIndexViewStyle())
        XCTAssertTrue(try sut.inspect().indexViewStyle() is PageIndexViewStyle)
    }
}
