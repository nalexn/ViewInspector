import XCTest
import SwiftUI
@testable import ViewInspector

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
final class PreferenceTests: XCTestCase {
    
    func testPreference() throws {
        let sut = EmptyView().preference(key: Key.self, value: "test")
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testTransformPreference() throws {
        let sut = EmptyView().transformPreference(Key.self) { _ in }
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testAnchorPreference() throws {
        let source = Anchor.Source([Anchor<String>.Source]())
        let sut = EmptyView().anchorPreference(key: Key.self, value: source, transform: { _ in "" })
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testTransformAnchorPreference() throws {
        let source = Anchor.Source([Anchor<String>.Source]())
        let sut = EmptyView().transformAnchorPreference(key: Key.self, value: source, transform: { _, _ in })
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testOnPreferenceChange() throws {
        let sut = EmptyView().onPreferenceChange(Key.self) { _ in }
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testOverlayPreferenceValue() throws {
        let sut = try EmptyView()
            .overlayPreferenceValue(Key.self) { _ in Text("Test") }
            .inspect()
        XCTAssertNoThrow(try sut.emptyView())
        XCTAssertEqual(try sut.overlayPreferenceValue().text().string(), "Test")
    }
    
    func testBackgroundPreferenceValue() throws {
        let sut = try EmptyView()
            .backgroundPreferenceValue(Key.self) { _ in Text("Test") }
            .inspect()
        XCTAssertNoThrow(try sut.emptyView())
        XCTAssertEqual(try sut.backgroundPreferenceValue().text().string(), "Test")
    }
    
    func testRetainsModifiers() throws {
        let view = Text("Test")
            .padding()
            .overlayPreferenceValue(Key.self) { _ in EmptyView().padding() }
            .padding().padding()
        let sut1 = try view.inspect().text()
        XCTAssertEqual(sut1.content.medium.viewModifiers.count, 4)
        let sut2 = try view.inspect().overlayPreferenceValue().emptyView()
        XCTAssertEqual(sut2.content.medium.viewModifiers.count, 1)
    }
    
    struct Key: PreferenceKey {
        static var defaultValue: String = "abc"
        static func reduce(value: inout String, nextValue: () -> String) {
            value = nextValue()
        }
    }
    
    func testDifferentOverlayUseCases() throws {
        let sut = try ManyOverlaysView().inspect().emptyView()
        let prefValue = try sut.overlayPreferenceValue().text().string()
        XCTAssertEqual(prefValue, Key.defaultValue)
        let border = try sut.border(Color.self)
        XCTAssertEqual(border.shapeStyle, .red)
        XCTAssertNoThrow(try sut.overlay(1).spacer())
    }
    
    func testDifferentOverlayUseCasesIOS15() throws {
        guard #available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
        else { throw XCTSkip() }
        let sut = try ManyOverlaysViewIOS15().inspect().emptyView()
        let prefValue = try sut.overlayPreferenceValue().text().string()
        XCTAssertEqual(prefValue, Key.defaultValue)
        let border = try sut.border(Color.self)
        XCTAssertEqual(border.shapeStyle, .red)
        XCTAssertNoThrow(try sut.overlay(0).spacer())
        XCTAssertEqual(try sut.overlay(1).color().value(), Color.green)
    }
    
    func testDifferentBackgroundOverlayUseCases() throws {
        let sut = try ManyBGOverlaysView().inspect().emptyView()
        let prefValue = try sut.backgroundPreferenceValue().text().string()
        XCTAssertEqual(prefValue, Key.defaultValue)
        XCTAssertNoThrow(try sut.background(1).spacer())
    }
    
    func testOverlaySearch() throws {
        let sut1 = try ManyOverlaysView().inspect()
        XCTAssertEqual(try sut1.find(text: "Test").pathToRoot,
            "view(ManyOverlaysView.self).emptyView().overlay().anyView().text()")
        XCTAssertEqual(try sut1.find(text: Key.defaultValue).pathToRoot,
            "view(ManyOverlaysView.self).emptyView().overlayPreferenceValue().text()")
        let sut2 = try ManyBGOverlaysView().inspect()
        XCTAssertEqual(try sut2.find(text: "Test").pathToRoot,
            "view(ManyBGOverlaysView.self).emptyView().background().anyView().text()")
        XCTAssertEqual(try sut2.find(text: Key.defaultValue).pathToRoot,
            "view(ManyBGOverlaysView.self).emptyView().backgroundPreferenceValue().text()")
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
private struct ManyOverlaysView: View, Inspectable {
    var body: some View {
        EmptyView()
            .overlay(AnyView(Text("Test")))
            .overlayPreferenceValue(PreferenceTests.Key.self) { value in
                Text(value)
            }
            .border(Color.red)
            .overlay(Spacer())
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
private struct ManyOverlaysViewIOS15: View, Inspectable {
    var body: some View {
        EmptyView()
            .overlay(Spacer())
            .overlayPreferenceValue(PreferenceTests.Key.self) { value in
                Text(value)
            }
            .overlay(Color.green, ignoresSafeAreaEdges: [.top])
            .border(Color.red)
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
private struct ManyBGOverlaysView: View, Inspectable {
    var body: some View {
        EmptyView()
            .background(AnyView(Text("Test")))
            .backgroundPreferenceValue(PreferenceTests.Key.self) { value in
                Text(value)
            }
            .background(Spacer())
    }
}
