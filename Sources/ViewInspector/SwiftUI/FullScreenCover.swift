import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension ViewType {

    struct FullScreenCover: KnownViewType {
        public static var typePrefix: String = ViewType.PopupContainer<FullScreenCover>.typePrefix
        public static var namespacedPrefixes: [String] { [typePrefix] }
        public static func inspectionCall(typeName: String) -> String {
            return "fullScreenCover(\(ViewType.indexPlaceholder))"
        }
    }
}

// MARK: - Content Extraction

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension ViewType.FullScreenCover: SingleViewContent {

    public static func child(_ content: Content) throws -> Content {
        let view = try Inspector.attribute(label: "popup", value: content.view)
        let medium = content.medium.resettingViewModifiers()
        return try Inspector.unwrap(view: view, medium: medium)
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension ViewType.FullScreenCover: MultipleViewContent {

    public static func children(_ content: Content) throws -> LazyGroup<Content> {
        let view = try Inspector.attribute(label: "popup", value: content.view)
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
        return try popup(parent: parent, index: index,
                         modifierPredicate: isFullScreenCoverBuilder(modifier:),
                         standardPredicate: standardFullScreenCoverModifier)
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

// MARK: - Custom Attributes

@available(iOS 14.0, tvOS 14.0, watchOS 7.0, *)
@available(macOS, unavailable)
public extension InspectableView where View == ViewType.FullScreenCover {

    func callOnDismiss() throws {
        let fullScreenCover = try Inspector.cast(
            value: content.view, type: ViewType.PopupContainer<ViewType.FullScreenCover>.self)
        fullScreenCover.presenter.dismissPopup()
    }
}
