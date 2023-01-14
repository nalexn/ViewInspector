import XCTest
import SwiftUI
@testable import ViewInspector

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 7.0, *)
final class NavigationSplitViewTests: XCTestCase {
    
    func testSingleEnclosedView() throws {
        guard #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
        else { throw XCTSkip() }
        let view = NavigationSplitView(sidebar: { Text("1") },
                                       content: { Text("2") },
                                       detail: { Text("3") })
        let sut = try view.inspect().navigationSplitView()
        let content = try sut.text().string()
        let sidebar = try sut.sidebarView().text().string()
        let detail = try sut.detailView().text().string()
        XCTAssertEqual(sidebar, "1")
        XCTAssertEqual(content, "2")
        XCTAssertEqual(detail, "3")
    }
    
    func testMultipleEnclosedViews() throws {
        guard #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
        else { throw XCTSkip() }
        let view = NavigationSplitView(sidebar: { Text("1"); Text("11") },
                                       content: { Text("2"); Text("22") },
                                       detail: { Text("3"); Text("33") })
        let sut = try view.inspect().navigationSplitView()
        let content1 = try sut.text().string()
        let content2 = try sut.text(1).string()
        let sidebar1 = try sut.sidebarView().text(0).string()
        let sidebar2 = try sut.sidebarView().text(1).string()
        let detail1 = try sut.detailView().text(0).string()
        let detail2 = try sut.detailView().text(1).string()
        XCTAssertEqual(sidebar1, "1")
        XCTAssertEqual(sidebar2, "11")
        XCTAssertEqual(content1, "2")
        XCTAssertEqual(content2, "22")
        XCTAssertEqual(detail1, "3")
        XCTAssertEqual(detail2, "33")
    }
    
    func testResetsModifiers() throws {
        guard #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
        else { throw XCTSkip() }
        let view = NavigationSplitView(
            sidebar: { Text("1") }, content: { Text("2") }, detail: { Text("3") })
            .padding()
        let sut = try view.inspect().navigationSplitView()
        let content = try sut.text()
        let sidebar = try sut.sidebarView().text()
        let detail = try sut.detailView().text()
        XCTAssertEqual(content.content.medium.viewModifiers.count, 0)
        XCTAssertEqual(sidebar.content.medium.viewModifiers.count, 0)
        XCTAssertEqual(detail.content.medium.viewModifiers.count, 0)
    }
    
    func testExtractionFromSingleViewContainer() throws {
        guard #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
        else { throw XCTSkip() }
        let view = AnyView(NavigationSplitView(sidebar: { EmptyView() }, detail: { EmptyView() }))
        XCTAssertNoThrow(try view.inspect().anyView().navigationSplitView())
    }
    
    func testExtractionFromMultipleViewContainer() throws {
        guard #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
        else { throw XCTSkip() }
        let view = HStack {
            NavigationSplitView(sidebar: { EmptyView() }, detail: { EmptyView() })
            NavigationSplitView(sidebar: { EmptyView() }, detail: { EmptyView() })
        }
        XCTAssertNoThrow(try view.inspect().hStack().navigationSplitView(0))
        XCTAssertNoThrow(try view.inspect().hStack().navigationSplitView(1))
    }
    
    func testSearch() throws {
        guard #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
        else { throw XCTSkip() }
        let view = AnyView(NavigationSplitView(
            sidebar: { Text("1") },
            content: { Text("2"); Text("22") },
            detail: { Text("3"); Text("33") })
        )
        let sut = try view.inspect()
        XCTAssertEqual(try sut.find(ViewType.NavigationSplitView.self).pathToRoot,
                       "anyView().navigationSplitView()")
        XCTAssertEqual(try sut.find(text: "1").pathToRoot,
                       "anyView().navigationSplitView().sidebarView().text()")
        XCTAssertEqual(try sut.find(text: "2").pathToRoot,
                       "anyView().navigationSplitView().text(0)")
        XCTAssertEqual(try sut.find(text: "22").pathToRoot,
                       "anyView().navigationSplitView().text(1)")
        XCTAssertEqual(try sut.find(text: "3").pathToRoot,
                       "anyView().navigationSplitView().detailView().text(0)")
        XCTAssertEqual(try sut.find(text: "33").pathToRoot,
                       "anyView().navigationSplitView().detailView().text(1)")
    }
}
