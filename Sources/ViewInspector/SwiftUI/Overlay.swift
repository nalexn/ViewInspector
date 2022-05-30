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
        return try contentForModifierLookup
            .overlay(parent: self, api: [.overlay, .overlayStyle], index: index)
    }
    
    func background(_ index: Int? = nil) throws -> InspectableView<ViewType.Overlay> {
        return try contentForModifierLookup
            .overlay(parent: self, api: [.background, .backgroundStyle], index: index)
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
    
    func overlay(parent: UnwrappedView, api: ViewType.Overlay.API, index: Int?
    ) throws -> InspectableView<ViewType.Overlay> {
        return try overlay(parent: parent, api: [api], index: index)
    }
    
    func overlay(parent: UnwrappedView, api: [ViewType.Overlay.API], index: Int?
    ) throws -> InspectableView<ViewType.Overlay> {
        let modifiers = modifiersMatching { modifier in
            api.contains(where: {
                modifier.modifierType.contains($0.modifierName)
            })
        }
        let hasMultipleOverlays = modifiers.count > 1
        let apiName = api.first!.rawValue
        guard let (modifier, rootView) = modifiers.lazy.compactMap({ modifier -> (Any, Any)? in
            for anApi in api {
                do {
                    let rootView = try Inspector.attribute(path: anApi.rootViewPath, value: modifier)
                    try anApi.verifySignature(content: rootView, hasMultipleOverlays: hasMultipleOverlays)
                    return (modifier, rootView)
                } catch { continue }
            }
            return nil
        }).dropFirst(index ?? 0).first else {
            let parentName = Inspector.typeName(value: view)
            throw InspectionError.modifierNotFound(
                parent: parentName, modifier: apiName, index: index ?? 0)
        }
        let alignment = (try? Inspector
            .attribute(path: "modifier|alignment", value: modifier,
                       type: Alignment.self)) ?? .center
        let edges = (try? Inspector
            .attribute(path: "modifier|ignoresSafeAreaEdges", value: modifier,
                       type: Edge.Set.self)) ?? .all
        let overlayParams = ViewType.Overlay.Params(alignment: alignment, ignoresSafeAreaEdges: edges)
        let medium = self.medium.resettingViewModifiers()
            .appending(viewModifier: overlayParams)
        let content = try Inspector.unwrap(content: Content(rootView, medium: medium))
        let base = apiName + "(\(ViewType.indexPlaceholder))"
        let call = ViewType.inspectionCall(base: base, index: index)
        return try .init(content, parent: parent, call: call, index: index)
    }
}

// MARK: - ViewType.Overlay.API

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
internal extension ViewType.Overlay {
    enum API: String {
        case border
        case overlay
        case overlayStyle
        case overlayPreferenceValue
        case background
        case backgroundStyle
        case backgroundPreferenceValue
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
internal extension ViewType.Overlay.API {
    
    var modifierName: String {
        switch self {
        case .border, .overlay, .overlayPreferenceValue:
            return "_OverlayModifier"
        case .overlayStyle:
            return "_OverlayStyleModifier"
        case .background, .backgroundPreferenceValue:
            return "_BackgroundModifier"
        case .backgroundStyle:
            return "_BackgroundStyleModifier"
        }
    }
    
    var rootViewPath: String {
        switch self {
        case .border, .overlay, .overlayPreferenceValue:
            return "modifier|overlay"
        case .background, .backgroundPreferenceValue:
            return "modifier|background"
        case .overlayStyle, .backgroundStyle:
            return "modifier|style"
        }
    }
    
    func verifySignature(content: Any, hasMultipleOverlays: Bool) throws {
        let reportFailure: () throws -> Void = {
            throw InspectionError.notSupported("Different view signature")
        }
        switch self {
        case .overlayStyle, .backgroundStyle:
            break
        case .border:
            let stroke = try? InspectableView<ViewType.Shape>(Content(content), parent: nil, index: nil).strokeStyle()
            if stroke == nil {
                try reportFailure()
            }
        case .overlay:
            let otherCases = [ViewType.Overlay.API.border, .overlayPreferenceValue]
            if hasMultipleOverlays, otherCases.contains(where: {
                (try? $0.verifySignature(content: content, hasMultipleOverlays: hasMultipleOverlays)) != nil
            }) {
                try reportFailure()
            }
        case .background:
            if (try? ViewType.Overlay.API.backgroundPreferenceValue
                    .verifySignature(content: content, hasMultipleOverlays: hasMultipleOverlays)) != nil {
                try reportFailure()
            }
        case .overlayPreferenceValue, .backgroundPreferenceValue:
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
    
    func ignoresSafeAreaEdges() throws -> Edge.Set {
        guard let params = content.medium.viewModifiers
            .compactMap({ $0 as? ViewType.Overlay.Params }).first else {
            throw InspectionError.attributeNotFound(label: "ignoresSafeAreaEdges", type: "Background")
        }
        return params.ignoresSafeAreaEdges
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
private extension ViewType.Overlay {
    struct Params {
        let alignment: Alignment
        let ignoresSafeAreaEdges: Edge.Set
    }
}
