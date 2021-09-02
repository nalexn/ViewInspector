import SwiftUI

// MARK: - ActionSheet

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension ViewType {
    
    struct ActionSheet: KnownViewType {
        public static var typePrefix: String = "ViewType.ActionSheet.Container"
        public static var namespacedPrefixes: [String] {
            return ["ViewInspector." + typePrefix]
        }
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
        guard let sheetBuilder = try? self.modifierAttribute(
                modifierLookup: { isActionSheetBuilder(modifier: $0) }, path: "modifier",
                type: ActionSheetBuilder.self, call: "", index: index ?? 0)
        else {
            _ = try self.modifier({
                $0.modifierType == "IdentifiedPreferenceTransformModifier<Key>"
                || $0.modifierType.contains("AlertTransformModifier")
            }, call: "actionSheet")
            throw InspectionError.notSupported(
                """
                Please refer to the Guide for inspecting the ActionSheet: \
                https://github.com/nalexn/ViewInspector/blob/master/guide.md#alert-sheet-and-actionsheet
                """)
        }
        let sheet = try sheetBuilder.buildSheet()
        let container = ViewType.ActionSheet.Container(sheet: sheet, builder: sheetBuilder)
        let medium = self.medium.resettingViewModifiers()
        let content = Content(container, medium: medium)
        let call = ViewType.inspectionCall(
            base: ViewType.ActionSheet.inspectionCall(typeName: ""), index: index)
        return try .init(content, parent: parent, call: call, index: index)
    }
    
    func actionSheetsForSearch() -> [ViewSearch.ModifierIdentity] {
        let count = medium.viewModifiers
            .compactMap { isActionSheetBuilder(modifier: $0) }
            .count
        return Array(0..<count).map { _ in
            .init(name: "", builder: { parent, index in
                try parent.content.actionSheet(parent: parent, index: index)
            })
        }
    }
    
    private func isActionSheetBuilder(modifier: Any) -> Bool {
        return (try? Inspector.attribute(
            label: "modifier", value: modifier, type: ActionSheetBuilder.self)) != nil
    }
}

@available(iOS 13.0, tvOS 13.0, *)
@available(macOS, unavailable)
internal extension ViewType.ActionSheet {
    struct Container: CustomViewIdentityMapping {
        let sheet: SwiftUI.ActionSheet
        let builder: ActionSheetBuilder
        
        var viewTypeForSearch: KnownViewType.Type { ViewType.ActionSheet.self }
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
}

// MARK: - Non Standard Children

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension ViewType.ActionSheet: SupplementaryChildren {
    static func supplementaryChildren(_ parent: UnwrappedView) throws -> LazyGroup<SupplementaryView> {
        let buttons = try Inspector.attribute(
            path: "sheet|buttons", value: parent.content.view, type: [Any].self)
        return .init(count: 2 + buttons.count) { index in
            let medium = parent.content.medium.resettingViewModifiers()
            switch index {
            case 0:
                let view = try Inspector.attribute(path: "sheet|title", value: parent.content.view)
                let content = try Inspector.unwrap(content: Content(view, medium: medium))
                return try InspectableView<ViewType.Text>(
                    content, parent: parent, call: "title()")
            case 1:
                let maybeView = try Inspector.attribute(
                    path: "sheet|message", value: parent.content.view, type: Text?.self)
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

// MARK: - ActionSheet inspection protocols

@available(iOS 13.0, tvOS 13.0, *)
@available(macOS, unavailable)
public protocol ActionSheetBuilder: SystemPopupPresenter {
    func buildSheet() throws -> ActionSheet
}

@available(iOS 13.0, tvOS 13.0, *)
@available(macOS, unavailable)
public protocol ActionSheetProvider: ActionSheetBuilder {
    var isPresented: Binding<Bool> { get }
    var sheetBuilder: () -> ActionSheet { get }
}

@available(iOS 13.0, tvOS 13.0, *)
@available(macOS, unavailable)
public protocol ActionSheetItemProvider: ActionSheetBuilder {
    associatedtype Item: Identifiable
    var item: Binding<Item?> { get }
    var sheetBuilder: (Item) -> ActionSheet { get }
}

@available(iOS 13.0, tvOS 13.0, *)
@available(macOS, unavailable)
public extension ActionSheetProvider {
    func buildSheet() throws -> ActionSheet {
        guard isPresented.wrappedValue else {
            throw InspectionError.viewNotFound(parent: "ActionSheet")
        }
        return sheetBuilder()
    }
    
    func dismissPopup() {
        isPresented.wrappedValue = false
    }
}

@available(iOS 13.0, tvOS 13.0, *)
@available(macOS, unavailable)
public extension ActionSheetItemProvider {
    func buildSheet() throws -> ActionSheet {
        guard let value = item.wrappedValue else {
            throw InspectionError.viewNotFound(parent: "ActionSheet")
        }
        return sheetBuilder(value)
    }
    
    func dismissPopup() {
        item.wrappedValue = nil
    }
}
