import SwiftUI

// MARK: - Adjusting Text in a View

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView {
    
    #if !os(macOS)
    func textContentType() throws -> UITextContentType? {
        let reference = EmptyView().textContentType(.emailAddress)
        let keyPath = try Inspector.environmentKeyPath(Optional<String>.self, reference)
        let value = try environment(keyPath, call: "textContentType")
        return value.flatMap { UITextContentType(rawValue: $0) }
    }
    #endif

    #if os(iOS) || os(tvOS)
    func keyboardType() throws -> UIKeyboardType {
        let reference = EmptyView().keyboardType(.default)
        let keyPath = try Inspector.environmentKeyPath(Int.self, reference)
        let value = try environment(keyPath, call: "keyboardType")
        return UIKeyboardType(rawValue: value)!
    }
    
    func autocapitalization() throws -> UITextAutocapitalizationType {
        let reference = EmptyView().autocapitalization(.none)
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
    
    func allowsTightening() throws -> Bool {
        let reference = EmptyView().allowsTightening(true)
        let keyPath = try Inspector.environmentKeyPath(Bool.self, reference)
        return try environment(keyPath, call: "allowsTightening")
    }
    
    func disableAutocorrection() throws -> Bool? {
        let reference = EmptyView().disableAutocorrection(false)
        let keyPath = try Inspector.environmentKeyPath(Optional<Bool>.self, reference)
        return try environment(keyPath, call: "disableAutocorrection")
    }
    
    func flipsForRightToLeftLayoutDirection() throws -> Bool? {
        return try modifierAttribute(
            modifierName: "_FlipForRTLEffect", path: "modifier|isEnabled",
            type: Optional<Bool>.self, call: "flipsForRightToLeftLayoutDirection")
    }
}
