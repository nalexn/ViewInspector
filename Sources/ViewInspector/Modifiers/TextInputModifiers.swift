import SwiftUI

// MARK: - Adjusting Text in a View

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public extension InspectableView {
    
    #if (os(iOS) || os(tvOS)) && !targetEnvironment(macCatalyst)
    func textContentType() throws -> UITextContentType? {
        let reference = EmptyView().textContentType(.emailAddress)
        let keyPath = try Inspector.environmentKeyPath(Optional<String>.self, reference)
        let value = try environment(keyPath, call: "textContentType")
        return value.flatMap { UITextContentType(rawValue: $0) }
    }
    
    func keyboardType() throws -> UIKeyboardType {
        guard #available(iOS 15.0, tvOS 15.0, watchOS 8.0, *) else {
            let reference = EmptyView().keyboardType(.default)
            let keyPath = try Inspector.environmentKeyPath(Int.self, reference)
            let value = try environment(keyPath, call: "keyboardType")
            return UIKeyboardType(rawValue: value)!
        }
        guard let modifier = content.medium.environmentModifiers.last(where: { modifier in
            guard let keyPath = try? modifier.keyPath()
            else { return false }
            let keyPathType = Inspector.typeName(value: keyPath)
            return keyPathType == "WritableKeyPath<EnvironmentValues, KeyboardType>"
        }) else {
            throw InspectionError.modifierNotFound(
                parent: Inspector.typeName(value: content.view), modifier: "keyboardType", index: 0)
        }
        return try Inspector.attribute(
            label: "type", value: try modifier.value(), type: UIKeyboardType.self)
    }
    
    func autocapitalization() throws -> UITextAutocapitalizationType {
        let reference = EmptyView().autocapitalization(.none)
        if #available(iOS 15.0, tvOS 15.0, watchOS 8.0, *) {
            typealias Closure = (inout TextInputAutocapitalization) -> Void
            if let keyPath = try? Inspector
                .environmentKeyPath(TextInputAutocapitalization.self, reference) {
                let closure = try environment(keyPath, call: "autocapitalization", valueType: Closure.self)
                var value = TextInputAutocapitalization.never
                closure(&value)
                let behavior = try Inspector.attribute(label: "behavior", value: value)
                let stringValue = String(describing: behavior)
                guard let style = TextInputAutocapitalization.Behavior(rawValue: stringValue) else {
                    throw InspectionError.notSupported("Unknown TextInputAutocapitalization.Behavior: \(stringValue)")
                }
                return style.autocapitalizationType
            }
        }
        let keyPath = try Inspector.environmentKeyPath(Int.self, reference)
        let value = try environment(keyPath, call: "autocapitalization")
        return UITextAutocapitalizationType(rawValue: value)!
    }
    #endif
    
    func font() throws -> Font? {
        return try font(checkIfText: true)
    }
    
    internal func font(checkIfText: Bool) throws -> Font? {
        let reference = EmptyView().font(.callout)
        let keyPath = try Inspector.environmentKeyPath(Optional<Font>.self, reference)
        let throwIfText: () throws -> Void = {
            guard checkIfText, content.view is Text else { return }
            throw InspectionError.notSupported(
                "Please use .attributes().font() for inspecting Font on a Text")
        }
        do {
            let font = try environment(keyPath, call: "font")
            try throwIfText()
            return font
        } catch {
            try throwIfText()
            throw error
        }
    }
    
    func lineLimit() throws -> Int? {
        let reference = EmptyView().lineLimit(nil)
        let keyPath = try Inspector.environmentKeyPath(Optional<Int>.self, reference)
        return try environment(keyPath, call: "lineLimit")
    }
    
    func lineSpacing() throws -> CGFloat {
        let reference = EmptyView().lineSpacing(0)
        let keyPath = try Inspector.environmentKeyPath(CGFloat.self, reference)
        return try environment(keyPath, call: "lineSpacing")
    }
    
    func multilineTextAlignment() throws -> TextAlignment {
        let reference = EmptyView().multilineTextAlignment(.leading)
        let keyPath = try Inspector.environmentKeyPath(TextAlignment.self, reference)
        return try environment(keyPath, call: "multilineTextAlignment")
    }
    
    func minimumScaleFactor() throws -> CGFloat {
        let reference = EmptyView().minimumScaleFactor(3)
        let keyPath = try Inspector.environmentKeyPath(CGFloat.self, reference)
        return try environment(keyPath, call: "minimumScaleFactor")
    }
    
    func truncationMode() throws -> Text.TruncationMode {
        let reference = EmptyView().truncationMode(.head)
        let keyPath = try Inspector.environmentKeyPath(Text.TruncationMode.self, reference)
        return try environment(keyPath, call: "truncationMode")
    }
    
    func allowsTightening() -> Bool {
        let reference = EmptyView().allowsTightening(true)
        if let keyPath = try? Inspector.environmentKeyPath(Bool.self, reference),
           let value = try? environment(keyPath, call: "allowsTightening") {
            return value
        }
        return false
    }
    
    #if !os(watchOS)
    func disableAutocorrection() -> Bool {
        let reference = EmptyView().disableAutocorrection(false)
        if let keyPath = try? Inspector.environmentKeyPath(Optional<Bool>.self, reference),
           let value = try? environment(keyPath, call: "disableAutocorrection") {
            return value
        }
        return false
    }
    #endif
    
    func flipsForRightToLeftLayoutDirection() -> Bool {
        return modifiersMatching({ $0.modifierType == "_FlipForRTLEffect" },
                                 transitive: true)
            .compactMap {
                try? Inspector.attribute(path: "modifier|isEnabled", value: $0, type: Bool.self)
            }
            .contains(true)
    }
}

#if (os(iOS) || os(tvOS)) && !targetEnvironment(macCatalyst)
@available(iOS 15.0, tvOS 15.0, watchOS 8.0, *)
extension TextInputAutocapitalization {
    enum Behavior: String {
        case never, words, sentences, characters
        
        var autocapitalizationType: UITextAutocapitalizationType {
            switch self {
            case .never: return .none
            case .words: return .words
            case .sentences: return .sentences
            case .characters: return .allCharacters
            }
        }
    }
}
#endif
