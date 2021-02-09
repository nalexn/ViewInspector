import XCTest
import SwiftUI
@testable import ViewInspector

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
final class EmptyViewTests: XCTestCase {
    
    func testInspect() throws {
        XCTAssertNoThrow(try EmptyView().inspect())
    }
    
    func testExtractionFromSingleViewContainer() throws {
        let view = AnyView(EmptyView())
        XCTAssertNoThrow(try view.inspect().anyView().emptyView())
    }
    
    func testExtractionFromMultipleViewContainer() throws {
        let view = HStack {
            Text("")
            EmptyView()
            Text("")
            EmptyView()
        }
        XCTAssertNoThrow(try view.inspect().hStack().emptyView(1))
        XCTAssertNoThrow(try view.inspect().hStack().emptyView(3))
    }
    
    func testSearch() throws {
        let view = AnyView(EmptyView())
        XCTAssertEqual(try view.inspect().find(ViewType.EmptyView.self).pathToRoot,
                       "anyView().emptyView()")
    }
}
