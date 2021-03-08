import SwiftUI

// MARK: - ViewGraphicalEffects

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView {
    
    func blur() throws -> (radius: CGFloat, isOpaque: Bool) {
        let radius = try modifierAttribute(
            modifierName: "_BlurEffect", path: "modifier|radius",
            type: CGFloat.self, call: "blur")
        let isOpaque = try modifierAttribute(
            modifierName: "_BlurEffect", path: "modifier|isOpaque",
            type: Bool.self, call: "blur")
        return (radius, isOpaque)
    }
    
    func opacity() throws -> Double {
        return try modifierAttribute(
            modifierName: "_OpacityEffect", path: "modifier|opacity",
            type: Double.self, call: "opacity")
    }
    
    func brightness() throws -> Double {
        return try modifierAttribute(
            modifierName: "_BrightnessEffect", path: "modifier|amount",
            type: Double.self, call: "brightness")
    }
    
    func contrast() throws -> Double {
        return try modifierAttribute(
            modifierName: "_ContrastEffect", path: "modifier|amount",
            type: Double.self, call: "contrast")
    }
    
    func colorInvert() throws {
        _ = try modifierAttribute(
            modifierName: "_ColorInvertEffect", path: "modifier",
            type: Any.self, call: "colorInvert")
    }
    
    func colorMultiply() throws -> Color {
        return try modifierAttribute(
            modifierName: "_ColorMultiplyEffect", path: "modifier|color",
            type: Color.self, call: "colorMultiply")
    }
    
    func saturation() throws -> Double {
        return try modifierAttribute(
            modifierName: "_SaturationEffect", path: "modifier|amount",
            type: Double.self, call: "saturation")
    }
    
    func grayscale() throws -> Double {
        return try modifierAttribute(
            modifierName: "_GrayscaleEffect", path: "modifier|amount",
            type: Double.self, call: "grayscale")
    }
    
    func hueRotation() throws -> Angle {
        return try modifierAttribute(
            modifierName: "_HueRotationEffect", path: "modifier|angle",
            type: Angle.self, call: "hueRotation")
    }
    
    func luminanceToAlpha() throws {
        _ = try modifierAttribute(
            modifierName: "_LuminanceToAlphaEffect", path: "modifier",
            type: Any.self, call: "luminanceToAlpha")
    }
    
    func shadow() throws -> (color: Color, radius: CGFloat, offset: CGSize) {
        let color = try modifierAttribute(
            modifierName: "_ShadowEffect", path: "modifier|color",
            type: Color.self, call: "shadow")
        let radius = try modifierAttribute(
            modifierName: "_ShadowEffect", path: "modifier|radius",
            type: CGFloat.self, call: "shadow")
        let offset = try modifierAttribute(
            modifierName: "_ShadowEffect", path: "modifier|offset",
            type: CGSize.self, call: "shadow")
        return (color, radius, offset)
    }
    
    func border<S>(_ type: S.Type) throws -> (content: S, width: CGFloat) {
        let content = try modifierAttribute(modifierName:
            "_OverlayModifier<_ShapeView<_StrokedShape", path: "modifier|overlay|style",
            type: Any.self, call: "border")
        let castedContent = try Inspector.cast(value: content, type: S.self)
        let width = try modifierAttribute(modifierName:
            "_OverlayModifier<_ShapeView<_StrokedShape", path: "modifier|overlay|shape|style|lineWidth",
            type: CGFloat.self, call: "border")
        return (castedContent, width)
    }
    
    func blendMode() throws -> BlendMode {
        return try modifierAttribute(
            modifierName: "_BlendModeEffect", path: "modifier|blendMode",
            type: BlendMode.self, call: "blendMode")
    }
}

// MARK: - ViewMasking

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView {
    
    func clipShape<S>(_ shape: S.Type) throws -> S where S: Shape {
        return try clipShape(shape, call: "clipShape")
    }
    
    private func clipShape<S>(_ shape: S.Type, call: String) throws -> S where S: Shape {
        let shapeValue = try modifierAttribute(
            modifierName: "_ClipEffect", path: "modifier|shape",
            type: Any.self, call: call)
        return try Inspector.cast(value: shapeValue, type: S.self)
    }
    
    func clipStyle() throws -> FillStyle {
        return try modifierAttribute(
            modifierName: "_ClipEffect", path: "modifier|style",
            type: FillStyle.self, call: "clipStyle")
    }
    
    func cornerRadius() throws -> CGFloat {
        let shape = try clipShape(RoundedRectangle.self, call: "cornerRadius")
        return shape.cornerSize.width
    }
    
    func mask() throws -> InspectableView<ViewType.ClassifiedView> {
        return try contentForModifierLookup.mask(parent: self)
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
internal extension Content {
    func mask(parent: UnwrappedView) throws -> InspectableView<ViewType.ClassifiedView> {
        let rootView = try modifierAttribute(
            modifierName: "_MaskEffect", path: "modifier|mask",
            type: Any.self, call: "mask")
        let medium = self.medium.resettingViewModifiers()
        return try .init(try Inspector.unwrap(content: Content(rootView, medium: medium)),
                         parent: parent, call: "mask()")
    }
}

// MARK: - ViewHiding

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView {
    
    func isHidden() -> Bool {
        return (try? modifierAttribute(
            modifierName: "_HiddenModifier", path: "modifier",
            type: Any.self, call: "hidden")) != nil
    }
    
    func isDisabled() throws -> Bool {
        let reference = EmptyView().disabled(true)
        typealias Closure = (inout Bool) -> Void
        let referenceKeyPath = try Inspector.environmentKeyPath(Bool.self, reference)
        let closure = try modifierAttribute(modifierLookup: { modifier -> Bool in
            guard modifier.modifierType == "_EnvironmentKeyTransformModifier<Bool>",
                  let keyPath = try? Inspector.environmentKeyPath(Bool.self, modifier)
            else { return false }
            return keyPath == referenceKeyPath
        }, path: "modifier|transform", type: Closure.self, call: "disabled")
        var value = true
        closure(&value)
        return !value
    }
}
