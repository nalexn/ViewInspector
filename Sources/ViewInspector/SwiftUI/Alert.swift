import SwiftUI

// MARK: - Alert

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension ViewType {
    
    struct Alert: KnownViewType {
        public static var typePrefix: String = ViewType.PopupContainer<Alert>.typePrefix
        static var typePrefixIOS15: String = "AlertModifier"
        public static var namespacedPrefixes: [String] {
            [typePrefix, .swiftUINamespaceRegex + typePrefixIOS15]
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
        do {
            return try popup(parent: parent, index: index,
                             modifierPredicate: isDeprecatedAlertPresenter(modifier:),
                             standardPredicate: deprecatedStandardAlertModifier)
        } catch {
            if #available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *),
               let alert = try? alertIOS15(parent: parent, index: index) {
                return alert
            } else {
                throw error
            }
        }
    }
    
    private func deprecatedStandardAlertModifier(_ name: String = "Alert") throws -> Any {
        return try self.modifier({
            $0.modifierType == "IdentifiedPreferenceTransformModifier<Key>"
            || $0.modifierType.contains("AlertTransformModifier")
        }, call: name.firstLetterLowercased)
    }
    
    func alertsForSearch() -> [ViewSearch.ModifierIdentity] {
        let count = medium.viewModifiers
            .filter { modifier in
                isDeprecatedAlertPresenter(modifier: modifier)
                || isAlertIOS15(modifier: modifier)
            }
            .count
        return Array(0..<count).map { _ in
            .init(name: "", builder: { parent, index in
                try parent.content.alert(parent: parent, index: index)
            })
        }
    }
    
    private func isDeprecatedAlertPresenter(modifier: Any) -> Bool {
        let modifier = try? Inspector.attribute(
            label: "modifier", value: modifier, type: BasePopupPresenter.self)
        return modifier?.isAlertPresenter == true
    }
    
    // MARK: - iOS 15
    
    var isIOS15Modifier: Bool {
        let type = ViewType.PopupContainer<ViewType.Alert>.self
        return (try? Inspector.cast(value: view, type: type)) == nil
    }
    
    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
    func alertIOS15(parent: UnwrappedView, index: Int?) throws -> InspectableView<ViewType.Alert> {
        let modifier = try self.modifierAttribute(
            modifierLookup: isAlertIOS15(modifier:), path: "modifier",
            type: Any.self, call: "alert", index: index ?? 0)
        let medium = self.medium.resettingViewModifiers()
        let content = Content(modifier, medium: medium)
        let call = ViewType.inspectionCall(
            base: ViewType.Alert.inspectionCall(typeName: ""), index: index)
        let view = try InspectableView<ViewType.Alert>(
            content, parent: parent, call: call, index: index)
        guard try view.isPresentedBinding().wrappedValue else {
            throw InspectionError.viewNotFound(parent: "Alert")
        }
        return view
    }
    
    private func isAlertIOS15(modifier: Any) -> Bool {
        guard let modifier = modifier as? ModifierNameProvider
        else { return false }
        return modifier.modifierType.contains(ViewType.Alert.typePrefixIOS15)
    }
}

// MARK: - Custom Attributes

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView where View == ViewType.Alert {

    func title() throws -> InspectableView<ViewType.Text> {
        return try View.supplementaryChildren(self).element(at: 0)
            .asInspectableView(ofType: ViewType.Text.self)
    }
    
    func message() throws -> InspectableView<ViewType.ClassifiedView> {
        return try View.supplementaryChildren(self).element(at: 1)
            .asInspectableView(ofType: ViewType.ClassifiedView.self)
    }
    
    func primaryButton() throws -> InspectableView<ViewType.AlertButton> {
        return try View.supplementaryChildren(self).element(at: 2)
            .asInspectableView(ofType: ViewType.AlertButton.self)
    }
    
    func secondaryButton() throws -> InspectableView<ViewType.AlertButton> {
        return try View.supplementaryChildren(self).element(at: 3)
            .asInspectableView(ofType: ViewType.AlertButton.self)
    }
    
    func dismiss() throws {
        do {
            let container = try Inspector.cast(
                value: content.view, type: ViewType.PopupContainer<ViewType.Alert>.self)
            container.presenter.dismissPopup()
        } catch {
            if #available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *),
               let binding = try? isPresentedBinding() {
                binding.wrappedValue = false
            } else {
                throw error
            }
        }
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
public extension InspectableView where View == ViewType.Alert {
    
    func actions() throws -> InspectableView<ViewType.ClassifiedView> {
        return try View.supplementaryChildren(self).element(at: 2)
            .asInspectableView(ofType: ViewType.ClassifiedView.self)
    }
}

// MARK: - Non Standard Children

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension ViewType.Alert: SupplementaryChildren {
    static func supplementaryChildren(_ parent: UnwrappedView) throws -> LazyGroup<SupplementaryView> {
        let iOS15Modifier = parent.content.isIOS15Modifier
        return .init(count: iOS15Modifier ? 3 : 4) { index in
            let medium = parent.content.medium.resettingViewModifiers()
            switch index {
            case 0:
                let path = iOS15Modifier ? "title" : "popup|title"
                let view = try Inspector.attribute(path: path, value: parent.content.view)
                let content = try Inspector.unwrap(content: Content(view, medium: medium))
                return try InspectableView<ViewType.Text>(content, parent: parent, call: "title()")
            case 1:
                let path = iOS15Modifier ? "message" : "popup|message"
                do {
                    let view = try Inspector.attribute(path: path, value: parent.content.view)
                    let content = try Inspector.unwrap(content: Content(view, medium: medium))
                    return try InspectableView<ViewType.ClassifiedView>(
                        content, parent: parent, call: "message()")
                } catch {
                    if let inspError = error as? InspectionError,
                       case .viewNotFound = inspError {
                        throw InspectionError.viewNotFound(parent: "message")
                    }
                    throw error
                }
            case 2:
                if iOS15Modifier {
                    let view = try Inspector.attribute(path: "actions", value: parent.content.view)
                    let content = try Inspector.unwrap(content: Content(view, medium: medium))
                    return try InspectableView<ViewType.ClassifiedView>(
                        content, parent: parent, call: "actions()")
                }
                let view = try Inspector.attribute(path: "popup|primaryButton", value: parent.content.view)
                let content = try Inspector.unwrap(content: Content(view, medium: medium))
                return try InspectableView<ViewType.AlertButton>(
                    content, parent: parent, call: "primaryButton()")
            default:
                let maybeView = try Inspector.attribute(
                    path: "popup|secondaryButton", value: parent.content.view, type: Alert.Button?.self)
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
                label: "presenter", value: container,
                type: BasePopupPresenter.self)
        else { throw InspectionError.parentViewNotFound(view: "Alert.Button") }
        presenter.dismissPopup()
        typealias Callback = () -> Void
        let callback = try Inspector
            .attribute(label: "action", value: content.view, type: Callback.self)
        callback()
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
private extension InspectableView where View == ViewType.Alert {
    func isPresentedBinding() throws -> Binding<Bool> {
        return try Inspector.attribute(
            label: "isPresented", value: content.view, type: Binding<Bool>.self)
    }
}
