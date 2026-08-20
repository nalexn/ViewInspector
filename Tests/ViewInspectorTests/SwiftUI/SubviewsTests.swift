import XCTest
import SwiftUI
@testable import ViewInspector

@MainActor
@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
final class SubviewsTests: XCTestCase {

    // MARK: - Group(subviews:)

    func testGroupSubviewsSingleSubview() throws {
        let view = Group(subviews: HStack { Text("First"); Text("Second") }) { subviews in
            ForEach(Array(subviews.enumerated()), id: \.offset) { _, subview in subview }
        }
        let sut = try view.inspect().group()
        // The HStack is a single subview of the inspected view
        XCTAssertEqual(sut.count, 1)
        XCTAssertEqual(try sut.hStack(0).text(0).string(), "First")
        XCTAssertEqual(try sut.hStack(0).text(1).string(), "Second")
    }

    func testGroupSubviewsMultipleSubviews() throws {
        let view = SubviewsContainer { Text("First"); Text("Second"); Text("Third") }
        let sut = try view.inspect().view(SubviewsContainer<TupleView<(Text, Text, Text)>>.self).group()
        XCTAssertEqual(sut.count, 3)
        XCTAssertEqual(try sut.text(0).string(), "First")
        XCTAssertEqual(try sut.text(2).string(), "Third")
    }

    func testGroupSubviewsSearch() throws {
        let view = AnyView(Group(subviews: VStack { Text("First") }) { $0 })
        XCTAssertEqual(try view.inspect().find(text: "First").pathToRoot,
                       "anyView().group().vStack(0).text(0)")
    }

    func testGroupSubviewsTransformIsNotApplied() throws {
        let view = Group(subviews: VStack { Text("First") }) { subviews in
            ForEach(Array(subviews.enumerated()), id: \.offset) { index, subview in
                subview.accessibilityIdentifier("subview-\(index)")
            }
        }
        // The transform closure takes a `SubviewsCollection` that only the SwiftUI
        // rendering engine can produce, so the transformation is not visible for inspection
        XCTAssertThrows(
            try view.inspect().find(viewWithAccessibilityIdentifier: "subview-0"),
            "Search did not find a match")
    }

    // MARK: - Group(sections:)

    func testGroupSectionsContent() throws {
        let view = Group(sections: VStack {
            Section { Text("Content 1") } header: { Text("Header 1") }
            Section { Text("Content 2") } header: { Text("Header 2") }
        }) { sections in
            ForEach(Array(sections.enumerated()), id: \.offset) { index, _ in
                Text("Section \(index)")
            }
        }
        let sut = try view.inspect().group().vStack(0)
        XCTAssertEqual(sut.count, 2)
        XCTAssertEqual(try sut.section(0).header().text().string(), "Header 1")
        XCTAssertEqual(try sut.section(1).text(0).string(), "Content 2")
    }

    func testGroupSectionsSearch() throws {
        let view = AnyView(Group(sections: VStack { Section { Text("First") } }) { _ in EmptyView() })
        XCTAssertEqual(try view.inspect().find(text: "First").pathToRoot,
                       "anyView().group().vStack(0).section(0).text(0)")
    }

    // MARK: - ForEach(subviews:)

    func testForEachSubviews() throws {
        let view = ForEach(subviews: HStack { Text("First"); Text("Second") }) { subview in
            subview.border(Color.red)
        }
        let sut = try view.inspect().forEach()
        XCTAssertEqual(sut.count, 1)
        XCTAssertEqual(try sut.hStack(0).text(1).string(), "Second")
    }

    func testForEachSubviewsSearch() throws {
        let view = ForEach(subviews: VStack { Text("First") }) { $0 }
        XCTAssertEqual(try view.inspect().find(text: "First").pathToRoot,
                       "forEach().vStack(0).text(0)")
    }

    // MARK: - ForEach(sections:)

    func testForEachSections() throws {
        let view = ForEach(sections: VStack {
            Section { Text("Content 1") } header: { Text("Header 1") }
        }) { section in
            Text("Section")
        }
        let sut = try view.inspect().forEach().group(0).vStack(0)
        XCTAssertEqual(try sut.section(0).header().text().string(), "Header 1")
        XCTAssertEqual(try sut.section(0).text(0).string(), "Content 1")
    }

    func testForEachSectionsSearch() throws {
        let view = ForEach(sections: VStack { Section { Text("First") } }) { _ in EmptyView() }
        XCTAssertEqual(try view.inspect().find(text: "First").pathToRoot,
                       "forEach().group(0).vStack(0).section(0).text(0)")
    }
}

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
private struct SubviewsContainer<Content: View>: View {

    @ViewBuilder var content: Content

    var body: some View {
        Group(subviews: content) { subviews in
            ForEach(Array(subviews.enumerated()), id: \.offset) { _, subview in subview }
        }
    }
}
