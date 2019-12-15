import SwiftUI

// MARK: - ViewPreview

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
