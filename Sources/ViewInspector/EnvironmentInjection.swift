import SwiftUI

// MARK: - ViewInspectorConfig

/// Global configuration for ViewInspector behavior.
@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public enum ViewInspectorConfig {
    /// When enabled, `@Environment` properties are resolved to their default
    /// `EnvironmentValues` before body evaluation, preventing
    /// "Accessing Environment<T>'s value outside of being installed on a View" warnings.
    ///
    /// Defaults to the `VIEWINSPECTOR_RESOLVE_ENVIRONMENT` environment variable
    /// (set to "1", "YES", or "TRUE"). Can be overridden per-test via direct assignment.
    nonisolated(unsafe) public static var resolveEnvironmentValues: Bool = {
        if let value = ProcessInfo.processInfo.environment["VIEWINSPECTOR_RESOLVE_ENVIRONMENT"] {
            return value == "1" || value.uppercased() == "YES" || value.uppercased() == "TRUE"
        }
        return false
    }()

}

// MARK: - EnvironmentObject injection

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)

internal enum EnvironmentInjection {
    static func missingEnvironmentObjects(for entity: Any) -> [String] {
        let prefix = "SwiftUI.EnvironmentObject<"
        let mirror = Mirror(reflecting: entity)
        return mirror.children.compactMap {
            let fullName = Inspector.typeName(value: $0.value, namespaced: true)
            guard fullName.hasPrefix(prefix),
                  (try? Inspector.attribute(path: "_store|some", value: $0.value)) == nil,
                  let ivarName = $0.label
            else { return nil }
            var objName = Inspector.typeName(value: $0.value)
            objName = objName[18..<objName.count - 1]
            return "\(ivarName[1..<ivarName.count]): \(objName)"
        }
    }
    static func inject<T>(environmentObject: AnyObject, into entity: T) -> T {
        let type = "SwiftUI.EnvironmentObject<\(Inspector.typeName(value: environmentObject, namespaced: true))>"
        let mirror = Mirror(reflecting: entity)
        guard let label = mirror.children
                .first(where: {
                    Inspector.typeName(value: $0.value, namespaced: true) == type
                })?.label
        else { return entity }
        let envObjSize = EnvObject.structSize
        let viewSize = MemoryLayout<T>.size
        var offset = MemoryLayout<T>.stride - envObjSize
        let step = MemoryLayout<T>.alignment
        while offset + envObjSize > viewSize {
            offset -= step
        }
        return withUnsafeBytes(of: EnvObject.Forgery(object: nil)) { reference in
            while offset >= 0 {
                var copy = entity
                withUnsafeMutableBytes(of: &copy) { bytes in
                    guard bytes[offset..<offset + envObjSize].elementsEqual(reference)
                    else { return }
                    let rawPointer = bytes.baseAddress! + offset + EnvObject.seedOffset
                    let pointerToValue = rawPointer.assumingMemoryBound(to: Int.self)
                    pointerToValue.pointee = -1
                }
                if let seed = try? Inspector.attribute(path: label + "|_seed", value: copy, type: Int.self),
                   seed == -1 {
                    withUnsafeMutableBytes(of: &copy) { bytes in
                        let rawPointer = bytes.baseAddress! + offset
                        let pointerToValue = rawPointer.assumingMemoryBound(to: EnvObject.Forgery.self)
                        pointerToValue.pointee = .init(object: environmentObject)
                    }
                    return copy
                }
                offset -= step
            }
            return entity
        }
    }
}

// MARK: - @Environment resolution

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
internal extension EnvironmentInjection {

    /// Builds an `EnvironmentValues` by applying tracked `.environment()` modifiers
    /// on top of SwiftUI defaults. This allows test code like
    /// `MyView().environment(\.colorScheme, .dark)` to be reflected during resolution.
    static func environmentValues(from modifiers: [EnvironmentModifier]) -> EnvironmentValues {
        var env = EnvironmentValues()
        for modifier in modifiers {
            guard let keyPath = try? modifier.keyPath(),
                  let value = try? modifier.value(),
                  let applicable = keyPath as? AnyWritableEnvironmentKeyPath
            else { continue }
            _ = applicable._apply(value: value, to: &env)
        }
        return env
    }

    /// Resolves `@Environment` properties from `.keyPath` state to `.value` state,
    /// preventing "Accessing Environment<T>'s value outside of being installed on a View" warnings.
    ///
    /// - Parameter environmentValues: The `EnvironmentValues` to resolve from. Defaults to
    ///   `EnvironmentValues()` (SwiftUI defaults). Pass a customized instance to override
    ///   specific values, including custom `EnvironmentKey` types.
    static func resolveEnvironmentProperties<T>(
        in entity: T,
        using environmentValues: EnvironmentValues = EnvironmentValues()
    ) -> T {
        guard ViewInspectorConfig.resolveEnvironmentValues else { return entity }

        let prefix = "SwiftUI.Environment<"
        let mirror = Mirror(reflecting: entity)
        var copy = entity

        for child in mirror.children {
            let typeName = Inspector.typeName(value: child.value, namespaced: true)
            guard typeName.hasPrefix(prefix), let label = child.label else { continue }

            // Use EnvironmentResolvable protocol to resolve with correct generic context.
            // The protocol returns both the original bytes (from the real generic type,
            // NOT the existential container) and the resolved .value state bytes.
            guard let resolvable = child.value as? any EnvironmentResolvable,
                  let resolution = resolvable._resolve(using: environmentValues)
            else { continue }

            copy = writeFieldBytes(
                resolution.resolvedBytes,
                referenceBytes: resolution.originalBytes,
                fieldSize: resolution.fieldSize,
                matchSize: resolution.matchSize,
                label: label,
                into: copy
            )
        }
        return copy
    }

    /// Finds a field in the parent struct by byte-matching then overwrites with new bytes.
    ///
    /// Only `matchSize` bytes are compared for field identification (the keypath pointer).
    /// This is necessary because Mirror-extracted copies of @Environment may have different
    /// "spare" payload bytes when `sizeof(Value) > sizeof(KeyPath)` — the enum's payload
    /// area is `max(sizeof(keyPath), sizeof(Value))`, and bytes beyond the keypath pointer
    /// in the `.keyPath` case are uninitialized/undefined.
    ///
    /// Writing the resolved `.value` state bytes into a Swift-managed copy is safe because
    /// `@Environment`'s destroy checks the enum tag: tag=1 (.value) destroys the value
    /// payload (which we already verified is non-reference), so no keypath release occurs.
    private static func writeFieldBytes<T>(
        _ newBytes: [UInt8],
        referenceBytes: [UInt8],
        fieldSize: Int,
        matchSize: Int,
        label: String,
        into entity: T
    ) -> T {
        let entitySize = MemoryLayout<T>.size
        let entityAlignment = MemoryLayout<T>.alignment
        // Scan forward from offset 0 in alignment-sized steps.
        // @Environment fields are aligned to their internal alignment (pointer-sized),
        // which matches the parent struct's alignment.
        let step = max(entityAlignment, 1)

        var offset = 0
        while offset + fieldSize <= entitySize {
            var matches = false
            withUnsafeBytes(of: entity) { bytes in
                guard offset + matchSize <= bytes.count else { return }
                // Only compare the keypath pointer bytes — these are unique per field
                // and guaranteed to be identical between Mirror copy and original.
                matches = Array(bytes[offset..<offset + matchSize])
                    == Array(referenceBytes.prefix(matchSize))
            }

            if matches {
                // Overwrite the matched field with the resolved .value state bytes.
                var result = entity
                withUnsafeMutableBytes(of: &result) { bytes in
                    for i in 0..<min(fieldSize, newBytes.count) {
                        (bytes.baseAddress! + offset + i)
                            .assumingMemoryBound(to: UInt8.self).pointee = newBytes[i]
                    }
                }
                return result
            }
            offset += step
        }
        return entity
    }
}

/// Result of resolving an @Environment field.
@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
internal struct EnvironmentResolution {
    /// The real size of the @Environment<Value> struct (not the existential container).
    let fieldSize: Int
    /// How many bytes from the start to compare for field identification.
    /// This is the keypath pointer size — only these bytes are guaranteed to be identical
    /// between a Mirror-extracted copy and the original in the parent struct.
    /// When `sizeof(Value) > sizeof(KeyPath)`, the `.keyPath` enum case has spare payload
    /// bytes that Mirror may not preserve, causing full-field comparison to fail.
    let matchSize: Int
    /// The original bytes of the @Environment in .keyPath state (real struct bytes).
    let originalBytes: [UInt8]
    /// The bytes of the @Environment in .value state after resolution.
    let resolvedBytes: [UInt8]
}

/// Protocol for type-erased @Environment resolution.
/// Environment<Value> conforms to this, allowing us to call generic code
/// with the correct Value type at runtime.
@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
internal protocol EnvironmentResolvable {
    /// Resolves this @Environment using the given `EnvironmentValues` and returns the resolution
    /// data including the real struct size and bytes (not existential container bytes).
    func _resolve(using environmentValues: EnvironmentValues) -> EnvironmentResolution?
    /// Returns the raw bytes of this @Environment struct (real generic type, not existential).
    func _originalBytes() -> [UInt8]
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension Environment: EnvironmentResolvable {
    func _originalBytes() -> [UInt8] {
        withUnsafeBytes(of: self) { Array($0) }
    }

    func _resolve(using environmentValues: EnvironmentValues) -> EnvironmentResolution? {
        // Check if already in .value state
        let mirror = Mirror(reflecting: self)
        guard let contentChild = mirror.children.first(where: { $0.label == "content" }) else {
            return nil
        }
        let contentMirror = Mirror(reflecting: contentChild.value)
        guard let enumCase = contentMirror.children.first,
              enumCase.label != ".value" // Already resolved
        else { return nil }

        // Extract the keyPath
        guard let keyPath = enumCase.value as? KeyPath<EnvironmentValues, Value> else {
            return nil
        }

        // Resolve from the provided EnvironmentValues
        let resolvedValue = environmentValues[keyPath: keyPath]

        // Skip resolution for Value types that contain references (closures, objects).
        // Raw byte manipulation of reference types breaks ARC and causes crashes.
        guard !containsReferenceTypes(resolvedValue) else { return nil }

        // Get the REAL size and bytes of this @Environment<Value> struct
        // (not the existential container that Mirror wraps it in)
        let realSize = MemoryLayout<Self>.size
        let keyPathSize = MemoryLayout<KeyPath<EnvironmentValues, Value>>.size
        let originalBytes: [UInt8] = withUnsafeBytes(of: self) { Array($0) }
        let resolvedBytes = buildValueStateBytes(resolvedValue)

        return EnvironmentResolution(
            fieldSize: realSize,
            matchSize: keyPathSize,
            originalBytes: originalBytes,
            resolvedBytes: resolvedBytes
        )
    }

    /// Checks whether a value contains reference types (classes, closures, etc.)
    /// that would be unsafe to manipulate via raw bytes.
    private func containsReferenceTypes(_ value: Any) -> Bool {
        // Class instances
        if type(of: value) is AnyClass { return true }
        // Check Mirror children recursively (1 level deep)
        let mirror = Mirror(reflecting: value)
        for child in mirror.children {
            if type(of: child.value) is AnyClass { return true }
            // Function/closure types show up as "() -> ()" etc.
            let typeName = String(describing: type(of: child.value))
            if typeName.contains("->") { return true }
            // Optional wrapping a reference type
            let childMirror = Mirror(reflecting: child.value)
            if childMirror.displayStyle == .optional {
                for inner in childMirror.children {
                    if type(of: inner.value) is AnyClass { return true }
                    let innerName = String(describing: type(of: inner.value))
                    if innerName.contains("->") { return true }
                }
            }
        }
        return false
    }

    /// Constructs the raw bytes of this @Environment<Value> in `.value(v)` state.
    ///
    /// @Environment<Value> is @frozen and contains a single `content` field of type Content,
    /// which is an enum:
    ///   case keyPath(KeyPath<EnvironmentValues, Value>)  — tag 0
    ///   case value(Value)                                — tag 1
    ///
    /// For multi-payload enums, Swift uses:
    ///   [payload area: max(sizeof(case0), sizeof(case1)) bytes][tag: 1 byte]
    private func buildValueStateBytes(_ value: Value) -> [UInt8] {
        // Use raw memory to avoid ARC issues. Creating `var copy = self` and zeroing
        // its bytes would corrupt reference-counted fields (e.g. the keypath pointer),
        // causing crashes when `copy` is deallocated.
        let size = MemoryLayout<Self>.size
        let buffer = UnsafeMutableRawBufferPointer.allocate(
            byteCount: size, alignment: MemoryLayout<Self>.alignment)
        defer { buffer.deallocate() }

        memset(buffer.baseAddress!, 0, size)

        // Write value payload at the start
        withUnsafeBytes(of: value) { valueBytes in
            let count = min(valueBytes.count, size)
            if count > 0 {
                buffer.baseAddress!.copyMemory(from: valueBytes.baseAddress!, byteCount: count)
            }
        }

        // Write tag = 1 (for .value case) after the payload area
        let keyPathPayloadSize = MemoryLayout<KeyPath<EnvironmentValues, Value>>.size
        let valuePayloadSize = MemoryLayout<Value>.size
        let tagOffset = max(keyPathPayloadSize, valuePayloadSize)
        if tagOffset < size {
            (buffer.baseAddress! + tagOffset).assumingMemoryBound(to: UInt8.self).pointee = 1
        }

        return Array(buffer)
    }
}

// MARK: - ViewHosting environment defaults

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
internal extension EnvironmentInjection {

    /// Wraps a view with explicit default environment values to prevent
    /// "Accessing Environment<T>'s value outside of being installed on a View" warnings
    /// when the view is hosted via UIHostingController in tests.
    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
    static func viewWithResolvedEnvironment<V: View>(_ view: V) -> some View {
        view
            .environment(\.isEnabled, true)
            .environment(\.dynamicTypeSize, .large)
            .environment(\.redactionReasons, [])
    }

    /// Fallback for older OS versions — resolves only iOS 13+ environment keys.
    static func viewWithResolvedEnvironmentBase<V: View>(_ view: V) -> some View {
        view
            .environment(\.isEnabled, true)
    }
}

// MARK: - Type-erased environment keyPath application

/// Protocol for applying a type-erased WritableKeyPath + value to EnvironmentValues.
/// WritableKeyPath<EnvironmentValues, T> conforms to this, enabling generic application
/// without a fixed list of supported types.
@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
internal protocol AnyWritableEnvironmentKeyPath {
    func _apply(value: Any, to env: inout EnvironmentValues) -> Bool
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension WritableKeyPath: AnyWritableEnvironmentKeyPath where Root == EnvironmentValues {
    internal func _apply(value: Any, to env: inout EnvironmentValues) -> Bool {
        guard let typedValue = value as? Value else { return false }
        env[keyPath: self] = typedValue
        return true
    }
}

// MARK: - EnvObject (EnvironmentObject injection support)

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
internal struct EnvObject {
    static var seedOffset: Int { 8 }
    static var structSize: Int { 16 }

    struct Forgery {
        let object: AnyObject?
        let seed: Int = 0
    }
}

internal extension String {
    subscript(intRange: Range<Int>) -> String {
        let range = Range(uncheckedBounds: (lower: max(0, min(count, intRange.lowerBound)),
                                            upper: min(count, max(0, intRange.upperBound))))
        let start = index(startIndex, offsetBy: range.lowerBound)
        let end = index(start, offsetBy: range.upperBound - range.lowerBound)
        return String(self[start ..< end])
    }
}
