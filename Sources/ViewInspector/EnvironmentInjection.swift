import SwiftUI

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
