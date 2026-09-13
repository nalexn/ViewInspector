import XCTest
import SwiftUI
@testable import ViewInspector

@MainActor
@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
final class TupleViewTests: XCTestCase {
    
    func testSimpleTupleView() throws {
        let view = SimpleTupleView().padding()
        let sut = try view.inspect().view(SimpleTupleView.self).implicitAnyView()
        XCTAssertThrows(try sut.emptyView(),
                        "Unable to extract EmptyView: please specify its index inside parent view")
        XCTAssertNoThrow(try sut.emptyView(0))
        XCTAssertNoThrow(try sut.text(1))
    }
    
    func testTupleInsideTupleView() throws {
        let view = TupleInsideTupleView(flag: true)
        let sut = try view.inspect().implicitAnyView().hStack()
        let string1 = try sut.text(0).string()
        XCTAssertEqual(string1, "xyz")
        XCTAssertThrows(try sut.text(1),
                        "Please insert .\(tupleCall)(1) after HStack for inspecting its children at index 1")
        let string2 = try nestedTupleText(sut, tuple: 1, text: 0).string()
        XCTAssertEqual(string2, "abc")
        let string3 = try nestedTupleText(sut, tuple: 1, text: 1).string()
        XCTAssertEqual(string3, "def")
    }
    
    func testSearch() throws {
        let view1 = TupleInsideTupleView(flag: true)
        let view2 = TupleInsideTupleView(flag: false)
        #if compiler(<6) || compiler(>=6.1)
        XCTAssertEqual(try view1.inspect().find(text: "xyz").pathToRoot,
                       "view(TupleInsideTupleView.self).hStack().text(0)")
        XCTAssertEqual(try view1.inspect().find(text: "abc").pathToRoot,
                       "view(TupleInsideTupleView.self).hStack().\(tupleCall)(1).text(0)")
        XCTAssertEqual(try view1.inspect().find(text: "def").pathToRoot,
                       "view(TupleInsideTupleView.self).hStack().\(tupleCall)(1).text(1)")
        XCTAssertEqual(try view2.inspect().find(text: "xyz").pathToRoot,
                       "view(TupleInsideTupleView.self).hStack().text(0)")
        #else
        XCTAssertEqual(try view1.inspect().find(text: "xyz").pathToRoot,
                       "view(TupleInsideTupleView.self).anyView().hStack().text(0)")
        XCTAssertEqual(try view1.inspect().find(text: "abc").pathToRoot,
                       "view(TupleInsideTupleView.self).anyView().hStack().\(tupleCall)(1).text(0)")
        XCTAssertEqual(try view1.inspect().find(text: "def").pathToRoot,
                       "view(TupleInsideTupleView.self).anyView().hStack().\(tupleCall)(1).text(1)")
        XCTAssertEqual(try view2.inspect().find(text: "xyz").pathToRoot,
                       "view(TupleInsideTupleView.self).anyView().hStack().text(0)")
        #endif
        XCTAssertThrows(try view2.inspect().find(text: "abc"), "Search did not find a match")
        XCTAssertThrows(try view2.inspect().find(text: "def"), "Search did not find a match")
    }
    
    func testMultipleChildrenInContainer() throws {
        let view = VStack { Text("A"); Text("B") }
        XCTAssertEqual(try view.inspect().vStack().text(0).string(), "A")
        XCTAssertEqual(try view.inspect().vStack().text(1).string(), "B")
        XCTAssertEqual(try view.inspect().find(text: "B").pathToRoot, "vStack().text(1)")
    }

    func testMultipleModifiedChildrenInContainer() throws {
        guard #available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
        else { throw XCTSkip() }
        let view = DecoratedFieldsView()
        XCTAssertEqual(try view.inspect().find(text: "Label").string(), "Label")
        XCTAssertEqual(try view.inspect().find(ViewType.TextField.self).labelView().text().string(),
                       "Placeholder")
        XCTAssertEqual(try view.inspect().find(text: "Footer").string(), "Footer")
    }

    func testResetsModifiers() throws {
        let view = TupleInsideTupleView(flag: true)
        let hStack = try view.inspect().implicitAnyView().hStack()
        let sut = try nestedTupleText(hStack, tuple: 1, text: 0)
        XCTAssertEqual(sut.content.medium.viewModifiers.count, 2)
    }
}

// MARK: - Deployment target differences

/// `ViewBuilder` assembles multiple children into `TupleContent` instead of
/// `TupleView` when the deployment target is iOS 27 or above. The two are
/// inspected with `tupleContentView(_:)` and `tupleView(_:)` respectively.
@MainActor
@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
private var tupleCall: String {
    return Inspector.isTupleContentView(TupleProbeView().body) ? "tupleContentView" : "tupleView"
}

@MainActor
@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
private func nestedTupleText(_ sut: InspectableView<ViewType.HStack>,
                             tuple: Int, text: Int) throws -> InspectableView<ViewType.Text> {
    if Inspector.isTupleContentView(TupleProbeView().body) {
        return try sut.tupleContentView(tuple).text(text)
    }
    return try sut.tupleView(tuple).text(text)
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
private struct TupleProbeView: View {
    var body: some View {
        Text("1")
        Text("2")
    }
}

// MARK: - TupleContent

#if compiler(>=6.4)

/// Since iOS 27 `ViewBuilder` assembles multiple children into `TupleContent`
/// instead of `TupleView`
@MainActor
@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
final class TupleContentTests: XCTestCase {

    func testTupleContentInsideTupleContent() throws {
        guard #available(iOS 27.0, macOS 27.0, tvOS 27.0, watchOS 27.0, visionOS 27.0, *)
        else { throw XCTSkip() }
        let sut = try TupleContentView(flag: true).inspect().implicitAnyView().hStack()
        XCTAssertEqual(try sut.text(0).string(), "xyz")
        XCTAssertThrows(try sut.text(1),
                        "Please insert .tupleContentView(1) after HStack for inspecting its children at index 1")
        XCTAssertEqual(try sut.tupleContentView(1).text(0).string(), "abc")
        XCTAssertEqual(try sut.tupleContentView(1).text(1).string(), "def")
    }

    func testSearch() throws {
        guard #available(iOS 27.0, macOS 27.0, tvOS 27.0, watchOS 27.0, visionOS 27.0, *)
        else { throw XCTSkip() }
        let view = TupleContentView(flag: true)
        XCTAssertEqual(try view.inspect().find(text: "xyz").pathToRoot,
                       "view(TupleContentView.self).hStack().text(0)")
        XCTAssertEqual(try view.inspect().find(text: "abc").pathToRoot,
                       "view(TupleContentView.self).hStack().tupleContentView(1).text(0)")
        XCTAssertEqual(try view.inspect().find(text: "def").pathToRoot,
                       "view(TupleContentView.self).hStack().tupleContentView(1).text(1)")
    }

    func testResetsModifiers() throws {
        guard #available(iOS 27.0, macOS 27.0, tvOS 27.0, watchOS 27.0, visionOS 27.0, *)
        else { throw XCTSkip() }
        let view = TupleContentView(flag: true)
        let sut = try view.inspect().implicitAnyView().hStack().tupleContentView(1).text(0)
        XCTAssertEqual(sut.content.medium.viewModifiers.count, 2)
    }

    func testToolbarItemsExtraction() throws {
        guard #available(iOS 27.0, macOS 27.0, tvOS 27.0, watchOS 27.0, visionOS 27.0, *)
        else { throw XCTSkip() }
        let sut = try ToolbarTupleContentView().inspect().implicitAnyView().emptyView()
        XCTAssertEqual(try sut.toolbar().item(0).text().string(), "abc")
        XCTAssertEqual(try sut.toolbar().item(1).text().string(), "def")
    }
}

/// The `@available` attribute raises the availability context, so `ViewBuilder`
/// picks the `TupleContent` overload no matter what the deployment target is
@available(iOS 27.0, macOS 27.0, tvOS 27.0, watchOS 27.0, visionOS 27.0, *)
private struct TupleContentView: View {

    let flag: Bool
    var body: some View {
        HStack {
            Text("xyz")
            if flag {
                Text("abc").offset().blur(radius: 1)
                Text("def")
            }
        }.padding()
    }
}

@available(iOS 27.0, macOS 27.0, tvOS 27.0, watchOS 27.0, visionOS 27.0, *)
private struct ToolbarTupleContentView: View {
    var body: some View {
        EmptyView()
            .toolbar {
                ToolbarItem { Text("abc") }
                ToolbarItem { Text("def") }
            }
    }
}

#endif

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
private struct SimpleTupleView: View {
    var body: some View {
        EmptyView()
        Text("abc")
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
private struct TupleInsideTupleView: View {
    
    let flag: Bool
    var body: some View {
        HStack {
            Text("xyz")
            if flag {
                Text("abc").offset().blur(radius: 1)
                Text("def")
            }
        }.padding()
    }
}

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
private struct DecoratedFieldsView: View {

    @State private var value: String = ""

    var body: some View {
        VStack(alignment: .leading) {
            Text("Label")
                .padding(4)
                .accessibilityLabel(Text("label"))
            TextField("Placeholder", text: $value)
                .padding()
                .onAppear { }
            Text("Footer")
                .opacity(0.5)
        }
    }
}
