import XCTest
import SwiftUI
@testable import ViewInspector

@available(iOS 13.0, macOS 10.15, *)
@available(tvOS, unavailable)
final class TreeViewTests: XCTestCase {
    
    @available(watchOS, deprecated: 7.0)
    func testEnclosedView() throws {
        let sut = Text("Test").contextMenu(ContextMenu(menuItems: { Text("Menu") }))
        let text = try sut.inspect().text().string()
        XCTAssertEqual(text, "Test")
    }
    
    @available(watchOS, deprecated: 7.0)
    func testRetainsModifiers() throws {
        let view = Text("Test")
            .padding()
            .contextMenu(ContextMenu(menuItems: { Text("Menu") }))
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

  @available(watchOS, deprecated: 7.0)
  func testVariadicViewTree() throws {
    let button = try SampleVariadicViewScreen().inspect().find(button: "Execute")
    XCTAssertNotNil(button)
  }

  @available(iOS 16.0, *)
  func testLayoutViewTree() throws {
    XCTAssertNoThrow(try SampleLayoutScreen().inspect().find(text: "SampleLayoutScreen text 2"))
  }
}

// MARK: - View Modifiers

@available(iOS 13.0, macOS 10.15, *)
@available(tvOS, unavailable)
final class GlobalModifiersForTreeView: XCTestCase {
    
    @available(watchOS, deprecated: 7.0)
    func testContextMenu() throws {
        let sut = EmptyView().contextMenu(ContextMenu(menuItems: { Text("") }))
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
}

// MARK: - SampleVariadicViewScreen

@available(iOS 13.0, macOS 10.15, *)
private struct SampleVariadicViewScreen: View {
  @State var opacity: Double = 1.0

  var body: some View {
    _VariadicView.Tree(SampleVariadicViewScreenOpacityRoot(opacity: opacity),
                       content: {
      Text("Click the button to execute the action.")
      Button(action: {
        if opacity < 1.0 {
          opacity = 1.0
        } else {
          opacity = 0.5
        }
      }, label: {
        Text("Execute")
      })
    })
  }
}

// MARK: - SampleVariadicViewScreenRoot

@available(iOS 13.0, macOS 10.15, *)
private struct SampleVariadicViewScreenOpacityRoot: _VariadicView_MultiViewRoot {
  let opacity: Double

  func body(children: _VariadicView.Children) -> some View {
    ForEach(children) { child in
      child
        .opacity(opacity)
    }
  }
}

// MARK: - SampleLayoutScreen

@available(iOS 16.0, *)
private struct SampleLayoutScreen: View {
  var body: some View {
    SimpleHStackLayout {
      Text("SampleLayoutScreen text 1")
      Text("SampleLayoutScreen text 2")
      Text("SampleLayoutScreen text 3")
    }
  }
}

// MARK: - SimpleHStack

@available(iOS 16.0, *)
// copied from https://swiftui-lab.com/layout-protocol-part-1/#layout-cache
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
