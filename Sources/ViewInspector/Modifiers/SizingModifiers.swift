import SwiftUI

// MARK: - ViewSizing

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView {

    func fixedFrame() throws -> (width: CGFloat, height: CGFloat, alignment: Alignment) {
        let width = try fixedWidth()
        let height = try fixedHeight()
        let alignment = try fixedAlignment()
        return (width, height, alignment)
    }

    func fixedHeight() throws -> CGFloat {
        return try modifierAttribute(
            modifierName: "_FrameLayout", path: "modifier|height",
            type: CGFloat.self, call: "frame(height:)")
    }

    func fixedWidth() throws -> CGFloat {
        return try modifierAttribute(
            modifierName: "_FrameLayout", path: "modifier|width",
            type: CGFloat.self, call: "frame(width:)")
    }

    func fixedAlignment() throws -> Alignment {
        return try modifierAttribute(
            modifierName: "_FrameLayout", path: "modifier|alignment",
            type: Alignment.self, call: "frame(alignment:)")
    }
    
    func flexFrame() throws -> (minWidth: CGFloat, idealWidth: CGFloat, maxWidth: CGFloat,
                                minHeight: CGFloat, idealHeight: CGFloat, maxHeight: CGFloat,
                                alignment: Alignment) {
        let floatAttrNames = ["minWidth", "idealWidth", "maxWidth",
                              "minHeight", "idealHeight", "maxHeight"]
        let call = "frame(minWidth: idealWidth: maxWidth: minHeight: idealHeight: maxHeight: alignment:)"
        var floats = [CGFloat]()
        for name in floatAttrNames {
            do {
                let value = try modifierAttribute(
                    modifierName: "_FlexFrameLayout", path: "modifier|\(name)",
                    type: CGFloat.self, call: call)
                floats.append(value)
            } catch {
                floats.append(CGFloat.nan)
            }
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

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView {

    private struct PaddingAttributes {
        let edgeInsets: EdgeInsets?
        let edges: Edge.Set
    }

    func padding() throws -> EdgeInsets {
        return try modifierAttribute(
            modifierName: "_PaddingLayout", path: "modifier|insets",
            type: EdgeInsets.self, call: "padding")
    }

    func padding(_ edge: Edge.Set) throws -> CGFloat {
        let attributes = try self.paddingAttributes()
        for attribute in attributes {
            if attribute.edges.contains(edge) {
                if let value = edgeValue(attribute: attribute, edge: edge) {
                    return value
                }
            }
        }
        throw InspectionError.modifierNotFound(parent: Inspector.typeName(value: self), modifier: "padding")
    }

    func hasPadding(_ edge: Edge.Set = .all)  throws -> Bool {
        let attributes = try self.paddingAttributes()
        for attribute in attributes {
            if attribute.edges.contains(edge) {
                return true
            }
        }
        return false
    }

    private func edgeValue(attribute: PaddingAttributes, edge: Edge.Set) -> CGFloat? {
        guard let edgeInsets = attribute.edgeInsets else {
            return nil
        }
        var result = [CGFloat]()
        if edge.contains(.top) {
            result.append(edgeInsets.top)
        }
        if edge.contains(.bottom) {
            result.append(edgeInsets.bottom)
        }
        if edge.contains(.trailing) {
            result.append(edgeInsets.trailing)
        }
        if edge.contains(.leading) {
            result.append(edgeInsets.leading)
        }
        if hasSingleValue(result) {
            return result[0]
        }
        return nil
    }

    private func hasSingleValue(_ array: [CGFloat]) -> Bool {
        if array.count == 0 {
            return false
        }
        return array.dropLast().allSatisfy { $0 == array.last }
    }

    private func paddingAttributes() throws -> [PaddingAttributes] {
        let count = numberModifierAttributes(modifierName: "_PaddingLayout", path: "modifier|edges", call: "padding")

        var attributes = [PaddingAttributes]()

        for index in 0..<count {
            let edges = try modifierAttribute(
                modifierName: "_PaddingLayout", path: "modifier|edges",
                type: SwiftUI.Edge.Set.self, call: "padding", index: index)
            let insets: EdgeInsets?
            do {
                insets = try modifierAttribute(
                    modifierName: "_PaddingLayout", path: "modifier|insets",
                    type: EdgeInsets.self, call: "padding", index: index)
            } catch {
                insets = nil
            }
            attributes.append(PaddingAttributes(edgeInsets: insets, edges: edges))
        }

        return attributes
    }
}
