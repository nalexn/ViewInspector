import XCTest
import SwiftUI
@testable import ViewInspector

@available(iOS 15.0, macOS 12.0, *)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
final class ControlGroupTests: XCTestCase {

    func testSingleEnclosedView() throws {
        let sut = ControlGroup { Spacer() }
        XCTAssertNoThrow(try sut.inspect().controlGroup().spacer())
    }

    func testMultipleEnclosedViews() throws {
        let sut = ControlGroup { Spacer(); Divider() }
        XCTAssertNoThrow(try sut.inspect().controlGroup().spacer(0))
        XCTAssertNoThrow(try sut.inspect().controlGroup().divider(1))
    }

    func testSearch() throws {
        let sut = AnyView(ControlGroup { Spacer(); Divider() })
        XCTAssertEqual(try sut.inspect().find(ViewType.Spacer.self).pathToRoot,
                       "anyView().controlGroup().spacer(0)")
        XCTAssertEqual(try sut.inspect().find(ViewType.Divider.self).pathToRoot,
                       "anyView().controlGroup().divider(1)")
    }
    
    func testResetsModifiers() throws {
        let sut = ControlGroup { Spacer() }.padding()
        let view = try sut.inspect().controlGroup().spacer()
        XCTAssertEqual(view.content.medium.viewModifiers.count, 0)
    }

    func testExtractionFromSingleViewContainer() throws {
        let sut = AnyView(ControlGroup { Spacer() })
        XCTAssertNoThrow(try sut.inspect().anyView().controlGroup())
    }

    func testExtractionFromMultipleViewContainer() throws {
        let view = HStack {
            ControlGroup { Spacer() }
            ControlGroup { Divider() }
        }
        XCTAssertNoThrow(try view.inspect().hStack().controlGroup(0).spacer())
        XCTAssertNoThrow(try view.inspect().hStack().controlGroup(1).divider())
    }
}
