import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension ViewType {

    struct FullScreenCover: KnownViewType {
        public static var typePrefix: String = "ViewType.FullScreenCover.Container"
        public static var namespacedPrefixes: [String] {
            return ["ViewInspector." + typePrefix]
        }
        public static func inspectionCall(typeName: String) -> String {
            return "fullScreenCover(\(ViewType.indexPlaceholder))"
        }
    }
}

// MARK: - Content Extraction

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension ViewType.FullScreenCover: SingleViewContent {

    public static func child(_ content: Content) throws -> Content {
        let view = try Inspector.attribute(label: "view", value: content.view)
        let medium = content.medium.resettingViewModifiers()
        return try Inspector.unwrap(view: view, medium: medium)
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension ViewType.FullScreenCover: MultipleViewContent {

    public static func children(_ content: Content) throws -> LazyGroup<Content> {
        let view = try Inspector.attribute(label: "view", value: content.view)
        let medium = content.medium.resettingViewModifiers()
        return try Inspector.viewsInContainer(view: view, medium: medium)
    }
}

// MARK: - Extraction

@available(iOS 14.0, tvOS 14.0, watchOS 7.0, *)
@available(macOS, unavailable)
public extension InspectableView {

    func fullScreenCover(_ index: Int? = nil) throws -> InspectableView<ViewType.FullScreenCover> {
        return try contentForModifierLookup.fullScreenCover(parent: self, index: index)
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
internal extension Content {

    func fullScreenCover(parent: UnwrappedView, index: Int?) throws -> InspectableView<ViewType.FullScreenCover> {
        guard let fullScreenCoverPresenter = try? self.modifierAttribute(
                modifierLookup: { isFullScreenCoverBuilder(modifier: $0) }, path: "modifier",
                type: PopupPresenter.self, call: "", index: index ?? 0)
        else {
            _ = try standardFullScreenCoverModifier()
            throw InspectionError.notSupported(
                """
                Please refer to the Guide for inspecting the FullScreenCover: \
                https://github.com/nalexn/ViewInspector/blob/master/guide.md#alert-sheet-actionsheet-and-fullscreencover
                """)
        }
        let view = try fullScreenCoverPresenter.buildPopup()
        let container = ViewType.FullScreenCover.Container(view: view, presenter: fullScreenCoverPresenter)
        let medium = self.medium.resettingViewModifiers()
        let content = Content(container, medium: medium)
        let call = ViewType.inspectionCall(
            base: ViewType.FullScreenCover.inspectionCall(typeName: ""), index: index)
        return try .init(content, parent: parent, call: call, index: index)
    }
    
    func standardFullScreenCoverModifier() throws -> Any {
        return try self.modifier({
            $0.modifierType == "IdentifiedPreferenceTransformModifier<Key>"
            || $0.modifierType.contains("SheetPresentationModifier")
        }, call: "fullScreenCover")
    }

    func fullScreenCoversForSearch() -> [ViewSearch.ModifierIdentity] {
        let count = medium.viewModifiers
            .filter { isFullScreenCoverBuilder(modifier: $0) }
            .count
        return Array(0..<count).map { _ in
            .init(name: "", builder: { parent, index in
                try parent.content.fullScreenCover(parent: parent, index: index)
            })
        }
    }

    private func isFullScreenCoverBuilder(modifier: Any) -> Bool {
        let modifier = try? Inspector.attribute(
            label: "modifier", value: modifier, type: PopupPresenter.self)
        return modifier?.isFullScreenCoverPresenter == true
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
internal extension ViewType.FullScreenCover {
    struct Container: CustomViewIdentityMapping {
        let view: Any
        let presenter: PopupPresenter

        var viewTypeForSearch: KnownViewType.Type { ViewType.FullScreenCover.self }
    }
}

// MARK: - Custom Attributes

@available(iOS 14.0, tvOS 14.0, watchOS 7.0, *)
@available(macOS, unavailable)
public extension InspectableView where View == ViewType.FullScreenCover {

    func callOnDismiss() throws {
        let fullScreenCover = try Inspector.cast(value: content.view, type: ViewType.FullScreenCover.Container.self)
        fullScreenCover.presenter.dismissPopup()
    }
}
