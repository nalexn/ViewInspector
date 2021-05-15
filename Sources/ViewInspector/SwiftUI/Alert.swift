import SwiftUI

// MARK: - Alert

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension ViewType {
    
    struct Alert: KnownViewType {
        public static var typePrefix: String = "ViewType.Alert.Container"
        public static var namespacedPrefixes: [String] {
            return ["ViewInspector." + typePrefix]
        }
        public static var isTransitive: Bool { true }
    }
}

// MARK: - Extraction

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView {

    func alert() throws -> InspectableView<ViewType.Alert> {
        return try contentForModifierLookup.alert(parent: self)
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
internal extension Content {
    
    func alert(parent: UnwrappedView) throws -> InspectableView<ViewType.Alert> {
        guard let alertBuilder = try? self.modifierAttribute(
                modifierLookup: { _ in true }, path: "modifier",
                type: AlertBuilder.self, call: "")
        else {
            _ = try self.modifier({
                $0.modifierType.contains("AlertTransformModifier")
            }, call: "alert")
            throw InspectionError.notSupported(
                """
                Please refer to the Guide for inspecting the Alert: \
                https://github.com/nalexn/ViewInspector/blob/master/guide.md#alert
                """)
        }
        let alert = try alertBuilder.buildAlert()
        let container = ViewType.Alert.Container(alert: alert, builder: alertBuilder)
        let medium = self.medium.resettingViewModifiers()
        let content = Content(container, medium: medium)
        return try .init(content, parent: parent, call: "alert()")
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
internal extension ViewType.Alert {
    struct Container {
        let alert: SwiftUI.Alert
        let builder: AlertBuilder
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
                return try .init(Content(view, medium: medium), parent: parent, call: "title()")
            case 1:
                let view = try Inspector.attribute(path: "alert|message", value: parent.content.view, type: Text?.self)
                guard let view = view else {
                    throw InspectionError.viewNotFound(parent: "message")
                }
                return try .init(Content(view, medium: medium), parent: parent, call: "message()")
            case 2:
                let view = try Inspector.attribute(path: "alert|primaryButton", value: parent.content.view)
                return try .init(Content(view, medium: medium), parent: parent, call: "primaryButton()")
            default:
                let view = try Inspector.attribute(
                    path: "alert|secondaryButton", value: parent.content.view, type: Alert.Button?.self)
                guard let view = view else {
                    throw InspectionError.viewNotFound(parent: "secondaryButton")
                }
                return try .init(Content(view, medium: medium), parent: parent, call: "secondaryButton()")
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
extension ViewType.AlertButton: SupplementaryChildrenLabelView { }

// MARK: - Custom Attributes

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView where View == ViewType.AlertButton {
    
    func labelView() throws -> InspectableView<ViewType.Text> {
        let view = try View.supplementaryChildren(self).element(at: 0)
        return try .init(view.content, parent: view.parentView)
    }
    
    func tap() throws {
        guard !isDisabled() else { return }
        guard let parent = self.parentView?.content.view as? ViewType.Alert.Container
        else { throw InspectionError.parentViewNotFound(view: "Alert.Button") }
        parent.builder.dismissAlert()
        typealias Callback = () -> Void
        let callback = try Inspector
            .attribute(label: "action", value: content.view, type: Callback.self)
        callback()
    }
}

// MARK: - Alert inspection protocols

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public protocol AlertBuilder {
    func buildAlert() throws -> SwiftUI.Alert
    func dismissAlert()
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public protocol AlertProvider: AlertBuilder {
    var isPresented: Binding<Bool> { get }
    var alertBuilder: () -> SwiftUI.Alert { get }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public protocol AlertItemProvider: AlertBuilder {
    associatedtype Item: Identifiable
    var item: Binding<Item?> { get }
    var alertBuilder: (Item) -> SwiftUI.Alert { get }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension AlertProvider {
    func buildAlert() throws -> SwiftUI.Alert {
        guard isPresented.wrappedValue else {
            throw InspectionError.viewNotFound(parent: "Alert")
        }
        return alertBuilder()
    }
    
    func dismissAlert() {
        isPresented.wrappedValue = false
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension AlertItemProvider {
    func buildAlert() throws -> SwiftUI.Alert {
        guard let value = item.wrappedValue else {
            throw InspectionError.viewNotFound(parent: "Alert")
        }
        return alertBuilder(value)
    }
    
    func dismissAlert() {
        item.wrappedValue = nil
    }
}
