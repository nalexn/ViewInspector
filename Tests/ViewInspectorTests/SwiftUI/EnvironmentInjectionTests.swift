import XCTest
import SwiftUI

@testable import ViewInspector

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
class EnvironmentInjectionTests: XCTestCase {

    override func setUp() {
        super.setUp()
        ViewInspectorConfig.resolveEnvironmentValues = false
    }

    override func tearDown() {
        ViewInspectorConfig.resolveEnvironmentValues = false
        super.tearDown()
    }

    // MARK: - EnvironmentResolvable protocol

    func testBoolEnvironmentResolvesToValueState() throws {
        let env = Environment(\.isEnabled)
        let resolution = env._resolve(using: EnvironmentValues())
        XCTAssertNotNil(resolution)
        XCTAssertEqual(resolution!.fieldSize, MemoryLayout<Environment<Bool>>.size)
        XCTAssertNotEqual(resolution!.originalBytes, resolution!.resolvedBytes)
    }

    func testEnumEnvironmentResolvesToValueState() throws {
        let env = Environment(\.colorScheme)
        let resolution = env._resolve(using: EnvironmentValues())
        XCTAssertNotNil(resolution)
        XCTAssertEqual(resolution!.fieldSize, MemoryLayout<Environment<ColorScheme>>.size)
    }

    func testActionEnvironmentDoesNotCrashDuringResolution() throws {
        guard #available(iOS 15.0, macOS 12.0, tvOS 15.0, *) else { throw XCTSkip("iOS 15+") }
        let env = Environment(\.dismiss)
        _ = env._resolve(using: EnvironmentValues())
    }

    func testUnresolvedEnvironmentIsInKeyPathState() throws {
        let env = Environment(\.colorScheme)
        let mirror = Mirror(reflecting: env)
        let contentChild = mirror.children.first { $0.label == "content" }
        XCTAssertNotNil(contentChild, "@Environment should have a 'content' child")
        let contentMirror = Mirror(reflecting: contentChild!.value)
        let enumCase = contentMirror.children.first
        XCTAssertEqual(enumCase?.label, "keyPath")
    }

    // MARK: - resolveEnvironmentProperties disabled

    @MainActor
    func testResolutionSkippedWhenFlagIsDisabled() throws {
        ViewInspectorConfig.resolveEnvironmentValues = false
        let view = SimpleEnvironmentView()
        let result = EnvironmentInjection.resolveEnvironmentProperties(in: view)
        let mirror = Mirror(reflecting: result)
        for child in mirror.children {
            let typeName = Inspector.typeName(value: child.value, namespaced: true)
            guard typeName.hasPrefix("SwiftUI.Environment") else { continue }
            let contentMirror = Mirror(reflecting: child.value)
                .children.first { $0.label == "content" }
                .flatMap { Mirror(reflecting: $0.value).children.first }
            XCTAssertEqual(contentMirror?.label, "keyPath")
        }
    }

    // MARK: - resolveEnvironmentProperties enabled

    @MainActor
    func testSimpleViewResolvedWhenFlagIsEnabled() throws {
        ViewInspectorConfig.resolveEnvironmentValues = true
        let view = SimpleEnvironmentView()
        let resolved = EnvironmentInjection.resolveEnvironmentProperties(in: view)
        let text = try resolved.inspect().find(ViewType.Text.self).string()
        XCTAssertEqual(text, "enabled")
    }

    @MainActor
    func testMultipleEnvironmentFieldsResolvedInSameView() throws {
        guard #available(iOS 15.0, macOS 12.0, tvOS 15.0, *) else { throw XCTSkip("iOS 15+") }
        ViewInspectorConfig.resolveEnvironmentValues = true
        let view = MultiEnvironmentView()
        let resolved = EnvironmentInjection.resolveEnvironmentProperties(in: view)
        let text = try resolved.inspect().find(ViewType.Text.self).string()
        XCTAssertEqual(text, "light_large")
    }

    @MainActor
    func testDismissEnvironmentDoesNotCrashDuringViewResolution() throws {
        guard #available(iOS 15.0, macOS 12.0, tvOS 15.0, *) else { throw XCTSkip("iOS 15+") }
        ViewInspectorConfig.resolveEnvironmentValues = true
        _ = EnvironmentInjection.resolveEnvironmentProperties(in: DismissEnvironmentView())
    }

    // MARK: - ViewInspector integration

    @MainActor
    func testInspectionOfViewWithMultipleEnvironmentFields() throws {
        guard #available(iOS 15.0, macOS 12.0, tvOS 15.0, *) else { throw XCTSkip("iOS 15+") }
        ViewInspectorConfig.resolveEnvironmentValues = true
        let text = try MultiEnvironmentView().inspect().find(ViewType.Text.self).string()
        XCTAssertEqual(text, "light_large")
    }

    @MainActor
    func testInspectionOfViewWithEnvironmentAndEnvironmentObject() throws {
        ViewInspectorConfig.resolveEnvironmentValues = true
        let obj = TestEnvObj()
        let sut = MixedEnvironmentView().environmentObject(obj)
        let text = try sut.inspect().find(ViewType.Text.self).string()
        XCTAssertEqual(text, "light_hello")
    }

    @MainActor
    func testInspectionOfViewModifierWithEnvironment() throws {
        ViewInspectorConfig.resolveEnvironmentValues = true
        let text = try EnvironmentModifierTestView().inspect().find(ViewType.Text.self).string()
        XCTAssertEqual(text, "content")
    }

    // MARK: - Custom environment values

    @MainActor
    func testEnvironmentModifierOverrideUsedDuringResolution() throws {
        ViewInspectorConfig.resolveEnvironmentValues = true
        let sut = ColorSchemeView().environment(\.colorScheme, .dark)
        let text = try sut.inspect().find(ViewType.Text.self).string()
        XCTAssertEqual(text, "dark")
    }

    @MainActor
    func testEnvironmentValuesFromModifiersAppliesCustomKeys() throws {
        // Build EnvironmentValues from a tracked modifier and verify the value is applied
        let sut = CustomKeyView().environment(\.testString, "custom_value")
        let inspected = try sut.inspect().find(ViewType.View<CustomKeyView>.self)
        let modifiers = inspected.content.medium.environmentModifiers
        XCTAssertFalse(modifiers.isEmpty, "Environment modifier should be tracked")
        let env = EnvironmentInjection.environmentValues(from: modifiers)
        XCTAssertEqual(env.testString, "custom_value")
    }

    @MainActor
    func testCustomEnvironmentKeyUsedDuringResolution() throws {
        ViewInspectorConfig.resolveEnvironmentValues = true
        let sut = CustomKeyView().environment(\.testString, "custom_value")
        let text = try sut.inspect().find(ViewType.Text.self).string()
        XCTAssertEqual(text, "custom_value")
    }

    @MainActor
    func testDefaultEnvironmentValuesUsedWhenNoOverride() throws {
        ViewInspectorConfig.resolveEnvironmentValues = true
        let text = try CustomKeyView().inspect().find(ViewType.Text.self).string()
        XCTAssertEqual(text, "default")
    }

    // MARK: - Regression

    @MainActor
    func testEnvironmentObjectInjectionStillWorksWithResolutionEnabled() throws {
        ViewInspectorConfig.resolveEnvironmentValues = true
        let obj = TestEnvObj()
        var sut = EnvironmentObjectOnlyView()
        sut = EnvironmentInjection.inject(environmentObject: obj, into: sut)
        let text = try sut.inspect().find(ViewType.Text.self).string()
        XCTAssertEqual(text, "hello")
    }
}

// MARK: - Test Views

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
private struct SimpleEnvironmentView: View {
    @Environment(\.isEnabled) var isEnabled
    var body: some View { Text(isEnabled ? "enabled" : "disabled") }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, *)
private struct MultiEnvironmentView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dynamicTypeSize) var dynamicTypeSize
    var body: some View {
        let scheme = colorScheme == .dark ? "dark" : "light"
        let size = dynamicTypeSize == .large ? "large" : "other"
        Text("\(scheme)_\(size)")
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, *)
private struct DismissEnvironmentView: View {
    @Environment(\.dismiss) var dismiss
    var body: some View { Button("Dismiss") { dismiss() } }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
private class TestEnvObj: ObservableObject {
    @Published var value = "hello"
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
private struct MixedEnvironmentView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var obj: TestEnvObj
    var body: some View { Text("\(colorScheme == .dark ? "dark" : "light")_\(obj.value)") }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
private struct EnvironmentModifierTestView: View {
    var body: some View {
        Text("content")
            .modifier(EnvironmentTestModifier())
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
struct EnvironmentTestModifier: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    func body(content: Self.Content) -> some View {
        VStack {
            content
        }
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
private struct EnvironmentObjectOnlyView: View {
    @EnvironmentObject var obj: TestEnvObj
    var body: some View { Text(obj.value) }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
private struct ColorSchemeView: View {
    @Environment(\.colorScheme) var colorScheme
    var body: some View { Text(colorScheme == .dark ? "dark" : "light") }
}

// MARK: - Custom EnvironmentKey

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
private struct TestStringKey: EnvironmentKey {
    static let defaultValue = "default"
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension EnvironmentValues {
    var testString: String {
        get { self[TestStringKey.self] }
        set { self[TestStringKey.self] = newValue }
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
private struct CustomKeyView: View {
    @Environment(\.testString) var testString
    var body: some View { Text(testString) }
}
