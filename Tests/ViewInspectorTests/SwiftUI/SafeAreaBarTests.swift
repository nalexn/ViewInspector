import XCTest
import SwiftUI
@testable import ViewInspector

@MainActor
@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
final class SafeAreaBarTests: XCTestCase {

    func testInspectionNotBlocked() throws {
        guard #available(iOS 26.0, macOS 26.0, tvOS 26.0, visionOS 26.0, *)
        else { throw XCTSkip() }
        let sut = EmptyView().safeAreaBar(edge: VerticalEdge.top) { Text("") }
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }

    func testInspectionErrorNoModifier() throws {
        guard #available(iOS 26.0, macOS 26.0, tvOS 26.0, visionOS 26.0, *)
        else { throw XCTSkip() }
        let sut = EmptyView().offset()
        XCTAssertThrows(try sut.inspect().emptyView().safeAreaBar(),
                        "EmptyView does not have 'safeAreaBar' modifier")
    }

    func testSimpleUnwrap() throws {
        guard #available(iOS 26.0, macOS 26.0, tvOS 26.0, visionOS 26.0, *)
        else { throw XCTSkip() }
        let sut = EmptyView().safeAreaBar(edge: VerticalEdge.top) { Text("") }
        XCTAssertEqual(try sut.inspect().emptyView().safeAreaBar().pathToRoot,
                       "emptyView().safeAreaBar()")
    }

    func testContentUnwrap() throws {
        guard #available(iOS 26.0, macOS 26.0, tvOS 26.0, visionOS 26.0, *)
        else { throw XCTSkip() }
        let sut = EmptyView().safeAreaBar(edge: VerticalEdge.top) { Text("abc") }
        let text = try sut.inspect().safeAreaBar().text()
        XCTAssertEqual(try text.string(), "abc")
    }

    func testVerticalEdge() throws {
        guard #available(iOS 26.0, macOS 26.0, tvOS 26.0, visionOS 26.0, *)
        else { throw XCTSkip() }
        let sut = EmptyView().safeAreaBar(edge: VerticalEdge.bottom) { Text("") }
        XCTAssertEqual(try sut.inspect().safeAreaBar().edge(),
                       SafeAreaBarEdge.vertical(.bottom))
    }

    func testHorizontalEdge() throws {
        guard #available(iOS 26.0, macOS 26.0, tvOS 26.0, visionOS 26.0, *)
        else { throw XCTSkip() }
        let sut = EmptyView().safeAreaBar(edge: HorizontalEdge.leading) { Text("") }
        XCTAssertEqual(try sut.inspect().safeAreaBar().edge(),
                       SafeAreaBarEdge.horizontal(.leading))
    }

    func testAlignment() throws {
        guard #available(iOS 26.0, macOS 26.0, tvOS 26.0, visionOS 26.0, *)
        else { throw XCTSkip() }
        let sut1 = EmptyView().safeAreaBar(edge: VerticalEdge.bottom, alignment: .leading) {
            Text("")
        }
        let sut2 = EmptyView().safeAreaBar(edge: HorizontalEdge.leading, alignment: .top) {
            Text("")
        }
        XCTAssertEqual(try sut1.inspect().safeAreaBar().alignment(),
                       SafeAreaBarAlignment.horizontal(.leading))
        XCTAssertEqual(try sut2.inspect().safeAreaBar().alignment(),
                       SafeAreaBarAlignment.vertical(.top))
    }

    func testSpacing() throws {
        guard #available(iOS 26.0, macOS 26.0, tvOS 26.0, visionOS 26.0, *)
        else { throw XCTSkip() }
        let sut1 = EmptyView().safeAreaBar(edge: VerticalEdge.top, spacing: 19) { Text("") }
        let sut2 = EmptyView().safeAreaBar(edge: VerticalEdge.top) { Text("") }
        XCTAssertEqual(try sut1.inspect().safeAreaBar().spacing(), 19)
        XCTAssertEqual(try sut2.inspect().safeAreaBar().spacing(), 0)
    }

    func testSearch() throws {
        guard #available(iOS 26.0, macOS 26.0, tvOS 26.0, visionOS 26.0, *)
        else { throw XCTSkip() }
        let sut = Group {
            EmptyView()
            Text("")
                .safeAreaBar(edge: VerticalEdge.top) { EmptyView(); Text("1") }
                .padding()
                .safeAreaBar(edge: HorizontalEdge.leading) { Text("2") }
        }
        XCTAssertEqual(try sut.inspect().find(text: "1").pathToRoot,
                       "group().text(1).safeAreaBar().text(1)")
        XCTAssertEqual(try sut.inspect().find(text: "2").pathToRoot,
                       "group().text(1).safeAreaBar(1).text()")
    }
}
