import SwiftUI

// MARK: - Alert

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension ViewType {
    
    struct Alert: KnownViewType {
        public static var typePrefix: String = "ViewType.Alert.Container"
        public static var namespacedPrefixes: [String] {
            return ["ViewInspector." + typePrefix]
        }
        public static func inspectionCall(typeName: String) -> String {
            return "alert(\(ViewType.indexPlaceholder))"
        }
    }
}

// MARK: - Extraction

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView {

    func alert(_ index: Int? = nil) throws -> InspectableView<ViewType.Alert> {
        return try contentForModifierLookup.alert(parent: self, index: index)
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
internal extension Content {
    
    func alert(parent: UnwrappedView, index: Int?) throws -> InspectableView<ViewType.Alert> {
        guard let alertBuilder = try? self.modifierAttribute(
                modifierLookup: { isAlertBuilder(modifier: $0) }, path: "modifier",
                type: AlertBuilder.self, call: "", index: index ?? 0)
        else {
            _ = try self.modifier({
                $0.modifierType == "IdentifiedPreferenceTransformModifier<Key>"
                || $0.modifierType.contains("AlertTransformModifier")
            }, call: "alert")
            throw InspectionError.notSupported(
                """
                Please refer to the Guide for inspecting the Alert: \
                https://github.com/nalexn/ViewInspector/blob/master/guide.md#alert-sheet-and-actionsheet
                """)
        }
        let alert = try alertBuilder.buildAlert()
        let container = ViewType.Alert.Container(alert: alert, builder: alertBuilder)
        let medium = self.medium.resettingViewModifiers()
        let content = Content(container, medium: medium)
        let call = ViewType.inspectionCall(
            base: ViewType.Alert.inspectionCall(typeName: ""), index: index)
        return try .init(content, parent: parent, call: call, index: index)
    }
    
    func alertsForSearch() -> [ViewSearch.ModifierIdentity] {
        let count = medium.viewModifiers
            .compactMap { isAlertBuilder(modifier: $0) }
            .count
        return Array(0..<count).map { _ in
            .init(name: "", builder: { parent, index in
                try parent.content.alert(parent: parent, index: index)
            })
        }
    }
    
    private func isAlertBuilder(modifier: Any) -> Bool {
        return (try? Inspector.attribute(
            label: "modifier", value: modifier, type: AlertBuilder.self)) != nil
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
internal extension ViewType.Alert {
    struct Container: CustomViewIdentityMapping {
        let alert: SwiftUI.Alert
        let builder: AlertBuilder
        
        var viewTypeForSearch: KnownViewType.Type { ViewType.Alert.self }
    }
}

// MARK: - Custom Attributes

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView where View == ViewType.Alert {

    func title() throws -> InspectableView<ViewType.Text> {
        return try View.supplementaryChildren(self).element(at: 0)
            .asInspectableView(ofType: ViewType.Text.self)
    }
    
    func message() throws -> InspectableView<ViewType.Text> {
        return try View.supplementaryChildren(self).element(at: 1)
            .asInspectableView(ofType: ViewType.Text.self)
    }
    
    func primaryButton() throws -> InspectableView<ViewType.AlertButton> {
        return try View.supplementaryChildren(self).element(at: 2)
            .asInspectableView(ofType: ViewType.AlertButton.self)
    }
    
    func secondaryButton() throws -> InspectableView<ViewType.AlertButton> {
        return try View.supplementaryChildren(self).element(at: 3)
            .asInspectableView(ofType: ViewType.AlertButton.self)
    }
}

// MARK: - Non Standard Children

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension ViewType.Alert: SupplementaryChildren {
    static func supplementaryChildren(_ parent: UnwrappedView) throws -> LazyGroup<SupplementaryView> {
        return .init(count: 4) { index in
            let medium = parent.content.medium.resettingViewModifiers()
            switch index {
            case 0:
                let view = try Inspector.attribute(path: "alert|title", value: parent.content.view)
                let content = try Inspector.unwrap(content: Content(view, medium: medium))
                return try InspectableView<ViewType.Text>(
                    content, parent: parent, call: "title()")
            case 1:
                let maybeView = try Inspector.attribute(
                    path: "alert|message", value: parent.content.view, type: Text?.self)
                guard let view = maybeView else {
                    throw InspectionError.viewNotFound(parent: "message")
                }
                let content = try Inspector.unwrap(content: Content(view, medium: medium))
                return try InspectableView<ViewType.Text>(
                    content, parent: parent, call: "message()")
            case 2:
                let view = try Inspector.attribute(path: "alert|primaryButton", value: parent.content.view)
                let content = try Inspector.unwrap(content: Content(view, medium: medium))
                return try InspectableView<ViewType.AlertButton>(
                    content, parent: parent, call: "primaryButton()")
            default:
                let maybeView = try Inspector.attribute(
                    path: "alert|secondaryButton", value: parent.content.view, type: Alert.Button?.self)
                guard let view = maybeView else {
                    throw InspectionError.viewNotFound(parent: "secondaryButton")
                }
                let content = try Inspector.unwrap(content: Content(view, medium: medium))
                return try InspectableView<ViewType.AlertButton>(
                    content, parent: parent, call: "secondaryButton()")
            }
        }
    }
}

// MARK: - AlertButton

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension ViewType {
    
    struct AlertButton: KnownViewType {
        public static var typePrefix: String = "Alert.Button"
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension SwiftUI.Alert.Button: CustomViewIdentityMapping {
    var viewTypeForSearch: KnownViewType.Type { ViewType.AlertButton.self }
}

// MARK: - Non Standard Children

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension ViewType.AlertButton: SupplementaryChildren {
    static func supplementaryChildren(_ parent: UnwrappedView) throws -> LazyGroup<SupplementaryView> {
        return .init(count: 1) { _ in
            let child = try Inspector.attribute(path: "label", value: parent.content.view)
            let medium = parent.content.medium.resettingViewModifiers()
            let content = try Inspector.unwrap(content: Content(child, medium: medium))
            return try InspectableView<ViewType.Text>(content, parent: parent, call: "labelView()")
        }
    }
}

// MARK: - Custom Attributes

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension Alert.Button {
    enum Style: String {
        case `default`, cancel, destructive
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView where View == ViewType.AlertButton {
    
    func labelView() throws -> InspectableView<ViewType.Text> {
        return try View.supplementaryChildren(self).element(at: 0)
            .asInspectableView(ofType: ViewType.Text.self)
    }
    
    func style() throws -> Alert.Button.Style {
        let value = try Inspector.attribute(label: "style", value: content.view)
        let stringValue = String(describing: value)
        guard let style = Alert.Button.Style(rawValue: stringValue) else {
            throw InspectionError.notSupported("Unknown Alert.Button.Style: \(stringValue)")
        }
        return style
    }
    
    func tap() throws {
        guard let container = self.parentView?.content.view,
            let presenter = try? Inspector.attribute(
                label: "builder", value: container,
                type: SystemPopupPresenter.self)
        else { throw InspectionError.parentViewNotFound(view: "Alert.Button") }
        presenter.dismissPopup()
        typealias Callback = () -> Void
        let callback = try Inspector
            .attribute(label: "action", value: content.view, type: Callback.self)
        callback()
    }
}

// MARK: - Alert inspection protocols

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public protocol SystemPopupPresenter {
    func dismissPopup()
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public protocol AlertBuilder: SystemPopupPresenter {
    func buildAlert() throws -> Alert
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public protocol AlertProvider: AlertBuilder {
    var isPresented: Binding<Bool> { get }
    var alertBuilder: () -> Alert { get }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public protocol AlertItemProvider: AlertBuilder {
    associatedtype Item: Identifiable
    var item: Binding<Item?> { get }
    var alertBuilder: (Item) -> Alert { get }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension AlertProvider {
    func buildAlert() throws -> Alert {
        guard isPresented.wrappedValue else {
            throw InspectionError.viewNotFound(parent: "Alert")
        }
        return alertBuilder()
    }
    
    func dismissPopup() {
        isPresented.wrappedValue = false
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension AlertItemProvider {
    func buildAlert() throws -> Alert {
        guard let value = item.wrappedValue else {
            throw InspectionError.viewNotFound(parent: "Alert")
        }
        return alertBuilder(value)
    }
    
    func dismissPopup() {
        item.wrappedValue = nil
    }
}
