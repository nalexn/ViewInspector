import SwiftUI

// MARK: - ViewColorTests

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView {
    
    func foregroundColor() throws -> Color? {
        return try foregroundColor(checkIfText: true)
    }
    
    internal func foregroundColor(checkIfText: Bool) throws -> Color? {
        let reference = EmptyView().foregroundColor(nil)
        let keyPath = try Inspector.environmentKeyPath(Optional<Color>.self, reference)
        let throwIfText: () throws -> Void = {
            guard checkIfText, content.view is Text else { return }
            throw InspectionError.notSupported(
                "Please use .attributes().foregroundColor() for inspecting foregroundColor on a Text")
        }
        do {
            let color = try environment(keyPath, call: "foregroundColor")
            try throwIfText()
            return color
        } catch {
            try throwIfText()
            throw error
        }
    }
    
    @available(macOS 11.0, *)
    func accentColor() throws -> Color? {
        let reference = EmptyView().accentColor(nil)
        let keyPath = try Inspector.environmentKeyPath(Optional<Color>.self, reference)
        return try environment(keyPath, call: "accentColor")
    }

    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
    func tint() throws -> Color? {
        let reference = EmptyView().tint(nil)
        let keyPath = try Inspector.environmentKeyPath(Optional<Color>.self, reference)
        return try environment(keyPath, call: "tint")
    }
    
    func colorScheme() throws -> ColorScheme {
        let reference = EmptyView().colorScheme(.light)
        do {
            let keyPath = try Inspector.environmentKeyPath(ColorScheme.self, reference)
            return try environment(keyPath, call: "colorScheme")
        } catch {
            if #available(macOS 11.0, *) {
                if let preferred = try? preferredColorScheme() {
                    return preferred
                }
            }
            throw error
        }
    }
    
    @available(macOS 11.0, *)
    func preferredColorScheme() throws -> ColorScheme? {
        return try modifierAttribute(
            modifierName: "_PreferenceWritingModifier<PreferredColorSchemeKey>",
            transitive: true,
            path: "modifier|value", type: Optional<ColorScheme>.self, call: "preferredColorScheme")
    }

    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
    func foregroundStyleShapeStyle<S>(_ style: S.Type) throws -> S where S: ShapeStyle {
        let typeName = Inspector.typeName(type: S.self)
        return try modifierAttribute(
            modifierName: "_ForegroundStyleModifier<\(typeName)>",
            transitive: false,
            path: "modifier|style", type: S.self, call: "foregroundStyle")
    }
}

// MARK: - ViewPreview

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView {
    
    func previewDevice() throws -> PreviewDevice {
        return try modifierAttribute(
            modifierName: "PreviewDeviceTraitKey", path: "modifier|value",
            type: PreviewDevice.self, call: "previewDevice")
    }
    
    func previewDisplayName() throws -> String {
        return try modifierAttribute(
            modifierName: "PreviewDisplayNameTraitKey", path: "modifier|value",
            type: String.self, call: "previewDisplayName")
    }
    
    func previewLayout() throws -> PreviewLayout {
        return try modifierAttribute(
            modifierName: "PreviewLayoutTraitKey", path: "modifier|value",
            type: PreviewLayout.self, call: "previewLayout")
    }
}
