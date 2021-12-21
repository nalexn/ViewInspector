import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension ViewType {
    
    struct Overlay: KnownViewType {
        public static var typePrefix: String = ""
        public static var isTransitive: Bool { true }
    }
}

// MARK: - Extraction

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView {

    func overlay(_ index: Int? = nil) throws -> InspectableView<ViewType.Overlay> {
        return try contentForModifierLookup.overlay(parent: self, index: index)
    }
    
    func background(_ index: Int? = nil) throws -> InspectableView<ViewType.Overlay> {
        return try contentForModifierLookup.background(parent: self, index: index)
    }
}

// MARK: - Content

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension ViewType.Overlay: SingleViewContent {
    
    public static func child(_ content: Content) throws -> Content {
        return content
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension ViewType.Overlay: MultipleViewContent {
    
    public static func children(_ content: Content) throws -> LazyGroup<Content> {
        return try Inspector.viewsInContainer(view: content.view, medium: content.medium)
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
internal extension Content {
    
    func overlay(parent: UnwrappedView, call: String = "overlay", index: Int?
    ) throws -> InspectableView<ViewType.Overlay> {
        let modifier = try self.modifier({ modifier -> Bool in
            return modifier.modifierType.contains("_OverlayModifier")
        }, call: call, index: index ?? 0)
        let rootView = try Inspector.attribute(path: "modifier|overlay", value: modifier)
        let alignment = try Inspector.attribute(path: "modifier|alignment", value: modifier, type: Alignment.self)
        let overlayParams = ViewType.Overlay.Params(alignment: alignment)
        let medium = self.medium.resettingViewModifiers()
            .appending(viewModifier: overlayParams)
        let content = try Inspector.unwrap(content: Content(rootView, medium: medium))
        let base = call + "(\(ViewType.indexPlaceholder))"
        let call = ViewType.inspectionCall(base: base, index: index)
        return try .init(content, parent: parent, call: call, index: index)
    }
    
    func background(parent: UnwrappedView, call: String = "background", index: Int?
    ) throws -> InspectableView<ViewType.Overlay> {
        let modifier = try self.modifier({ modifier -> Bool in
            return modifier.modifierType.contains("_BackgroundModifier")
        }, call: call, index: index ?? 0)
        let rootView = try Inspector.attribute(path: "modifier|background", value: modifier)
        let alignment = try Inspector.attribute(path: "modifier|alignment", value: modifier, type: Alignment.self)
        let overlayParams = ViewType.Overlay.Params(alignment: alignment)
        let medium = self.medium.resettingViewModifiers()
            .appending(viewModifier: overlayParams)
        let content = try Inspector.unwrap(content: Content(rootView, medium: medium))
        let base = call + "(\(ViewType.indexPlaceholder))"
        let call = ViewType.inspectionCall(base: base, index: index)
        return try .init(content, parent: parent, call: call, index: index)
    }
}

// MARK: - Custom Attributes

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView where View == ViewType.Overlay {

    func alignment() throws -> Alignment {
        guard let params = content.medium.viewModifiers
            .compactMap({ $0 as? ViewType.Overlay.Params }).first else {
            throw InspectionError.attributeNotFound(label: "alignment", type: "Overlay")
        }
        return params.alignment
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
private extension ViewType.Overlay {
    struct Params {
        let alignment: Alignment
    }
}
