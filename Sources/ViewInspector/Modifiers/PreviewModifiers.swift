import SwiftUI

// MARK: - ViewColorTests

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView {
    
    func foregroundColor() throws -> Color? {
        let foregroundKeyPath = try Inspector.environmentColorKeyPath(EmptyView().foregroundColor(nil))
        return try modifierAttribute(modifierLookup: { modifier -> Bool in
            guard modifier.modifierType == "_EnvironmentKeyWritingModifier<Optional<Color>>",
                  let keyPath = try? Inspector.environmentColorKeyPath(modifier)
            else { return false }
            return keyPath == foregroundKeyPath
        }, path: "modifier|value", type: Optional<Color>.self, call: "foregroundColor")
    }
    
    #if !os(macOS)
    func accentColor() throws -> Color? {
        let accentKeyPath = try Inspector.environmentColorKeyPath(EmptyView().accentColor(nil))
        return try modifierAttribute(modifierLookup: { modifier -> Bool in
            guard modifier.modifierType == "_EnvironmentKeyWritingModifier<Optional<Color>>",
                  let keyPath = try? Inspector.environmentColorKeyPath(modifier)
            else { return false }
            return keyPath == accentKeyPath
        }, path: "modifier|value", type: Optional<Color>.self, call: "accentColor")
    }
    #endif
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
internal extension Inspector {
    static func environmentColorKeyPath(_ value: Any) throws -> WritableKeyPath<EnvironmentValues, Color?> {
        guard let keyPath = try? Inspector.attribute(path: "modifier|keyPath", value: value)
        as? WritableKeyPath<EnvironmentValues, Color?> else {
            throw InspectionError.attributeNotFound(
                label: "keyPath", type: Inspector.typeName(value: value))
        }
        return keyPath
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
