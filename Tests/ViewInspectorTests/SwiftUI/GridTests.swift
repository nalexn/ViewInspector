import XCTest
import SwiftUI
@testable import ViewInspector

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
final class GridTests: XCTestCase {
    
    func testInspect() throws {
        guard #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
        else { throw XCTSkip() }
        let view = Grid {
            GridRow { Text("1"); Text("2") }
            GridRow { Text("3"); Text("4") }
        }
        let grid = try view.inspect().grid()
        XCTAssertEqual(try grid.gridRow(0).text(1).string(), "2")
        XCTAssertEqual(try grid.gridRow(1).text(0).string(), "3")
    }
    
    func testExtractionFromSingleViewContainer() throws {
        guard #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
        else { throw XCTSkip() }
        let view1 = AnyView(Grid { GridRow { EmptyView() } })
        XCTAssertNoThrow(try view1.inspect().anyView().grid().gridRow(0))
        let view2 = AnyView(GridRow { EmptyView() })
        XCTAssertNoThrow(try view2.inspect().anyView().gridRow())
    }

    func testExtractionFromMultipleViewContainer() throws {
        guard #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
        else { throw XCTSkip() }
        let view = HStack {
            Text("")
            Grid { GridRow { EmptyView() } }
            Text("")
        }
        XCTAssertNoThrow(try view.inspect().hStack().grid(1).gridRow(0))
    }

    func testSearch() throws {
        guard #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
        else { throw XCTSkip() }
        let view = HStack { Grid {
            GridRow { AnyView(Text("1")) }
            EmptyView()
            AnyView(GridRow { EmptyView(); HStack { Text("2") } })
        } }
        XCTAssertEqual(try view.inspect().find(text: "1").pathToRoot,
                       "hStack().grid(0).gridRow(0).anyView(0).text()")
        XCTAssertEqual(try view.inspect().find(text: "2").pathToRoot,
                       "hStack().grid(0).anyView(2).gridRow().hStack(1).text(0)")
    }

    func testGridAlignmentInspection() throws {
        guard #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
        else { throw XCTSkip() }
        let view = Grid(alignment: .bottomTrailing) { GridRow { EmptyView() } }
        let sut = try view.inspect().grid().alignment()
        XCTAssertEqual(sut, .bottomTrailing)
    }
    
    func testHorizontalSpacing() throws {
        guard #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
        else { throw XCTSkip() }
        let view = Grid(horizontalSpacing: 4) { GridRow { EmptyView() } }
        let sut = try view.inspect().grid().horizontalSpacing()
        XCTAssertEqual(sut, 4)
    }
    
    func testVerticalSpacing() throws {
        guard #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
        else { throw XCTSkip() }
        let view = Grid(verticalSpacing: 4) { GridRow { EmptyView() } }
        let sut = try view.inspect().grid().verticalSpacing()
        XCTAssertEqual(sut, 4)
    }
    
    func testGridRowAlignmentInspection() throws {
        guard #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
        else { throw XCTSkip() }
        let view = Grid() { GridRow(alignment: .bottom) { EmptyView() } }
        let sut = try view.inspect().grid().gridRow(0).alignment()
        XCTAssertEqual(sut, .bottom)
    }
}
