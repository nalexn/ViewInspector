import XCTest
import SwiftUI

@testable import ViewInspector

@MainActor
@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
final class EnvironmentValueInjectionTests: XCTestCase {

    func testEnvironmentContentMemoryLayout() throws {
        XCTAssertEqual(MemoryLayout<Environment<Int>>.size, MemoryLayout<EnvironmentContent<Int>>.size)
        XCTAssertEqual(MemoryLayout<Environment<String>>.size, MemoryLayout<EnvironmentContent<String>>.size)
        XCTAssertEqual(MemoryLayout<Environment<Payload>>.size, MemoryLayout<EnvironmentContent<Payload>>.size)
        XCTAssertEqual(MemoryLayout<Environment<Int?>>.size, MemoryLayout<EnvironmentContent<Int?>>.size)
        let sut = Environment(\EnvironmentValues.injectedString)
        XCTAssertEqual(sut.injectionKeyPath, \EnvironmentValues.injectedString)
        let replica = EnvironmentContent<String>.keyPath(\EnvironmentValues.injectedString)
        let sutBytes = withUnsafeBytes(of: sut) { Array($0) }
        let replicaBytes = withUnsafeBytes(of: replica) { Array($0) }
        // The key path reference at the front, the case discriminator at the back:
        XCTAssertEqual(sutBytes.prefix(MemoryLayout<UnsafeRawPointer>.size),
                       replicaBytes.prefix(MemoryLayout<UnsafeRawPointer>.size))
        XCTAssertEqual(sutBytes.last, replicaBytes.last)
    }

    func testDirectInjectionOfValueTypes() throws {
        var sut = ValueTypesView()
        XCTAssertEqual(try sut.inspect().find(ViewType.Text.self).string(), "default 0 false none 0.000000")
        sut = EnvironmentInjection.inject(environmentValues: [
            (\EnvironmentValues.injectedString, "injected"),
            (\EnvironmentValues.injectedInt, 42),
            (\EnvironmentValues.injectedBool, true),
            (\EnvironmentValues.injectedOptional, Optional("some")),
            (\EnvironmentValues.injectedStruct, Payload(number: 7.0))
        ], into: sut)
        XCTAssertEqual(try sut.inspect().find(ViewType.Text.self).string(), "injected 42 true some 7.000000")
    }

    func testInjectionThroughEnvironmentModifiers() throws {
        let sut = ValueTypesView()
            .environment(\.injectedString, "injected")
            .environment(\.injectedInt, 42)
            .environment(\.injectedBool, true)
            .environment(\.injectedOptional, "some")
            .environment(\.injectedStruct, Payload(number: 7.0))
        XCTAssertEqual(try sut.inspect().find(ViewType.Text.self).string(), "injected 42 true some 7.000000")
    }

    func testInjectionInNestedCustomView() throws {
        let sut = OuterView().environment(\.injectedString, "injected")
        XCTAssertEqual(try sut.inspect().find(InnerView.self).find(ViewType.Text.self).string(),
                       "injected|injected")
    }

    func testInjectionInCustomViewModifier() throws {
        let sut = InnerView().modifier(InjectedModifier()).environment(\.injectedString, "injected")
        XCTAssertEqual(try sut.inspect().find(text: "modifier: injected").string(), "modifier: injected")
    }

    func testTheInnermostModifierWins() throws {
        let sut = InnerView()
            .environment(\.injectedString, "outer")
            .padding()
        XCTAssertEqual(try VStack { sut.environment(\.injectedString, "inner") }
            .inspect().find(InnerView.self).find(ViewType.Text.self).string(), "outer|outer")
        XCTAssertEqual(try VStack { InnerView().environment(\.injectedString, "inner") }
            .environment(\.injectedString, "outer")
            .inspect().find(InnerView.self).find(ViewType.Text.self).string(), "inner|inner")
    }

    func testInjectionInActualView() throws {
        let sut = ValueTypesView().environment(\.injectedInt, 42)
        let view = try sut.inspect().find(ValueTypesView.self).actualView()
        XCTAssertEqual(view.number, 42)
        XCTAssertEqual(view.string, "default")
    }

    func testUnmodifiedPropertiesKeepTheDefaultValue() throws {
        let sut = ValueTypesView().environment(\.injectedInt, 42)
        XCTAssertEqual(try sut.inspect().find(ViewType.Text.self).string(), "default 42 false none 0.000000")
    }

    func testMultiplePropertiesWithTheSameKeyPath() throws {
        let sut = DuplicatedPropertiesView().environment(\.injectedString, "injected")
        XCTAssertEqual(try sut.inspect().find(ViewType.Text.self).string(), "injected-injected")
    }

    func testInjectionOfReferenceType() throws {
        let object = ReferenceValue()
        object.value = "injected"
        let sut = ReferenceTypeView().environment(\.injectedObject, object)
        XCTAssertEqual(try sut.inspect().find(ViewType.Text.self).string(), "injected")
        let view = try sut.inspect().find(ReferenceTypeView.self).actualView()
        XCTAssertIdentical(view.object, object)
    }

    func testInjectedReferenceTypeIsRetainedAndReleased() throws {
        weak var weakObject: ReferenceValue?
        try {
            let object = ReferenceValue()
            weakObject = object
            var sut = ReferenceTypeView()
            sut = EnvironmentInjection.inject(
                environmentValues: [(\EnvironmentValues.injectedObject, object)], into: sut)
            XCTAssertIdentical(sut.object, object)
            XCTAssertEqual(try sut.inspect().find(ViewType.Text.self).string(), "default")
        }()
        XCTAssertNil(weakObject)
    }

    func testInjectedValueTypeIsNotOverReleased() throws {
        // A `String` payload does not fit in the `keyPath` reference slot,
        // verifying the ARC balance for a multi-word value.
        for _ in 0..<100 {
            var sut = ValueTypesView()
            sut = EnvironmentInjection.inject(
                environmentValues: [(\EnvironmentValues.injectedString, String(repeating: "long", count: 20))],
                into: sut)
            XCTAssertTrue(sut.string.hasPrefix("longlong"))
        }
    }

    func testEnvironmentModifierReadingIsUnaffected() throws {
        let sut = ValueTypesView().environment(\.injectedInt, 42)
        let view = try sut.inspect().find(ValueTypesView.self)
        XCTAssertEqual(try view.environment(\.injectedInt), 42)
        XCTAssertThrows(try view.environment(\.injectedBool),
                        "ValueTypesView does not have 'environment(Bool)' modifier")
    }

    func testTransformEnvironmentModifierIsIgnored() throws {
        let sut = ValueTypesView()
            .transformEnvironment(\.injectedInt, transform: { $0 += 1 })
        XCTAssertEqual(try sut.inspect().find(ViewType.Text.self).string(), "default 0 false none 0.000000")
    }

    func testTransformEnvironmentModifierDoesNotShadowTheValue() throws {
        let sut = ValueTypesView()
            .environment(\.injectedInt, 42)
            .transformEnvironment(\.injectedInt, transform: { $0 += 1 })
        XCTAssertEqual(try sut.inspect().find(ViewType.Text.self).string(), "default 42 false none 0.000000")
    }

    func testInjectionOfSystemEnvironmentValue() throws {
        let sut = SystemValueView().environment(\.layoutDirection, .rightToLeft)
        XCTAssertEqual(try sut.inspect().find(ViewType.Text.self).string(), "rtl")
    }
}

// MARK: - Test data

private struct Payload: Equatable {
    var number: Double = 0
    var padding: String = "pad"
    var flag: Bool = false
}

private class ReferenceValue {
    var value = "default"
}

private struct StringKey: EnvironmentKey { static var defaultValue: String { "default" } }
private struct IntKey: EnvironmentKey { static var defaultValue: Int { 0 } }
private struct BoolKey: EnvironmentKey { static var defaultValue: Bool { false } }
private struct OptionalKey: EnvironmentKey { static var defaultValue: String? { nil } }
private struct StructKey: EnvironmentKey { static var defaultValue: Payload { .init() } }
private struct ObjectKey: EnvironmentKey {
    static var defaultValue: ReferenceValue { .init() }
}

private extension EnvironmentValues {
    var injectedString: String {
        get { self[StringKey.self] } set { self[StringKey.self] = newValue }
    }
    var injectedInt: Int {
        get { self[IntKey.self] } set { self[IntKey.self] = newValue }
    }
    var injectedBool: Bool {
        get { self[BoolKey.self] } set { self[BoolKey.self] = newValue }
    }
    var injectedOptional: String? {
        get { self[OptionalKey.self] } set { self[OptionalKey.self] = newValue }
    }
    var injectedStruct: Payload {
        get { self[StructKey.self] } set { self[StructKey.self] = newValue }
    }
    var injectedObject: ReferenceValue {
        get { self[ObjectKey.self] } set { self[ObjectKey.self] = newValue }
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
private struct ValueTypesView: View {

    private var iVar1: Int8 = 0
    @Environment(\.injectedString) var string
    private var iVar2: Bool = false
    @Environment(\.injectedInt) var number
    @Environment(\.injectedBool) private var flag
    @State private var state: Int = 0
    @Environment(\.injectedOptional) private var optional
    @Environment(\.injectedStruct) private var structure
    private var iVar3: Int16 = 0

    var body: some View {
        Text("\(string) \(number) \(flag) \(optional ?? "none") \(structure.number)")
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
private struct InnerView: View {

    @Environment(\.injectedString) private var string
    @Environment(\.injectedString) private var duplicate

    var body: some View {
        Text(string + "|" + duplicate)
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
private struct OuterView: View {

    @Environment(\.injectedString) private var string

    var body: some View {
        VStack {
            Text(string)
            InnerView()
        }
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
private struct DuplicatedPropertiesView: View {

    @Environment(\.injectedString) private var string1
    private var iVar: Bool = false
    @Environment(\.injectedString) private var string2

    var body: some View {
        Text(string1 + "-" + string2)
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
private struct ReferenceTypeView: View {

    @Environment(\.injectedObject) var object

    var body: some View {
        Text(object.value)
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
private struct SystemValueView: View {

    @Environment(\.layoutDirection) private var direction

    var body: some View {
        Text(direction == .rightToLeft ? "rtl" : "ltr")
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
private struct InjectedModifier: ViewModifier {

    @Environment(\.injectedString) private var string

    func body(content: Self.Content) -> some View {
        VStack {
            Text("modifier: " + string)
            content
        }
    }
}
