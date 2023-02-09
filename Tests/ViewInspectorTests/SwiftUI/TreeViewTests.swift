import XCTest
import SwiftUI
@testable import ViewInspector

@available(iOS 13.0, macOS 10.15, *)
@available(tvOS, unavailable)
final class TreeViewTests: XCTestCase {
    
    @available(watchOS, deprecated: 7.0)
    func testEnclosedView() throws {
        let sut = Text("Test").contextMenu(menuItems: { Text("Menu") })
        let text = try sut.inspect().text().string()
        XCTAssertEqual(text, "Test")
    }
    
    @available(watchOS, deprecated: 7.0)
    func testRetainsModifiers() throws {
        let view = Text("Test")
            .padding()
            .contextMenu(menuItems: { Text("Menu") })
            .padding().padding()
        let sut = try view.inspect().text()
        let count: Int
        if #available(iOS 15.3, tvOS 15.3, macOS 12.3, *) {
            count = 4
        } else {
            count = 3
        }
        XCTAssertEqual(sut.content.medium.viewModifiers.count, count)
    }

    func testLayoutBasedViewTree() throws {
        guard #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *) else {
            throw XCTSkip("Layouts are not available in this version.")
        }

        XCTAssertNoThrow(try LayoutScreen().inspect().find(text: "LayoutScreen text 2"))
    }
}

// MARK: - View Modifiers

@available(iOS 13.0, macOS 10.15, *)
@available(tvOS, unavailable)
final class GlobalModifiersForTreeView: XCTestCase {
    
    @available(watchOS, deprecated: 7.0)
    func testContextMenu() throws {
        let sut = EmptyView().contextMenu(menuItems: { Text("") })
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
}

// MARK: - LayoutScreen

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
private struct LayoutScreen: View {
    var body: some View {
        SimpleHStackLayout {
            Text("LayoutScreen text 1")
            Text("LayoutScreen text 2")
            Text("LayoutScreen text 3")
        }
    }
}

// MARK: - SimpleHStackLayout

/// Sample code copied from https://swiftui-lab.com/layout-protocol-part-1/#layout-cache
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
private struct SimpleHStackLayout: Layout {
    struct CacheData {
        var maxHeight: CGFloat
        var spaces: [CGFloat]
    }

    var spacing: CGFloat?

    func makeCache(subviews: Subviews) -> CacheData {
        CacheData(
            maxHeight: computeMaxHeight(subviews: subviews),
            spaces: computeSpaces(subviews: subviews))
    }

    func updateCache(_ cache: inout CacheData, subviews: Subviews) {
        cache.maxHeight = computeMaxHeight(subviews: subviews)
        cache.spaces = computeSpaces(subviews: subviews)
    }

    func sizeThatFits(proposal _: ProposedViewSize, subviews: Subviews, cache: inout CacheData) -> CGSize {
        let idealViewSizes = subviews.map { $0.sizeThatFits(.unspecified) }
        let accumulatedWidths = idealViewSizes.reduce(0) { $0 + $1.width }
        let accumulatedSpaces = cache.spaces.reduce(0) { $0 + $1 }

        return CGSize(
            width: accumulatedSpaces + accumulatedWidths,
            height: cache.maxHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal _: ProposedViewSize, subviews: Subviews, cache: inout CacheData) {
        var pt = CGPoint(x: bounds.minX, y: bounds.minY)

        for idx in subviews.indices {
            subviews[idx].place(at: pt, anchor: .topLeading, proposal: .unspecified)

            if idx < subviews.count - 1 {
                pt.x += subviews[idx].sizeThatFits(.unspecified).width + cache.spaces[idx]
            }
        }
    }

    func computeSpaces(subviews: LayoutSubviews) -> [CGFloat] {
        if let spacing {
            return [CGFloat](repeating: spacing, count: subviews.count - 1)
        } else {
            return subviews.indices.map { idx in
                guard idx < subviews.count - 1 else { return CGFloat(0) }

                return subviews[idx].spacing.distance(to: subviews[idx + 1].spacing, along: .horizontal)
            }
        }
    }

    func computeMaxHeight(subviews: LayoutSubviews) -> CGFloat {
        subviews.map { $0.sizeThatFits(.unspecified) }.reduce(0) { max($0, $1.height) }
    }
}
