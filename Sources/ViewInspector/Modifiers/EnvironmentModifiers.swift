import SwiftUI

// MARK: - Environment Modifiers

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView {

    func environment<T>(_ keyPath: WritableKeyPath<EnvironmentValues, T>) throws -> T {
        let environmentValues = EnvironmentValues()
        let defaultValue = environmentValues[keyPath: keyPath]
        let reference = EmptyView().environment(keyPath, defaultValue)
        let keyPath = try Inspector.environmentKeyPath(T.self, reference)
        return try environmentModifier(keyPath: keyPath, call: "")
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
internal extension InspectableView {
    func environmentModifier<T>(keyPath reference: WritableKeyPath<EnvironmentValues, T>, call: String) throws -> T {
        let name = Inspector.typeName(type: T.self)
        return try modifierAttribute(modifierLookup: { modifier -> Bool in
            guard modifier.modifierType == "_EnvironmentKeyWritingModifier<\(name)>",
                  let keyPath = try? Inspector.environmentKeyPath(T.self, modifier)
            else { return false }
            return keyPath == reference
        }, path: "modifier|value", type: T.self, call: call)
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
internal extension Inspector {
    static func environmentKeyPath<T>(_ type: T.Type, _ value: Any) throws -> WritableKeyPath<EnvironmentValues, T> {
        return try Inspector.attribute(path: "modifier|keyPath", value: value,
                                       type: WritableKeyPath<EnvironmentValues, T>.self)
    }
}
