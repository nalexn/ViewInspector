import SwiftUI

// MARK: - ViewSizing

public struct FixedFrameLayout: Equatable {
    public let width: CGFloat, height: CGFloat, alignment: Alignment
}

public struct FlexFrameLayout: Equatable {
    public let minWidth: CGFloat, idealWidth: CGFloat, maxWidth: CGFloat
    public let minHeight: CGFloat, idealHeight: CGFloat, maxHeight: CGFloat
    public let alignment: Alignment
}

public struct FixedSize: Equatable {
    public let horizontal: Bool, vertical: Bool
}

public extension InspectableView {
    func fixedFrame() throws -> FixedFrameLayout {
        let width = try modifierAttribute(
            modifierName: "_FrameLayout", path: "modifier|width",
            type: CGFloat.self, call: "frame(width: height: alignment:")
        let height = try modifierAttribute(
            modifierName: "_FrameLayout", path: "modifier|height",
            type: CGFloat.self, call: "frame(width: height: alignment:")
        let alignment = try modifierAttribute(
            modifierName: "_FrameLayout", path: "modifier|alignment",
            type: Alignment.self, call: "frame(width: height: alignment:")
        return FixedFrameLayout(width: width, height: height, alignment: alignment)
    }
    
    func flexFrame() throws -> FlexFrameLayout {
        let floatAttrNames = ["minWidth", "idealWidth", "maxWidth",
                              "minHeight", "idealHeight", "maxHeight"]
        let call = "frame(minWidth: idealWidth: maxWidth: minHeight: idealHeight: maxHeight: alignment:"
        let floats = try floatAttrNames.map { name in
            return try modifierAttribute(
                modifierName: "_FlexFrameLayout", path: "modifier|\(name)",
                type: CGFloat.self, call: call)
        }
        let alignment = try modifierAttribute(
            modifierName: "_FlexFrameLayout", path: "modifier|alignment",
            type: Alignment.self, call: call)
        return FlexFrameLayout(minWidth: floats[0], idealWidth: floats[1], maxWidth: floats[2],
                               minHeight: floats[3], idealHeight: floats[4], maxHeight: floats[5],
                               alignment: alignment)
    }
    
    func fixedSize() throws -> FixedSize {
        let horizontal = try modifierAttribute(
            modifierName: "_FixedSizeLayout", path: "modifier|horizontal",
            type: Bool.self, call: "fixedSize")
        let vertical = try modifierAttribute(
            modifierName: "_FixedSizeLayout", path: "modifier|vertical",
            type: Bool.self, call: "fixedSize")
        return FixedSize(horizontal: horizontal, vertical: vertical)
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
