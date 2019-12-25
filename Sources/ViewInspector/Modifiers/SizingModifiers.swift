import SwiftUI

// MARK: - ViewSizing

public struct FlexFrameLayout: Equatable {
    public let minWidth: CGFloat, idealWidth: CGFloat, maxWidth: CGFloat
    public let minHeight: CGFloat, idealHeight: CGFloat, maxHeight: CGFloat
    public let alignment: Alignment
}

public extension InspectableView {
    func fixedFrame() throws -> (width: CGFloat, height: CGFloat, alignment: Alignment) {
        let width = try modifierAttribute(
            modifierName: "_FrameLayout", path: "modifier|width",
            type: CGFloat.self, call: "frame(width: height: alignment:)")
        let height = try modifierAttribute(
            modifierName: "_FrameLayout", path: "modifier|height",
            type: CGFloat.self, call: "frame(width: height: alignment:)")
        let alignment = try modifierAttribute(
            modifierName: "_FrameLayout", path: "modifier|alignment",
            type: Alignment.self, call: "frame(width: height: alignment:)")
        return (width, height, alignment)
    }
    
    func flexFrame() throws -> (minWidth: CGFloat, idealWidth: CGFloat, maxWidth: CGFloat,
                                minHeight: CGFloat, idealHeight: CGFloat, maxHeight: CGFloat,
                                alignment: Alignment) {
        let floatAttrNames = ["minWidth", "idealWidth", "maxWidth",
                              "minHeight", "idealHeight", "maxHeight"]
        let call = "frame(minWidth: idealWidth: maxWidth: minHeight: idealHeight: maxHeight: alignment:)"
        let floats = try floatAttrNames.map { name in
            return try modifierAttribute(
                modifierName: "_FlexFrameLayout", path: "modifier|\(name)",
                type: CGFloat.self, call: call)
        }
        let alignment = try modifierAttribute(
            modifierName: "_FlexFrameLayout", path: "modifier|alignment",
            type: Alignment.self, call: call)
        return (floats[0], floats[1], floats[2], floats[3], floats[4], floats[5], alignment)
    }
    
    func fixedSize() throws -> (horizontal: Bool, vertical: Bool) {
        let horizontal = try modifierAttribute(
            modifierName: "_FixedSizeLayout", path: "modifier|horizontal",
            type: Bool.self, call: "fixedSize")
        let vertical = try modifierAttribute(
            modifierName: "_FixedSizeLayout", path: "modifier|vertical",
            type: Bool.self, call: "fixedSize")
        return (horizontal, vertical)
    }
    
    func layoutPriority() throws -> Double {
        return try modifierAttribute(
            modifierName: "LayoutPriorityTraitKey", path: "modifier|value",
            type: Double.self, call: "layoutPriority")
    }
}

// MARK: - ViewPadding

public extension InspectableView {
    
    func padding() throws -> EdgeInsets {
        return try modifierAttribute(
            modifierName: "_PaddingLayout", path: "modifier|insets",
            type: EdgeInsets.self, call: "padding")
    }
}
