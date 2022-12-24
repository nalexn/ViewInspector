import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension ViewType {
    
    struct ActionSheet: KnownViewType {
        public static var typePrefix: String = ViewType.PopupContainer<ActionSheet>.typePrefix
        public static var namespacedPrefixes: [String] { [typePrefix] }
        public static func inspectionCall(typeName: String) -> String {
            return "actionSheet(\(ViewType.indexPlaceholder))"
        }
    }
}

// MARK: - Extraction

@available(iOS 13.0, tvOS 13.0, *)
@available(macOS, unavailable)
public extension InspectableView {

    func actionSheet(_ index: Int? = nil) throws -> InspectableView<ViewType.ActionSheet> {
        return try contentForModifierLookup.actionSheet(parent: self, index: index)
    }
}

@available(iOS 13.0, tvOS 13.0, *)
@available(macOS, unavailable)
internal extension Content {
    
    func actionSheet(parent: UnwrappedView, index: Int?) throws -> InspectableView<ViewType.ActionSheet> {
        return try popup(parent: parent, index: index,
                         modifierPredicate: isActionSheetBuilder(modifier:),
                         standardPredicate: standardActionSheetModifier)
    }
    
    func standardActionSheetModifier(_ name: String = "ActionSheet") throws -> Any {
        return try self.modifier({
            $0.modifierType == "IdentifiedPreferenceTransformModifier<Key>"
            || $0.modifierType.contains("AlertTransformModifier")
        }, call: name.firstLetterLowercased)
    }
    
    func actionSheetsForSearch() -> [ViewSearch.ModifierIdentity] {
        let count = medium.viewModifiers
            .filter(isActionSheetBuilder(modifier:))
            .count
        return Array(0..<count).map { _ in
            .init(name: "", builder: { parent, index in
                try parent.content.actionSheet(parent: parent, index: index)
            })
        }
    }
    
    private func isActionSheetBuilder(modifier: Any) -> Bool {
        let modifier = try? Inspector.attribute(
            label: "modifier", value: modifier, type: BasePopupPresenter.self)
        return modifier?.isActionSheetPresenter == true
    }
}

// MARK: - Custom Attributes

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView where View == ViewType.ActionSheet {

    func title() throws -> InspectableView<ViewType.Text> {
        return try View.supplementaryChildren(self).element(at: 0)
            .asInspectableView(ofType: ViewType.Text.self)
    }
    
    func message() throws -> InspectableView<ViewType.Text> {
        return try View.supplementaryChildren(self).element(at: 1)
            .asInspectableView(ofType: ViewType.Text.self)
    }
    
    func button(_ index: Int) throws -> InspectableView<ViewType.AlertButton> {
        let allViews = try View.supplementaryChildren(self)
        guard index >= 0 && index < allViews.count - 2 else {
            throw InspectionError.viewNotFound(parent: "button at index \(index)")
        }
        return try allViews.element(at: index + 2)
            .asInspectableView(ofType: ViewType.AlertButton.self)
    }
    
    func dismiss() throws {
        let container = try Inspector.cast(
            value: content.view, type: ViewType.PopupContainer<ViewType.ActionSheet>.self)
        container.presenter.dismissPopup()
    }
}

// MARK: - Non Standard Children

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension ViewType.ActionSheet: SupplementaryChildren {
    static func supplementaryChildren(_ parent: UnwrappedView) throws -> LazyGroup<SupplementaryView> {
        let buttons = try Inspector.attribute(
            path: "popup|buttons", value: parent.content.view, type: [Any].self)
        return .init(count: 2 + buttons.count) { index in
            let medium = parent.content.medium.resettingViewModifiers()
            switch index {
            case 0:
                let view = try Inspector.attribute(path: "popup|title", value: parent.content.view)
                let content = try Inspector.unwrap(content: Content(view, medium: medium))
                return try InspectableView<ViewType.Text>(
                    content, parent: parent, call: "title()")
            case 1:
                let maybeView = try Inspector.attribute(
                    path: "popup|message", value: parent.content.view, type: Text?.self)
                guard let view = maybeView else {
                    throw InspectionError.viewNotFound(parent: "message")
                }
                let content = try Inspector.unwrap(content: Content(view, medium: medium))
                return try InspectableView<ViewType.Text>(
                    content, parent: parent, call: "message()")
            default:
                let index = index - 2
                guard index >= 0 && index < buttons.count,
                      let view = buttons[index] as? Alert.Button else {
                    throw InspectionError.viewNotFound(parent: "button at index \(index)")
                }
                let content = try Inspector.unwrap(content: Content(view, medium: medium))
                return try InspectableView<ViewType.AlertButton>(
                    content, parent: parent, call: "button(\(index))")
            }
        }
    }
}
