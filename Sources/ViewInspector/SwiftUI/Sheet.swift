import SwiftUI

// MARK: - Sheet

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension ViewType {
    
    struct Sheet: KnownViewType {
        public static var typePrefix: String = ViewType.PopupContainer<Sheet>.typePrefix
        public static var namespacedPrefixes: [String] { [typePrefix] }
        public static func inspectionCall(typeName: String) -> String {
            return "\(typeName.firstLetterLowercased)(\(ViewType.indexPlaceholder))"
        }
        public static var genericViewTypeForViewSearch: String? { "Sheet" }
    }
    typealias FullScreenCover = Sheet
}

// MARK: - Content Extraction

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension ViewType.Sheet: SingleViewContent {
    
    public static func child(_ content: Content) throws -> Content {
        let view = try Inspector.attribute(label: "popup", value: content.view)
        let medium = content.medium.resettingViewModifiers()
        return try Inspector.unwrap(view: view, medium: medium)
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension ViewType.Sheet: MultipleViewContent {
    
    public static func children(_ content: Content) throws -> LazyGroup<Content> {
        let view = try Inspector.attribute(label: "popup", value: content.view)
        let medium = content.medium.resettingViewModifiers()
        return try Inspector.viewsInContainer(view: view, medium: medium)
    }
}

// MARK: - Extraction

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView {

    func sheet(_ index: Int? = nil) throws -> InspectableView<ViewType.Sheet> {
        return try contentForModifierLookup.sheet(parent: self, index: index)
    }
}

@available(iOS 14.0, tvOS 14.0, watchOS 7.0, *)
@available(macOS, unavailable)
public extension InspectableView {

    func fullScreenCover(_ index: Int? = nil) throws -> InspectableView<ViewType.FullScreenCover> {
        return try contentForModifierLookup.sheet(parent: self, index: index, name: "FullScreenCover")
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
internal extension Content {
    
    func sheet(parent: UnwrappedView, index: Int?, name: String = "Sheet") throws -> InspectableView<ViewType.Sheet> {
        return try popup(parent: parent, index: index, name: name,
                         modifierPredicate: isSheetBuilder(modifier:),
                         standardPredicate: standardSheetModifier)
    }
    
    func standardSheetModifier(_ name: String = "Sheet") throws -> Any {
        return try self.modifier({
            $0.modifierType == "IdentifiedPreferenceTransformModifier<Key>"
            || $0.modifierType.contains("SheetPresentationModifier")
        }, call: name.firstLetterLowercased)
    }
    
    func sheetsForSearch() -> [ViewSearch.ModifierIdentity] {
        let count = medium.viewModifiers
            .filter(isSheetBuilder(modifier:))
            .count
        return Array(0..<count).map { _ in
            .init(name: "", builder: { parent, index in
                try parent.content.sheet(parent: parent, index: index)
            })
        }
    }
    
    private func isSheetBuilder(modifier: Any) -> Bool {
        let modifier = try? Inspector.attribute(
            label: "modifier", value: modifier, type: BasePopupPresenter.self)
        return modifier?.isSheetPresenter == true
    }
}

// MARK: - Custom Attributes

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView where View == ViewType.Sheet {

    func dismiss() throws {
        let container = try Inspector.cast(value: content.view, type: ViewType.PopupContainer<ViewType.Sheet>.self)
        container.presenter.dismissPopup()
    }
    
    @available(*, deprecated, renamed: "dismiss")
    func callOnDismiss() throws {
        try dismiss()
    }
}
