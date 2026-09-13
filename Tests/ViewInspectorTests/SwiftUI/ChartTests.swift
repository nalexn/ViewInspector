#if canImport(Charts)
import XCTest
import SwiftUI
import Charts
@testable import ViewInspector

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
final class ChartTests: XCTestCase {

    // MARK: - Extraction from SingleViewContent

    @MainActor
    func testExtractionFromSingleViewContainer() throws {
        guard #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
        else { throw XCTSkip() }
        let view = AnyView(Chart { BarMark(x: .value("a", 1), y: .value("b", 2)) })
        XCTAssertNoThrow(try view.inspect().anyView().chart())
    }

    // MARK: - Extraction from MultipleViewContent

    @MainActor
    func testExtractionFromMultipleViewContainer() throws {
        guard #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
        else { throw XCTSkip() }
        let view = HStack {
            Chart { BarMark(x: .value("a", 1), y: .value("b", 2)) }
            Chart { BarMark(x: .value("a", 2), y: .value("b", 3)) }
        }
        XCTAssertNoThrow(try view.inspect().hStack().chart(0))
        XCTAssertNoThrow(try view.inspect().hStack().chart(1))
    }

    // MARK: - Search

    @MainActor
    func testSearch() throws {
        guard #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
        else { throw XCTSkip() }
        let view = HStack { Chart { BarMark(x: .value("a", 1), y: .value("b", 2)) } }
        XCTAssertEqual(try view.inspect().find(ViewType.Chart.self).pathToRoot,
                       "hStack().chart(0)")
    }

    /// The `Chart` internals require a real layout context, so the search must not
    /// descend into the chart's body.
    @MainActor
    func testSearchDoesNotDescendIntoChart() throws {
        guard #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
        else { throw XCTSkip() }
        let view = VStack {
            Chart {
                BarMark(x: .value("a", 1), y: .value("b", 2))
            }
            .chartXAxis(.hidden)
            .id("chart")
        }
        XCTAssertNoThrow(try view.inspect().find(viewWithId: "chart"))
        XCTAssertThrows(try view.inspect().find(viewWithId: "unknown"),
                        "Search did not find a match")
        XCTAssertThrows(try view.inspect().find(text: "a"),
                        "Search did not find a match")
    }

    // MARK: - Chart with Data

    @MainActor
    func testExtractionFromDataInit() throws {
        guard #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
        else { throw XCTSkip() }
        struct DataPoint: Identifiable {
            let id = UUID()
            let category: String
            let value: Double
        }
        let data = [
            DataPoint(category: "A", value: 100),
            DataPoint(category: "B", value: 200)
        ]
        let view = AnyView(Chart(data) { item in
            BarMark(
                x: .value("Category", item.category),
                y: .value("Value", item.value)
            )
        })
        XCTAssertNoThrow(try view.inspect().anyView().chart())
    }

    // MARK: - PathToRoot

    @MainActor
    func testPathToRoot() throws {
        guard #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
        else { throw XCTSkip() }
        let view = VStack {
            Text("Header")
            HStack {
                Chart { BarMark(x: .value("a", 1), y: .value("b", 2)) }
            }
        }
        let chart = try view.inspect().vStack().hStack(1).chart(0)
        XCTAssertEqual(chart.pathToRoot, "vStack().hStack(1).chart(0)")
    }
}
#endif
