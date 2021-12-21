import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension ViewType {
    
    struct Overlay: KnownViewType {
        public static var typePrefix: String = ""
        public static var isTransitive: Bool { true }
        
        internal static var overlayModifierName: String { "_OverlayModifier" }
        internal static var backgroundModifierName: String { "_BackgroundModifier" }
    }
}

// MARK: - Extraction

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView {

    func overlay(_ index: Int? = nil) throws -> InspectableView<ViewType.Overlay> {
        return try contentForModifierLookup.overlay(parent: self, api: .overlay, index: index)
    }
    
    func background(_ index: Int? = nil) throws -> InspectableView<ViewType.Overlay> {
        return try contentForModifierLookup.background(parent: self, api: .background, index: index)
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
    
    enum OverlayAPI: String {
        case border
        case overlay
        case overlayPreferenceValue
    }
    
    func overlay(parent: UnwrappedView, api: OverlayAPI, index: Int?
    ) throws -> InspectableView<ViewType.Overlay> {
        let modifiers = modifiersMatching {
            $0.modifierType.contains(ViewType.Overlay.overlayModifierName)
        }
        guard let (modifier, rootView) = modifiers.lazy.compactMap({ modifier -> (Any, Any)? in
            do {
                let rootView = try Inspector.attribute(path: "modifier|overlay", value: modifier)
                try api.verifySignature(of: rootView, parent: view, index: index)
                return (modifier, rootView)
            } catch { return nil }
        }).dropFirst(index ?? 0).first else {
            let parentName = Inspector.typeName(value: view)
            throw InspectionError.modifierNotFound(
                parent: parentName, modifier: api.rawValue, index: index ?? 0)
        }
        let alignment = try Inspector.attribute(path: "modifier|alignment", value: modifier, type: Alignment.self)
        let overlayParams = ViewType.Overlay.Params(alignment: alignment)
        let medium = self.medium.resettingViewModifiers()
            .appending(viewModifier: overlayParams)
        let content = try Inspector.unwrap(content: Content(rootView, medium: medium))
        let base = api.rawValue + "(\(ViewType.indexPlaceholder))"
        let call = ViewType.inspectionCall(base: base, index: index)
        return try .init(content, parent: parent, call: call, index: index)
    }
    
    enum BackgroundAPI: String {
        case background
        case backgroundPreferenceValue
    }
    
    func background(parent: UnwrappedView, api: BackgroundAPI, index: Int?
    ) throws -> InspectableView<ViewType.Overlay> {
        let modifier = try self.modifier({ modifier -> Bool in
            return modifier.modifierType.contains(ViewType.Overlay.backgroundModifierName)
        }, call: api.rawValue, index: index ?? 0)
        let rootView = try Inspector.attribute(path: "modifier|background", value: modifier)
        let alignment = try Inspector.attribute(path: "modifier|alignment", value: modifier, type: Alignment.self)
        let overlayParams = ViewType.Overlay.Params(alignment: alignment)
        let medium = self.medium.resettingViewModifiers()
            .appending(viewModifier: overlayParams)
        let content = try Inspector.unwrap(content: Content(rootView, medium: medium))
        let base = api.rawValue + "(\(ViewType.indexPlaceholder))"
        let call = ViewType.inspectionCall(base: base, index: index)
        return try .init(content, parent: parent, call: call, index: index)
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
internal extension Content.OverlayAPI {
    
    func verifySignature(of content: Any, parent: Any, index: Int?) throws {
        let reportFailure: () throws -> Void = {
            throw InspectionError.notSupported("Different view signature")
        }
        switch self {
        case .border:
            let stroke = try? InspectableView<ViewType.Shape>(Content(content), parent: nil, index: nil).strokeStyle()
            if stroke == nil {
                try reportFailure()
            }
        case .overlay:
            let otherCases = [Content.OverlayAPI.border, .overlayPreferenceValue]
            if otherCases.contains(where: {
                (try? $0.verifySignature(of: content, parent: parent, index: index)) != nil
            }) {
                try reportFailure()
            }
        case .overlayPreferenceValue:
            if Inspector.typeName(value: content, generics: .remove) != "_PreferenceReadingView" {
                try reportFailure()
            }
        }
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
