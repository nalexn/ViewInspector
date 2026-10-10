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

    func testInjectionNeverWritesIntoFieldsThatLookLikeTheProperty() throws {
        let keyPath = \EnvironmentValues.injectedStruct
        let sut = SignatureDecoysFixture(
            before: .keyPath(keyPath), target: Environment(keyPath), after: .keyPath(keyPath))
        let result = EnvironmentInjection.inject(
            environmentValues: [(keyPath, Payload(number: 7.0))], into: sut)
        guard case .keyPath(let before) = result.before, case .keyPath(let after) = result.after else {
            return XCTFail("a field that is not an Environment property was replaced by an injected value")
        }
        XCTAssertEqual(before, keyPath, "the field before the property is untouched")
        XCTAssertEqual(after, keyPath, "the field after the property is untouched")
        XCTAssertEqual(
            result.target.injectionKeyPath, keyPath,
            "the property is not injected either, as nothing tells it from the fields that look like it")
    }

    func testInjectionIgnoresSignatureAroundAnotherProperty() throws {
        let keyPath = \EnvironmentValues.injectedStruct
        let target = Environment(keyPath)
        let sut = OverlappingSignatureFixture(
            reference: withUnsafeBytes(of: target) { $0.load(as: UInt.self) },
            string: Environment(\EnvironmentValues.injectedString),
            tag: withUnsafeBytes(of: target) { $0[$0.count - 1] },
            target: target)
        XCTAssertEqual(
            MemoryLayout<OverlappingSignatureFixture>.offset(of: \.reference), 0,
            "the key path reference is the first thing in the view")
        XCTAssertEqual(
            MemoryLayout<OverlappingSignatureFixture>.offset(of: \.tag), MemoryLayout<Environment<Payload>>.size - 1,
            "the case byte is the last byte of a property-sized window at the front, around the string property")
        XCTAssertEqual(
            matches(of: target, in: sut), [0, MemoryLayout<OverlappingSignatureFixture>.offset(of: \.target) ?? -1],
            "the signature is found at the front, around the string property, and at the property")
        let result = EnvironmentInjection.inject(
            environmentValues: [(keyPath, Payload(number: 7.0))], into: sut)
        XCTAssertEqual(
            result.target.wrappedValue.number, 7.0,
            "the property receives the injected value although its signature also appears around another property")
        XCTAssertEqual(result.reference, sut.reference, "the stray key path reference is untouched")
        XCTAssertEqual(result.tag, sut.tag, "the stray case byte is untouched")
        XCTAssertEqual(
            result.string.injectionKeyPath, \EnvironmentValues.injectedString,
            "the property inside the false window is untouched")
    }

    func testInjectionIntoSeveralPropertiesIgnoresSignatureAroundAnotherProperty() throws {
        let keyPath = \EnvironmentValues.injectedStruct
        let target = Environment(keyPath)
        let sut = SeveralTargetsFixture(
            reference: withUnsafeBytes(of: target) { $0.load(as: UInt.self) },
            string: Environment(\EnvironmentValues.injectedString),
            tag: withUnsafeBytes(of: target) { $0[$0.count - 1] },
            first: target, second: target)
        let layout = MemoryLayout<SeveralTargetsFixture>.self
        XCTAssertEqual(
            matches(of: target, in: sut), [0, layout.offset(of: \.first) ?? -1, layout.offset(of: \.second) ?? -1],
            "the signature is found at the front, around the string property, and at both properties")
        let result = EnvironmentInjection.inject(
            environmentValues: [(keyPath, Payload(number: 7.0))], into: sut)
        XCTAssertEqual(result.first.wrappedValue.number, 7.0, "the first property is injected")
        XCTAssertEqual(result.second.wrappedValue.number, 7.0, "the second property is injected")
        XCTAssertEqual(result.reference, sut.reference, "the stray key path reference is untouched")
        XCTAssertEqual(result.tag, sut.tag, "the stray case byte is untouched")
    }

    func testInjectionNeverWritesIntoLookAlikesOfSeveralAmbiguousProperties() throws {
        let stringKeyPath = \EnvironmentValues.injectedString
        let structKeyPath = \EnvironmentValues.injectedStruct
        let string = Environment(stringKeyPath)
        let payload = Environment(structKeyPath)
        let sut = MutualLookAlikesFixture(
            payloadReference: withUnsafeBytes(of: payload) { $0.load(as: UInt.self) },
            string: string,
            payloadTag: withUnsafeBytes(of: payload) { $0[$0.count - 1] },
            payload: payload,
            stringReference: withUnsafeBytes(of: string) { $0.load(as: UInt.self) },
            filler: 0,
            stringTag: withUnsafeBytes(of: string) { $0[$0.count - 1] })
        let layout = MemoryLayout<MutualLookAlikesFixture>.self
        XCTAssertEqual(
            matches(of: payload, in: sut), [0, layout.offset(of: \.payload) ?? -1],
            "the payload signature is found at the front, around the string property, and at the property")
        XCTAssertEqual(
            matches(of: string, in: sut), [layout.offset(of: \.string) ?? -1, layout.offset(of: \.stringReference) ?? -1],
            "the string signature is found at the property and in the stray fields at the end")
        let result = EnvironmentInjection.inject(
            environmentValues: [(stringKeyPath, "injected"), (structKeyPath, Payload(number: 7.0))], into: sut)
        XCTAssertEqual(result.payloadReference, sut.payloadReference, "the payload look-alike is untouched")
        XCTAssertEqual(result.payloadTag, sut.payloadTag, "the payload look-alike is untouched")
        XCTAssertEqual(result.stringReference, sut.stringReference, "the string look-alike is untouched")
        XCTAssertEqual(result.filler, sut.filler, "the string look-alike is untouched")
        XCTAssertEqual(result.stringTag, sut.stringTag, "the string look-alike is untouched")
    }

    func testInjectionLocatesPropertiesOneAfterAnother() throws {
        let stringKeyPath = \EnvironmentValues.injectedString
        let structKeyPath = \EnvironmentValues.injectedStruct
        let bigKeyPath = \EnvironmentValues.injectedBig
        let string = Environment(stringKeyPath)
        let payload = Environment(structKeyPath)
        let big = Environment(bigKeyPath)
        let sut = ChainedLookAlikesFixture(
            bigReference: withUnsafeBytes(of: big) { $0.load(as: UInt.self) },
            payload: payload,
            filler: (0, 0, 0, 0, 0),
            bigTag: withUnsafeBytes(of: big) { $0[$0.count - 1] },
            big: big,
            payloadReference: withUnsafeBytes(of: payload) { $0.load(as: UInt.self) },
            string: string,
            payloadTag: withUnsafeBytes(of: payload) { $0[$0.count - 1] })
        let layout = MemoryLayout<ChainedLookAlikesFixture>.self
        XCTAssertEqual(
            matches(of: string, in: sut), [layout.offset(of: \.string) ?? -1],
            "the string property is the only thing that has the string signature")
        XCTAssertEqual(
            matches(of: payload, in: sut), [layout.offset(of: \.payload) ?? -1, layout.offset(of: \.payloadReference) ?? -1],
            "the payload signature is found at the property and around the string property")
        XCTAssertEqual(
            matches(of: big, in: sut), [0, layout.offset(of: \.big) ?? -1],
            "the big signature is found at the front, around the payload property, and at the property")
        let result = EnvironmentInjection.inject(
            environmentValues: [
                (stringKeyPath, "injected"), (structKeyPath, Payload(number: 7.0)), (bigKeyPath, Big(first: 3))
            ], into: sut)
        XCTAssertEqual(result.string.wrappedValue, "injected", "the string property is injected")
        XCTAssertEqual(result.payload.wrappedValue.number, 7.0, "the payload property is injected")
        XCTAssertEqual(result.big.wrappedValue.first, 3, "the big property is injected")
        XCTAssertEqual(result.bigReference, sut.bigReference, "the big look-alike is untouched")
        XCTAssertEqual(result.bigTag, sut.bigTag, "the big look-alike is untouched")
        XCTAssertEqual(result.payloadReference, sut.payloadReference, "the payload look-alike is untouched")
        XCTAssertEqual(result.payloadTag, sut.payloadTag, "the payload look-alike is untouched")
    }

    func testWrapperHeldByAnotherTypeIsNotAPropertyOfTheView() throws {
        let stringKeyPath = \EnvironmentValues.injectedString
        let structKeyPath = \EnvironmentValues.injectedStruct
        let string = Environment(stringKeyPath)
        let payload = Environment(structKeyPath)
        let sut = BoxedWrapperFixture(
            payloadReference: withUnsafeBytes(of: payload) { $0.load(as: UInt.self) },
            string: string,
            payloadTag: withUnsafeBytes(of: payload) { $0[$0.count - 1] },
            stringReference: withUnsafeBytes(of: string) { $0.load(as: UInt.self) },
            filler: 0,
            stringTag: withUnsafeBytes(of: string) { $0[$0.count - 1] },
            boxed: payload)
        let layout = MemoryLayout<BoxedWrapperFixture>.self
        XCTAssertEqual(
            matches(of: string, in: sut), [layout.offset(of: \.string) ?? -1, layout.offset(of: \.stringReference) ?? -1],
            "the string signature is found at the property and in the stray fields")
        XCTAssertEqual(
            matches(of: payload, in: sut), [0],
            "the payload signature is found only around the string property, the wrapper in the `Any` is elsewhere")
        let result = EnvironmentInjection.inject(
            environmentValues: [(stringKeyPath, "injected")], into: sut)
        XCTAssertEqual(result.stringReference, sut.stringReference, "the string look-alike is untouched")
        XCTAssertEqual(result.filler, sut.filler, "the string look-alike is untouched")
        XCTAssertEqual(result.stringTag, sut.stringTag, "the string look-alike is untouched")
        XCTAssertEqual(
            result.string.injectionKeyPath, stringKeyPath,
            "the string property is not injected, as nothing tells it from its look-alike")
    }

    func testInjectionDoesNotTrustCustomMirrorToDiscardLookAlikes() throws {
        let stringKeyPath = \EnvironmentValues.injectedString
        let structKeyPath = \EnvironmentValues.injectedStruct
        let string = Environment(stringKeyPath)
        let payload = Environment(structKeyPath)
        let sut = FabricatedMirrorFixture(
            payloadReference: withUnsafeBytes(of: payload) { $0.load(as: UInt.self) },
            string: string,
            payloadTag: withUnsafeBytes(of: payload) { $0[$0.count - 1] },
            stringReference: withUnsafeBytes(of: string) { $0.load(as: UInt.self) },
            filler: 0,
            stringTag: withUnsafeBytes(of: string) { $0[$0.count - 1] })
        let layout = MemoryLayout<FabricatedMirrorFixture>.self
        XCTAssertEqual(
            matches(of: string, in: sut), [layout.offset(of: \.string) ?? -1, layout.offset(of: \.stringReference) ?? -1],
            "the string signature is found at the property and in the stray fields")
        XCTAssertEqual(
            matches(of: payload, in: sut), [0],
            "the payload signature is found only around the string property, the property the mirror reports is made up")
        let result = EnvironmentInjection.inject(
            environmentValues: [(stringKeyPath, "injected")], into: sut)
        XCTAssertEqual(result.stringReference, sut.stringReference, "the string look-alike is untouched")
        XCTAssertEqual(result.filler, sut.filler, "the string look-alike is untouched")
        XCTAssertEqual(result.stringTag, sut.stringTag, "the string look-alike is untouched")
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

    func testInjectionIntoPropertiesWithEqualKeyPathsThatAreDifferentObjects() throws {
        let literal = \EnvironmentValues.injectedStruct.number
        let composed = (\EnvironmentValues.injectedStruct).appending(path: \Payload.number)
        XCTAssertTrue(literal == composed, "the key paths are equal")
        XCTAssertFalse(literal === composed, "but they are different objects")
        let sut = DistinctKeyPathsFixture(first: Environment(literal), second: Environment(composed))
        let result = EnvironmentInjection.inject(environmentValues: [(literal, 7.0)], into: sut)
        XCTAssertEqual(result.first.wrappedValue, 7.0, "the property declared with the key path of the value")
        XCTAssertEqual(result.second.wrappedValue, 7.0, "the property declared with an equal key path")
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

    /// The offsets of the aligned windows of `view` that begin with the key path reference of `property`
    /// and end with its case byte, which is what the injection looks for.
    private func matches<Value, View>(of property: Environment<Value>, in view: View) -> [Int] {
        let size = MemoryLayout<Environment<Value>>.size
        let reference = MemoryLayout<UnsafeRawPointer>.size
        let pattern = withUnsafeBytes(of: property) { Array($0) }
        return withUnsafeBytes(of: view) { bytes in
            stride(from: 0, through: bytes.count - size, by: MemoryLayout<Environment<Value>>.alignment).filter {
                bytes[$0..<$0 + reference].elementsEqual(pattern[0..<reference])
                    && bytes[$0 + size - 1] == pattern[size - 1]
            }
        }
    }
}

// MARK: - Test data

private struct Payload: Equatable {
    var number: Double = 0
    var padding: String = "pad"
    var flag: Bool = false
}

/// 80 bytes, so that `Environment<Big>` can contain the other properties in a window.
private struct Big {
    var first: UInt = 0
    var others: (UInt, UInt, UInt, UInt, UInt, UInt, UInt, UInt, UInt) = (0, 0, 0, 0, 0, 0, 0, 0, 0)
}

private class ReferenceValue {
    var value = "default"
}

private struct StringKey: EnvironmentKey { static var defaultValue: String { "default" } }
private struct IntKey: EnvironmentKey { static var defaultValue: Int { 0 } }
private struct BoolKey: EnvironmentKey { static var defaultValue: Bool { false } }
private struct OptionalKey: EnvironmentKey { static var defaultValue: String? { nil } }
private struct StructKey: EnvironmentKey { static var defaultValue: Payload { .init() } }
private struct BigKey: EnvironmentKey { static var defaultValue: Big { .init() } }
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
    var injectedBig: Big {
        get { self[BigKey.self] } set { self[BigKey.self] = newValue }
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

/// Has two fields with the byte signature of the `Environment<Payload>` property (the key path reference
/// and the case) before and after the only real property. Only the declared types of the fields tell them
/// apart, and the bytes do not, so the injection can only leave the property alone and not write into the fields.
@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
private struct SignatureDecoysFixture {
    var before: EnvironmentContent<Payload>
    var target: Environment<Payload>
    var after: EnvironmentContent<Payload>
}

/// The key path reference and the case byte of the `Environment<Payload>` property sit in stray fields
/// around the `Environment<String>` property, so that a window the size of the payload property at the front
/// has its signature, as it happens by chance in `ValueTypesView` with a padding residue and a `Bool`.
@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
private struct OverlappingSignatureFixture {
    var reference: UInt
    var string: Environment<String>
    var tag: UInt8
    var target: Environment<Payload>
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
private struct SeveralTargetsFixture {
    var reference: UInt
    var string: Environment<String>
    var tag: UInt8
    var first: Environment<Payload>
    var second: Environment<Payload>
}

/// Each of the two properties has a look-alike made of stray fields: the one of the payload property contains
/// the string property, the one of the string property is at the end. Neither of the two is found exactly
/// as many times as it has properties.
@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
private struct MutualLookAlikesFixture {
    var payloadReference: UInt
    var string: Environment<String>
    var payloadTag: UInt8
    var payload: Environment<Payload>
    var stringReference: UInt
    var filler: UInt
    var stringTag: UInt8
}

/// The string property is found exactly once, its window is in the middle of the look-alike of the payload
/// property, and the payload property is in the middle of the look-alike of the big property.
@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
private struct ChainedLookAlikesFixture {
    var bigReference: UInt
    var payload: Environment<Payload>
    var filler: (UInt, UInt, UInt, UInt, UInt)
    var bigTag: UInt8
    var big: Environment<Big>
    var payloadReference: UInt
    var string: Environment<String>
    var payloadTag: UInt8
}

/// As `MutualLookAlikesFixture` without the payload property, which the mirror finds in the `Any`,
/// where it is in a box outside the view.
@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
private struct BoxedWrapperFixture {
    var payloadReference: UInt
    var string: Environment<String>
    var payloadTag: UInt8
    var stringReference: UInt
    var filler: UInt
    var stringTag: UInt8
    var boxed: Any
}

/// As `BoxedWrapperFixture`, but the mirror makes up a payload property.
@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
private struct FabricatedMirrorFixture: CustomReflectable {
    var payloadReference: UInt
    var string: Environment<String>
    var payloadTag: UInt8
    var stringReference: UInt
    var filler: UInt
    var stringTag: UInt8

    var customMirror: Mirror {
        Mirror(self, children: ["string": string, "payload": Environment(\EnvironmentValues.injectedStruct)])
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
private struct DistinctKeyPathsFixture {
    var first: Environment<Double>
    var second: Environment<Double>
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
