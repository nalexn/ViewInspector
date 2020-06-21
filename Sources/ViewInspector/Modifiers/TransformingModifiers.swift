import SwiftUI

// MARK: - ViewScaling

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView {
    
    func isScaledToFill() throws -> Bool {
        let mode = try contentMode(call: "scaledToFill")
        return try aspectRatio(call: "scaledToFill") == nil && mode == .fill
    }
    
    func isScaledToFit() throws -> Bool {
        let mode = try contentMode(call: "scaledToFit")
        return try aspectRatio(call: "scaledToFit") == nil && mode == .fit
    }
    
    func scaleEffect() throws -> CGSize {
        return try modifierAttribute(
            modifierName: "_ScaleEffect", path: "modifier|scale",
            type: CGSize.self, call: "scaleEffect")
    }
    
    func scaleEffectAnchor() throws -> UnitPoint {
        return try modifierAttribute(
            modifierName: "_ScaleEffect", path: "modifier|anchor",
            type: UnitPoint.self, call: "scaleEffect")
    }
    
    func aspectRatio() throws -> CGFloat? {
        return try aspectRatio(call: "aspectRatio")
    }
    
    func aspectRatioContentMode() throws -> ContentMode {
        return try contentMode(call: "aspectRatio")
    }
    
    #if !os(macOS)
    func imageScale() throws -> Image.Scale {
        return try modifierAttribute(
            modifierName: "_EnvironmentKeyWritingModifier<Scale>", path: "modifier|value",
            type: Image.Scale.self, call: "imageScale")
    }
    #endif
    
    private func aspectRatio(call: String) throws -> CGFloat? {
        return try modifierAttribute(
            modifierName: "_AspectRatioLayout", path: "modifier|aspectRatio",
            type: Optional<CGFloat>.self, call: "aspectRatio")
    }
    
    private func contentMode(call: String) throws -> ContentMode {
        return try modifierAttribute(
            modifierName: "_AspectRatioLayout", path: "modifier|contentMode",
            type: ContentMode.self, call: "aspectRatio")
    }
}
