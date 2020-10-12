import SwiftUI

// MARK: - Adjusting Text in a View

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView {
    
    #if !os(macOS)
    func textContentType() throws -> UITextContentType? {
        let reference = EmptyView().textContentType(.emailAddress)
        let keyPath = try Inspector.environmentKeyPath(Optional<String>.self, reference)
        let value = try environmentModifier(keyPath: keyPath, call: "textContentType")
        return value.flatMap { UITextContentType(rawValue: $0) }
    }
    #endif

    #if os(iOS) || os(tvOS)
    func keyboardType() throws -> UIKeyboardType {
        let reference = EmptyView().keyboardType(.default)
        let keyPath = try Inspector.environmentKeyPath(Int.self, reference)
        let value = try environmentModifier(keyPath: keyPath, call: "keyboardType")
        return UIKeyboardType(rawValue: value)!
    }
    
    func autocapitalization() throws -> UITextAutocapitalizationType {
        let reference = EmptyView().autocapitalization(.none)
        let keyPath = try Inspector.environmentKeyPath(Int.self, reference)
        let value = try environmentModifier(keyPath: keyPath, call: "autocapitalization")
        return UITextAutocapitalizationType(rawValue: value)!
    }
    #endif
    
    func disableAutocorrection() throws -> Bool? {
        let reference = EmptyView().disableAutocorrection(false)
        let keyPath = try Inspector.environmentKeyPath(Optional<Bool>.self, reference)
        return try environmentModifier(keyPath: keyPath, call: "disableAutocorrection")
    }
    
    func flipsForRightToLeftLayoutDirection() throws -> Bool? {
        return try modifierAttribute(
            modifierName: "_FlipForRTLEffect", path: "modifier|isEnabled",
            type: Optional<Bool>.self, call: "flipsForRightToLeftLayoutDirection")
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
