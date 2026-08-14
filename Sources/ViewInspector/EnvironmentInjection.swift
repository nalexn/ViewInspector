import SwiftUI
import Observation

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
        let entity = injectEnvironmentObject(environmentObject, into: entity)
        // An `Observable` object is injected the same way as any other environment value,
        // using the key paths SwiftUI assigns to `@Environment(Type.self)`.
        let values = environmentKeyPaths(for: environmentObject)
            .map { (keyPath: $0, value: environmentObject as Any) }
        return inject(environmentValues: values, into: entity)
    }

    private static func injectEnvironmentObject<T>(_ environmentObject: AnyObject, into entity: T) -> T {
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

    /// Injects the values of the enclosing `.environment(keyPath, value)` modifiers in the
    /// `@Environment(keyPath)` properties of the view, so that the view's `body` reads
    /// the injected value instead of the `EnvironmentKey`'s default one.
    static func inject<T>(environmentValues: [EnvironmentValueInjection], into entity: T) -> T {
        guard !environmentValues.isEmpty else { return entity }
        let wrappers = Mirror(reflecting: entity).children
            .compactMap { child -> (keyPath: AnyKeyPath, wrapper: EnvironmentPropertyWrapper)? in
                guard let wrapper = child.value as? EnvironmentPropertyWrapper,
                      let keyPath = wrapper.injectionKeyPath
                else { return nil }
                return (keyPath, wrapper)
            }
        guard !wrappers.isEmpty else { return entity }
        var copy = entity
        var injectedKeyPaths: [AnyKeyPath] = []
        for (keyPath, wrapper) in wrappers where !injectedKeyPaths.contains(keyPath) {
            injectedKeyPaths.append(keyPath)
            let candidates = environmentValues.filter { $0.keyPath == keyPath }.map { $0.value }
            guard !candidates.isEmpty else { continue }
            // Properties declared with the same key path share the byte pattern
            // and are all expected to receive the value.
            let expectedMatches = wrappers.filter { $0.keyPath == keyPath }.count
            withUnsafeMutableBytes(of: &copy) { bytes in
                wrapper.injectValue(candidates: candidates, into: bytes, expectedMatches: expectedMatches)
            }
        }
        return copy
    }

    /// The key paths SwiftUI uses for referencing the object in `EnvironmentValues`, for both
    /// the plain and the optional `@Environment(Type.self)`. Empty for non-`Observable` objects.
    static func environmentKeyPaths(for object: AnyObject) -> [AnyKeyPath] {
        guard #available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *),
              let object = object as? any Observable & AnyObject
        else { return [] }
        return environmentKeyPaths(of: object)
    }

    @available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
    private static func environmentKeyPaths<T>(of object: T) -> [AnyKeyPath]
    where T: Observable & AnyObject {
        return [Environment(T.self) as Any, Environment<T?>(T.self) as Any].compactMap {
            try? Inspector.attribute(path: "content|keyPath", value: $0, type: AnyKeyPath.self)
        }
    }
}

// MARK: - Environment value injection

internal typealias EnvironmentValueInjection = (keyPath: AnyKeyPath, value: Any)

/// Replica of the private `SwiftUI.Environment.Content` enum.
///
/// Swift lays out the cases of two structurally identical enums identically,
/// which is verified at runtime before the injection takes place.
@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
internal enum EnvironmentContent<Value> {
    case keyPath(KeyPath<EnvironmentValues, Value>)
    case value(Value)
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
internal protocol EnvironmentPropertyWrapper {
    /// The key path the property reads the value from,
    /// or `nil` when it already holds a resolved value.
    var injectionKeyPath: AnyKeyPath? { get }

    /// Replaces the `keyPath` case of every matching property found in `bytes` with the
    /// innermost of the `candidates` that matches the property's value type.
    ///
    /// The properties are located by the byte pattern of the key path reference and the
    /// enum's case discriminator. The injection is skipped altogether unless the number of
    /// the matches is the expected one, or if the layout does not meet the expectations.
    func injectValue(candidates: [Any], into bytes: UnsafeMutableRawBufferPointer, expectedMatches: Int)
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension SwiftUI.Environment: EnvironmentPropertyWrapper {

    var injectionKeyPath: AnyKeyPath? {
        return try? Inspector.attribute(path: "content|keyPath", value: self, type: AnyKeyPath.self)
    }

    func injectValue(candidates: [Any], into bytes: UnsafeMutableRawBufferPointer, expectedMatches: Int) {
        // A `transformEnvironment` modifier provides a transform closure instead of a value,
        // and is skipped by this type check.
        guard let value = candidates.reversed().lazy.compactMap({ $0 as? Value }).first,
              let keyPath = injectionKeyPath as? KeyPath<EnvironmentValues, Value>,
              let pattern = Pattern(wrapper: self, keyPath: keyPath)
        else { return }
        let offsets = pattern.offsets(in: bytes)
        guard offsets.count == expectedMatches else { return }
        let source = UnsafeMutablePointer<EnvironmentContent<Value>>.allocate(capacity: 1)
        defer { source.deallocate() }
        offsets.forEach { offset in
            // Every destination receives its own strong reference to the value,
            // and the replaced key path reference is released.
            source.initialize(to: .value(value))
            let destination = (bytes.baseAddress! + offset).assumingMemoryBound(to: Self.self)
            destination.deinitialize(count: 1)
            UnsafeMutableRawPointer(destination).copyMemory(from: source, byteCount: pattern.size)
        }
    }

    /// The byte signature of an `Environment<Value>` in the `keyPath` case.
    private struct Pattern {
        let reference: [UInt8]
        let discriminator: UInt8
        let size: Int

        /// Fails unless `EnvironmentContent<Value>` matches the layout of `Environment<Value>`:
        /// a key path reference at the front, followed by the case discriminator at the back.
        init?(wrapper: SwiftUI.Environment<Value>, keyPath: KeyPath<EnvironmentValues, Value>) {
            size = MemoryLayout<SwiftUI.Environment<Value>>.size
            guard MemoryLayout<EnvironmentContent<Value>>.size == size,
                  MemoryLayout<EnvironmentContent<Value>>.alignment
                    == MemoryLayout<SwiftUI.Environment<Value>>.alignment,
                  size > MemoryLayout<UnsafeRawPointer>.size
            else { return nil }
            let wrapperBytes = withUnsafeBytes(of: wrapper) { Array($0) }
            let replicaBytes = withUnsafeBytes(of: EnvironmentContent<Value>.keyPath(keyPath)) { Array($0) }
            reference = Array(wrapperBytes.prefix(MemoryLayout<UnsafeRawPointer>.size))
            discriminator = wrapperBytes[size - 1]
            guard replicaBytes.prefix(reference.count).elementsEqual(reference),
                  replicaBytes[size - 1] == discriminator
            else { return nil }
        }

        func offsets(in bytes: UnsafeMutableRawBufferPointer) -> [Int] {
            let step = MemoryLayout<SwiftUI.Environment<Value>>.alignment
            return stride(from: 0, through: max(0, bytes.count - size), by: step).filter { offset in
                return offset + size <= bytes.count
                    && bytes[offset..<offset + reference.count].elementsEqual(reference)
                    && bytes[offset + size - 1] == discriminator
            }
        }
    }
}

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
