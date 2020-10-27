import XCTest
import SwiftUI
@testable import ViewInspector

#if !os(macOS)

final class DisclosureGroupTests: XCTestCase {
    
    @available(iOS 14.0, macOS 11.0, *)
    @available(tvOS, unavailable)
    func testInspect() throws {
        let view = DisclosureGroup(content: { EmptyView() }, label: { EmptyView() })
        XCTAssertNoThrow(try view.inspect())
    }
    
    @available(iOS 14.0, macOS 11.0, *)
    @available(tvOS, unavailable)
    func testExtractionFromSingleViewContainer() throws {
        let view = AnyView(DisclosureGroup(content: { EmptyView() }, label: { EmptyView() }))
        XCTAssertNoThrow(try view.inspect().anyView().disclosureGroup())
    }
    
    @available(iOS 14.0, macOS 11.0, *)
    @available(tvOS, unavailable)
    func testExtractionFromMultipleViewContainer() throws {
        let view = HStack {
            Text("")
            DisclosureGroup(content: { EmptyView() }, label: { EmptyView() })
            Text("")
        }
        XCTAssertNoThrow(try view.inspect().hStack().disclosureGroup(1))
    }
    
    @available(iOS 14.0, macOS 11.0, *)
    @available(tvOS, unavailable)
    func testLabelInspection() throws {
        let sut = DisclosureGroup(content: { EmptyView() }, label: { Text("abc") })
        let string = try sut.inspect().disclosureGroup().label().text().string()
        XCTAssertEqual(string, "abc")
    }
    
    @available(iOS 14.0, macOS 11.0, *)
    @available(tvOS, unavailable)
    func testContentInspection() throws {
        let sut = DisclosureGroup(content: { Text("abc") }, label: { EmptyView() })
        let string = try sut.inspect().disclosureGroup().contentView().text().string()
        XCTAssertEqual(string, "abc")
    }
    
    @available(iOS 14.0, macOS 11.0, *)
    @available(tvOS, unavailable)
    func testToupleContentInspection() throws {
        let sut = DisclosureGroup(content: {
                                    EmptyView()
                                    Text("abc")
        }, label: { EmptyView() })
        let string = try sut.inspect().disclosureGroup().contentView().text(1).string()
        XCTAssertEqual(string, "abc")
    }
    
    @available(iOS 14.0, macOS 11.0, *)
    @available(tvOS, unavailable)
    func testExpansionError() throws {
        let sut = DisclosureGroup("", content: { EmptyView() })
        XCTAssertFalse(try sut.inspect().disclosureGroup().isExpanded())
        // swiftlint:disable line_length
        XCTAssertThrows(try sut.inspect().disclosureGroup().expand(),
                        "You need to enable programmatic expansion by using `DisclosureGroup(isExpanded:, content:, label:`")
        // swiftlint:enable line_length
    }
    
    @available(iOS 14.0, macOS 11.0, *)
    @available(tvOS, unavailable)
    func testExpansionWithStateActivation() throws {
        let view = TestViewState()
        XCTAssertFalse(view.state.expanded)
        XCTAssertFalse(try view.inspect().disclosureGroup().isExpanded())
        try view.inspect().disclosureGroup().expand()
        XCTAssertTrue(try view.inspect().disclosureGroup().isExpanded())
        try view.inspect().disclosureGroup().collapse()
        XCTAssertFalse(try view.inspect().disclosureGroup().isExpanded())
    }
    
    @available(iOS 14.0, macOS 11.0, *)
    @available(tvOS, unavailable)
    func testExpansionWithBindingActivation() throws {
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
