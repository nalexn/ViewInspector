import SwiftUI

// MARK: - Environment Modifiers

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView {

    func environment<T>(_ keyPath: WritableKeyPath<EnvironmentValues, T>) throws -> T {
        return try environment(keyPath, call: "environment(\(Inspector.typeName(type: T.self)))")
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
internal extension InspectableView {
    func environment<T>(_ reference: WritableKeyPath<EnvironmentValues, T>, call: String) throws -> T {
        guard let modifier = content.medium.environmentModifiers.last(where: { modifier in
            guard let keyPath = try? modifier.keyPath() as? WritableKeyPath<EnvironmentValues, T>
            else { return false }
            return keyPath == reference
        }) else {
            throw InspectionError.modifierNotFound(
                parent: Inspector.typeName(value: content.view), modifier: call)
        }
        return try Inspector.cast(value: try modifier.value(), type: T.self)
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
internal extension Inspector {
    static func environmentKeyPath<T>(_ type: T.Type, _ value: Any) throws -> WritableKeyPath<EnvironmentValues, T> {
        return try Inspector.attribute(path: "modifier|keyPath", value: value,
                                       type: WritableKeyPath<EnvironmentValues, T>.self)
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension ModifiedContent: EnvironmentModifier where Modifier: EnvironmentModifier {
    func keyPath() throws -> Any {
        return try Inspector.attribute(label: "modifier", value: self,
                                       type: Modifier.self).keyPath()
    }
    
    func value() throws -> Any {
        return try Inspector.attribute(label: "modifier", value: self,
                                       type: Modifier.self).value()
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
internal protocol EnvironmentModifier {
    func keyPath() throws -> Any
    func value() throws -> Any
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension _EnvironmentKeyWritingModifier: EnvironmentModifier {
    
    func keyPath() throws -> Any {
        return try Inspector.attribute(label: "keyPath", value: self)
    }
    
    func value() throws -> Any {
        return try Inspector.attribute(label: "value", value: self)
    }
}
