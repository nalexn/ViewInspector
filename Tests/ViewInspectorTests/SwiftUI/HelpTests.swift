import XCTest
import SwiftUI
@testable import ViewInspector

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
final class HelpTests: XCTestCase {

    func testRetainsModifiers() throws {
        guard #available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
        else { throw XCTSkip() }
        let padding = EdgeInsets(top: 1, leading: 2, bottom: 3, trailing: 4)
        let offset = CGSize(width: 5, height: 6)
        let view = AnyView(EmptyView().padding(padding).help("test").offset(offset))
        let emptyView = try view.inspect().anyView().emptyView()
        XCTAssertEqual(try emptyView.padding(), padding)
        XCTAssertEqual(try emptyView.offset(), offset)
        let help = try emptyView.help()
        XCTAssertThrows(try help.offset(), "Text does not have 'offset' modifier")
    }

    func testTextInspectionPaths() throws {
        guard #available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
        else { throw XCTSkip() }
        let view = AnyView(EmptyView().padding().help("test"))
        let emptyView = try view.inspect().anyView().emptyView()
        let help = try emptyView.help()
        XCTAssertEqual(try help.string(), "test")
        XCTAssertEqual(help.pathToRoot, "anyView().emptyView().help()")
        XCTAssertEqual(try view.inspect().find(text: "test").pathToRoot,
                       "anyView().emptyView().help()")
    }
}
