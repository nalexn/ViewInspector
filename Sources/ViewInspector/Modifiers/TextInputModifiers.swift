import SwiftUI

// MARK: - Adjusting Text in a View

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView {

    #if os(iOS) || os(tvOS)
    func keyboardType() throws -> UIKeyboardType {
        let reference = EmptyView().keyboardType(.default)
        let accentKeyPath = try Inspector.environmentKeyPath(Int.self, reference)
        let value = try modifierAttribute(modifierLookup: { modifier -> Bool in
            guard modifier.modifierType == "_EnvironmentKeyWritingModifier<Int>",
                  let keyPath = try? Inspector.environmentKeyPath(Int.self, modifier)
            else { return false }
            return keyPath == accentKeyPath
        }, path: "modifier|value", type: Int.self, call: "keyboardType")
        return UIKeyboardType(rawValue: value)!
    }
    
    func autocapitalization() throws -> UITextAutocapitalizationType {
        let reference = EmptyView().autocapitalization(.none)
        let accentKeyPath = try Inspector.environmentKeyPath(Int.self, reference)
        let value = try modifierAttribute(modifierLookup: { modifier -> Bool in
            guard modifier.modifierType == "_EnvironmentKeyWritingModifier<Int>",
                  let keyPath = try? Inspector.environmentKeyPath(Int.self, modifier)
            else { return false }
            return keyPath == accentKeyPath
        }, path: "modifier|value", type: Int.self, call: "autocapitalization")
        return UITextAutocapitalizationType(rawValue: value)!
    }
    #endif
}
