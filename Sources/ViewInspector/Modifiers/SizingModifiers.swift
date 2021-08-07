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

    func padding() throws -> EdgeInsets {
        let attr = paddingAttributes()
        guard attr.count > 0 else {
            throw noPaddingModifierError()
        }
        do {
            return .init(top: try attr.cumulativeValue(edge: .top) ?? 0,
                         leading: try attr.cumulativeValue(edge: .leading) ?? 0,
                         bottom: try attr.cumulativeValue(edge: .bottom) ?? 0,
                         trailing: try attr.cumulativeValue(edge: .trailing) ?? 0)
        } catch let error {
            if attr.allSatisfy({ $0.edges == .all }) {
                throw InspectionError.notSupported(
                    "Please use `hasPadding(_:)` for inspecting padding without explicit value.")
            }
            throw error
        }
    }

    func padding(_ edge: Edge.Set) throws -> CGFloat {
        let attr = paddingAttributes()
        let edges = edge.individualEdges
        guard edges.count > 0 else {
            throw InspectionError.notSupported("No edge is specified")
        }
        let values = try edges.map { singleEdge -> CGFloat in
            guard let value = try attr.cumulativeValue(edge: singleEdge.edgeSet) else {
                throw noPaddingModifierError()
            }
            return value
        }
        guard values.areAllEqual() else {
            throw InspectionError.notSupported(
                """
                Insets for edges '\(edges)' have different values, \
                consider calling `padding` individually per edge.
                """
            )
        }
        return values[0]
    }

    func hasPadding(_ edge: Edge.Set = .all) -> Bool {
        return paddingAttributes().contains(where: { $0.edges.contains(edge) })
    }

    private func paddingAttributes() -> [Inspector.PaddingAttributes] {
        return modifiersMatching({ $0.modifierType.contains("_PaddingLayout") })
            .enumerated()
            .compactMap { index, modifier -> Inspector.PaddingAttributes? in
                guard let edges = try? modifierAttribute(
                    modifierName: "_PaddingLayout", path: "modifier|edges",
                    type: SwiftUI.Edge.Set.self, call: "padding", index: index)
                else { return nil }
                let insets: EdgeInsets?
                do {
                    insets = try modifierAttribute(
                        modifierName: "_PaddingLayout", path: "modifier|insets",
                        type: EdgeInsets.self, call: "padding", index: index)
                } catch {
                    insets = nil
                }
                return .init(edgeInsets: insets, edges: edges)
            }
    }
    
    private func noPaddingModifierError() -> Error {
        return InspectionError.modifierNotFound(
            parent: Inspector.typeName(value: content.view),
            modifier: "padding", index: 0)
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
private extension Inspector {
    struct PaddingAttributes {
        let edgeInsets: EdgeInsets?
        let edges: Edge.Set
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
private extension Edge.Set {
    var individualEdges: [Edge] {
        return [Edge.top, .bottom, .leading, .trailing]
            .filter { contains($0.edgeSet) }
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
private extension Edge {
    var edgeSet: Edge.Set {
        switch self {
        case .top: return .top
        case .bottom: return .bottom
        case .leading: return .leading
        case .trailing: return .trailing
        }
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
private extension RandomAccessCollection where Element == Inspector.PaddingAttributes {
    func cumulativeValue(edge: Edge.Set) throws -> CGFloat? {
        let undefinedInsetError: (Edge) -> Error = { edge in
            return InspectionError.notSupported(
                """
                Undefined inset for '\(edge)' edge. Consider calling `hasPadding(_:)` \
                instead to assure a default padding is applied.
                """)
        }
        let insets = try compactMap { attr -> CGFloat? in
            if edge == .top, attr.edges.contains(.top) {
                guard let insets = attr.edgeInsets
                else { throw undefinedInsetError(.top) }
                return insets.top
            }
            if edge == .bottom, attr.edges.contains(.bottom) {
                guard let insets = attr.edgeInsets
                else { throw undefinedInsetError(.bottom) }
                return insets.bottom
            }
            if edge == .trailing, attr.edges.contains(.trailing) {
                guard let insets = attr.edgeInsets
                else { throw undefinedInsetError(.trailing) }
                return insets.trailing
            }
            if edge == .leading, attr.edges.contains(.leading) {
                guard let insets = attr.edgeInsets
                else { throw undefinedInsetError(.leading) }
                return insets.leading
            }
            return nil
        }
        return insets.count == 0 ? nil : insets.reduce(0, +)
    }
}

private extension RandomAccessCollection where Element: Equatable {
    func areAllEqual() -> Bool {
        guard let first = self.first else { return true }
        return !contains(where: { $0 != first })
    }
}
