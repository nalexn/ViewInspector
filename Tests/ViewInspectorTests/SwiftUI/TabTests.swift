import XCTest
import SwiftUI
@testable import ViewInspector

@MainActor
@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
final class TabTests: XCTestCase {

    // MARK: - TabView with Tabs Count

    func testTabViewWithTabsReturnsCorrectCount() throws {
        let sut = TabView {
            Tab("Received", systemImage: "tray.and.arrow.down.fill") {
                Text("ReceivedView")
            }
            Tab("Sent", systemImage: "tray.and.arrow.up.fill") {
                Text("SentView")
            }
            Tab("Account", systemImage: "person.crop.circle.fill") {
                Text("AccountView")
            }
        }

        let tabView = try sut.inspect().tabView()
        XCTAssertEqual(tabView.count, 3)
    }

    // MARK: - Tab Extraction

    func testTabExtractionFromTabView() throws {
        let sut = TabView {
            Tab("First", systemImage: "1.circle") {
                Text("First Content")
            }
            Tab("Second", systemImage: "2.circle") {
                Text("Second Content")
            }
        }

        XCTAssertNoThrow(try sut.inspect().tabView().tab(0))
        XCTAssertNoThrow(try sut.inspect().tabView().tab(1))
    }

    func testTabExtractionFromAnyView() throws {
        // Tab is not a View - it's a TabContent, so it can only be inside TabView
        // This test verifies tab extraction from a TabView wrapped in AnyView
        let sut = AnyView(
            TabView {
                Tab("Test", systemImage: "star") {
                    Text("Content")
                }
            }
        )
        XCTAssertNoThrow(try sut.inspect().anyView().tabView().tab(0))
    }

    // MARK: - Tab Content Inspection

    func testTabContentInspection() throws {
        let sut = TabView {
            Tab("First", systemImage: "1.circle") {
                Text("First Content")
            }
            Tab("Second", systemImage: "2.circle") {
                Text("Second Content")
            }
            Tab("Third", systemImage: "3.circle") {
                Text("Third Content")
            }
        }

        XCTAssertEqual(try sut.inspect().tabView().tab(0).text().string(), "First Content")
        XCTAssertEqual(try sut.inspect().tabView().tab(1).text().string(), "Second Content")
        XCTAssertEqual(try sut.inspect().tabView().tab(2).text().string(), "Third Content")
    }

    func testTabWithComplexContent() throws {
        let sut = TabView {
            Tab("Complex", systemImage: "star") {
                VStack {
                    Text("Title")
                    Button("Action") { }
                }
            }
        }

        let tab = try sut.inspect().tabView().tab(0)
        let vStack = try tab.vStack()
        XCTAssertEqual(try vStack.text(0).string(), "Title")
        XCTAssertNoThrow(try vStack.button(1))
    }

    // MARK: - Tab Label Inspection

    func testTabLabelViewInspection() throws {
        let sut = TabView {
            Tab("My Tab", systemImage: "star.fill") {
                Text("Content")
            }
        }

        let label = try sut.inspect().tabView().tab(0).labelView()
        // The label is a Label<Text, Image>
        XCTAssertEqual(try label.label().title().text().string(), "My Tab")
        XCTAssertNoThrow(try label.label().icon().image())
    }

    // MARK: - Tab Role

    func testTabRoleNil() throws {
        let sut = TabView {
            Tab("Test", systemImage: "star") {
                Text("Content")
            }
        }

        let role = try sut.inspect().tabView().tab(0).role()
        XCTAssertNil(role)
    }

    func testTabRoleSearch() throws {
        let sut = TabView {
            Tab("Search", systemImage: "magnifyingglass", role: .search) {
                Text("Search Content")
            }
        }

        let role = try sut.inspect().tabView().tab(0).role()
        XCTAssertEqual(role, .search)
    }

    // MARK: - Search Tests

    func testSearchForTabContent() throws {
        let sut = TabView {
            Tab("First", systemImage: "1.circle") {
                Text("FindMe")
            }
            Tab("Second", systemImage: "2.circle") {
                Text("Other")
            }
        }

        XCTAssertEqual(
            try sut.inspect().find(text: "FindMe").pathToRoot,
            "tabView().tab(0).text()")
    }

    func testSearchForTabInHierarchy() throws {
        let sut = VStack {
            TabView {
                Tab("First", systemImage: "1.circle") {
                    Text("Tab Content")
                }
            }
        }

        XCTAssertEqual(
            try sut.inspect().find(ViewType.Tab.self).pathToRoot,
            "vStack().tabView(0).tab(0)")
    }

    // MARK: - Traditional TabView still works

    func testTraditionalTabViewStillWorks() throws {
        let sut = TabView {
            Text("First")
                .tabItem { Label("First", systemImage: "1.circle") }
            Text("Second")
                .tabItem { Label("Second", systemImage: "2.circle") }
        }

        let tabView = try sut.inspect().tabView()
        XCTAssertEqual(tabView.count, 2)
        XCTAssertEqual(try tabView.text(0).string(), "First")
        XCTAssertEqual(try tabView.text(1).string(), "Second")
    }
}
