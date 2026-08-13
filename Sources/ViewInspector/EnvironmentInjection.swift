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
        return injectEnvironment(object: environmentObject, into: entity)
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

    /// Injects an `Observable` object in the `@Environment(Type.self)` properties of the view.
    ///
    /// Such property stores either a `KeyPath` to a private `EnvironmentValues` entry,
    /// or the resolved value. SwiftUI crashes when it reads the unresolved `KeyPath`
    /// outside a hosted view, so the injection replaces `keyPath` with the `value` case.
    private static func injectEnvironment<T>(object: AnyObject, into entity: T) -> T {
        let keyPaths = environmentKeyPaths(for: object)
        guard keyPaths.count > 0 else { return entity }
        return Mirror(reflecting: entity).children.reduce(entity) { entity, child in
            guard let label = child.label,
                  let keyPath = try? Inspector.attribute(path: "content|keyPath", value: child.value,
                                                         type: AnyKeyPath.self),
                  keyPaths.contains(keyPath)
            else { return entity }
            return withUnsafeBytes(of: Unmanaged.passUnretained(keyPath).toOpaque()) { reference in
                var offset = 0
                while offset + EnvValue.structSize <= MemoryLayout<T>.size {
                    var copy = entity
                    withUnsafeMutableBytes(of: &copy) { bytes in
                        guard bytes[offset..<offset + reference.count].elementsEqual(reference),
                              bytes[offset + reference.count] == EnvValue.keyPathCase
                        else { return }
                        let rawPointer = bytes.baseAddress! + offset
                        rawPointer.assumingMemoryBound(to: EnvValue.Forgery.self).pointee = .init(object: object)
                    }
                    if (try? Inspector.attribute(path: label + "|content|value", value: copy)) != nil {
                        return copy
                    }
                    offset += MemoryLayout<UnsafeRawPointer>.alignment
                }
                return entity
            }
        }
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

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
internal struct EnvValue {
    /// `SwiftUI.Environment.Content` is a frozen enum with cases `keyPath` and `value`,
    /// each holding a pointer-sized payload followed by the case discriminator.
    static var keyPathCase: UInt8 { 0 }
    static var structSize: Int { MemoryLayout<UnsafeRawPointer>.size + 1 }

    struct Forgery {
        let object: AnyObject?
        let valueCase: UInt8 = 1
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
