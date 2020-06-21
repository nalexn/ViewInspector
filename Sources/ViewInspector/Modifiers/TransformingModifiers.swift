import SwiftUI

// MARK: - ViewTransforming

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView {
    
    func rotation() throws -> (angle: Angle, anchor: UnitPoint) {
        let angle = try modifierAttribute(
            modifierName: "_RotationEffect", path: "modifier|angle",
            type: Angle.self, call: "rotationEffect")
        let anchor = try modifierAttribute(
            modifierName: "_RotationEffect", path: "modifier|anchor",
            type: UnitPoint.self, call: "rotationEffect")
        return (angle, anchor)
    }
    
    struct Rotation3D {
        let angle: Angle
        let axis: Axis
        let anchor: UnitPoint
        let anchorZ: CGFloat
        let perspective: CGFloat
        typealias Axis = (x: CGFloat, y: CGFloat, z: CGFloat)
    }
    
    func rotation3D() throws -> Rotation3D {
        let angle = try modifierAttribute(
            modifierName: "_Rotation3DEffect", path: "modifier|angle",
            type: Angle.self, call: "rotation3DEffect")
        let axis = try modifierAttribute(
            modifierName: "_Rotation3DEffect", path: "modifier|axis",
            type: Rotation3D.Axis.self, call: "rotation3DEffect")
        let anchor = try modifierAttribute(
            modifierName: "_Rotation3DEffect", path: "modifier|anchor",
            type: UnitPoint.self, call: "rotation3DEffect")
        let anchorZ = try modifierAttribute(
            modifierName: "_Rotation3DEffect", path: "modifier|anchorZ",
            type: CGFloat.self, call: "rotation3DEffect")
        let perspective = try modifierAttribute(
            modifierName: "_Rotation3DEffect", path: "modifier|perspective",
            type: CGFloat.self, call: "rotation3DEffect")
        return .init(angle: angle, axis: axis, anchor: anchor,
                     anchorZ: anchorZ, perspective: perspective)
    }
    
    func projectionTransform() throws -> ProjectionTransform {
        return try modifierAttribute(
            modifierName: "_ProjectionEffect", path: "modifier|transform",
            type: ProjectionTransform.self, call: "projectionTransform")
    }
    
    func transformEffect() throws -> CGAffineTransform {
        return try modifierAttribute(
            modifierName: "_TransformEffect", path: "modifier|transform",
            type: CGAffineTransform.self, call: "transformEffect")
    }
}

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
