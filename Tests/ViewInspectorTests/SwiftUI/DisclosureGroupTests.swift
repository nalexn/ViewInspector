import XCTest
import SwiftUI
@testable import ViewInspector

#if os(iOS) || os(macOS)
@available(iOS 13.0, macOS 10.15, *)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
final class DisclosureGroupTests: XCTestCase {
    
    func testInspect() throws {
        guard #available(iOS 14, tvOS 14, macOS 11.0, *) else { return }
        let view = DisclosureGroup(content: { EmptyView() }, label: { EmptyView() })
        XCTAssertNoThrow(try view.inspect())
    }
    
    func testExtractionFromSingleViewContainer() throws {
        guard #available(iOS 14, tvOS 14, macOS 11.0, *) else { return }
        let view = AnyView(DisclosureGroup(content: { EmptyView() }, label: { EmptyView() }))
        XCTAssertNoThrow(try view.inspect().anyView().disclosureGroup())
    }
    
    func testExtractionFromMultipleViewContainer() throws {
        guard #available(iOS 14, tvOS 14, macOS 11.0, *) else { return }
        let view = HStack {
            Text("")
            DisclosureGroup(content: { EmptyView() }, label: { EmptyView() })
            Text("")
        }
        XCTAssertNoThrow(try view.inspect().hStack().disclosureGroup(1))
    }
    
    func testLabelInspection() throws {
        guard #available(iOS 14, tvOS 14, macOS 11.0, *) else { return }
        let sut = DisclosureGroup(content: { EmptyView() }, label: { Text("abc") })
        let string = try sut.inspect().disclosureGroup().labelView().text().string()
        XCTAssertEqual(string, "abc")
    }
    
    func testContentInspection() throws {
        guard #available(iOS 14, tvOS 14, macOS 11.0, *) else { return }
        let sut = DisclosureGroup(content: { Text("abc") }, label: { EmptyView() })
        let string = try sut.inspect().disclosureGroup().text(0).string()
        XCTAssertEqual(string, "abc")
    }
    
    func testToupleContentInspection() throws {
        guard #available(iOS 14, tvOS 14, macOS 11.0, *) else { return }
        let sut = DisclosureGroup(content: {
                                    EmptyView()
                                    Text("abc")
        }, label: { EmptyView() })
        let string = try sut.inspect().disclosureGroup().text(1).string()
        XCTAssertEqual(string, "abc")
    }
    
    func testSearch() throws {
        guard #available(iOS 14, tvOS 14, macOS 11.0, *) else { return }
        let sut = DisclosureGroup(content: {
                                    EmptyView()
                                    Text("abc")
        }, label: { Spacer() })
        XCTAssertEqual(try sut.inspect().find(text: "abc").pathToRoot,
                       "disclosureGroup().text(1)")
        XCTAssertEqual(try sut.inspect().find(ViewType.Spacer.self).pathToRoot,
                       "disclosureGroup().labelView().spacer()")
    }
    
    func testExpansionError() throws {
        guard #available(iOS 14, tvOS 14, macOS 11.0, *) else { return }
        let sut = DisclosureGroup("", content: { EmptyView() })
        XCTAssertFalse(try sut.inspect().disclosureGroup().isExpanded())
        // swiftlint:disable line_length
        XCTAssertThrows(try sut.inspect().disclosureGroup().expand(),
                        "You need to enable programmatic expansion by using `DisclosureGroup(isExpanded:, content:, label:`")
        // swiftlint:enable line_length
    }
    
    func testExpansionWithStateActivation() throws {
        guard #available(iOS 14, tvOS 14, macOS 11.0, *) else { return }
        let view = TestViewState()
        XCTAssertFalse(view.state.expanded)
        XCTAssertFalse(try view.inspect().disclosureGroup().isExpanded())
        try view.inspect().disclosureGroup().expand()
        XCTAssertTrue(try view.inspect().disclosureGroup().isExpanded())
        try view.inspect().disclosureGroup().collapse()
        XCTAssertFalse(try view.inspect().disclosureGroup().isExpanded())
    }
    
    func testExpansionWithBindingActivation() throws {
        guard #available(iOS 14, tvOS 14, macOS 11.0, *) else { return }
        let expanded = Binding<Bool>(wrappedValue: false)
        let view = TestViewBinding(expanded: expanded)
        XCTAssertFalse(try view.inspect().disclosureGroup().isExpanded())
        try view.inspect().disclosureGroup().expand()
        XCTAssertTrue(try view.inspect().disclosureGroup().isExpanded())
        try view.inspect().disclosureGroup().collapse()
        XCTAssertFalse(try view.inspect().disclosureGroup().isExpanded())
    }
}

@available(iOS 14.0, macOS 11.0, *)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
private struct TestViewState: View, Inspectable {
    @ObservedObject var state = ExpansionState()
    
    var body: some View {
        DisclosureGroup(isExpanded: $state.expanded, content: {
            EmptyView()
            Text("abc")
        }, label: { EmptyView() })
    }
    
    class ExpansionState: ObservableObject {
        @Published var expanded: Bool = false
    }
}

@available(iOS 14.0, macOS 11.0, *)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
private struct TestViewBinding: View, Inspectable {

    @Binding var expanded: Bool = false
    
    init(expanded: Binding<Bool>) {
        _expanded = expanded
    }
    
    var body: some View {
        DisclosureGroup(isExpanded: $expanded, content: {
            EmptyView()
            Text("abc")
        }, label: { EmptyView() })
    }
}
#endif
