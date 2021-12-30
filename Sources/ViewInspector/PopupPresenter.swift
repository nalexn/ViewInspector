import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public protocol BasePopupPresenter {
    func buildPopup() throws -> Any
    func dismissPopup()
    func content() throws -> ViewInspector.Content
    var isAlertPresenter: Bool { get }
    var isActionSheetPresenter: Bool { get }
    var isPopoverPresenter: Bool { get }
    var isSheetPresenter: Bool { get }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public protocol PopupPresenter: BasePopupPresenter {
    associatedtype Popup
    var isPresented: Binding<Bool> { get }
    var popupBuilder: () -> Popup { get }
    var onDismiss: (() -> Void)? { get }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public protocol ItemPopupPresenter: BasePopupPresenter {
    associatedtype Popup
    associatedtype Item: Identifiable
    var item: Binding<Item?> { get }
    var popupBuilder: (Item) -> Popup { get }
    var onDismiss: (() -> Void)? { get }
}

// MARK: - Extensions

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension BasePopupPresenter {
    func subject<T>(_ type: T.Type) -> String {
        if isPopoverPresenter { return "Popover" }
        if isSheetPresenter { return "Sheet" }
        return Inspector.typeName(type: T.self)
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension PopupPresenter {
    func buildPopup() throws -> Any {
        guard isPresented.wrappedValue else {
            throw InspectionError.viewNotFound(parent: subject(Popup.self))
        }
        return popupBuilder()
    }
    
    func dismissPopup() {
        isPresented.wrappedValue = false
        onDismiss?()
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension ItemPopupPresenter {
    func buildPopup() throws -> Any {
        guard let value = item.wrappedValue else {
            throw InspectionError.viewNotFound(parent: subject(Popup.self))
        }
        return popupBuilder(value)
    }
    
    func dismissPopup() {
        item.wrappedValue = nil
        onDismiss?()
    }
}

// MARK: - Alert

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension PopupPresenter where Popup == Alert {
    var isAlertPresenter: Bool { true }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension ItemPopupPresenter where Popup == Alert {
    var isAlertPresenter: Bool { true }
}

// MARK: - ActionSheet

@available(iOS 13.0, tvOS 13.0, *)
@available(macOS, unavailable)
public extension PopupPresenter where Popup == ActionSheet {
    var isActionSheetPresenter: Bool { true }
}

@available(iOS 13.0, tvOS 13.0, *)
@available(macOS, unavailable)
public extension ItemPopupPresenter where Popup == ActionSheet {
    var isActionSheetPresenter: Bool { true }
}

// MARK: - Popover, Sheet & FullScreenCover

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension ViewModifier where Self: BasePopupPresenter {
    func content() throws -> ViewInspector.Content {
        let view = body(content: _ViewModifier_Content())
        return try view.inspect().viewModifierContent().content
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension ViewModifier where Self: PopupPresenter {
    var isPopoverPresenter: Bool {
        return (try? content().standardPopoverModifier()) != nil
    }
    var isSheetPresenter: Bool {
        return (try? content().standardSheetModifier()) != nil
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension ViewModifier where Self: ItemPopupPresenter {
    var isPopoverPresenter: Bool {
        return (try? content().standardPopoverModifier()) != nil
    }
    var isSheetPresenter: Bool {
        return (try? content().standardSheetModifier()) != nil
    }
}

// MARK: - Default

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension BasePopupPresenter {
    var isAlertPresenter: Bool { false }
    var isActionSheetPresenter: Bool { false }
    var isPopoverPresenter: Bool { false }
    var isSheetPresenter: Bool { false }
}

// MARK: - PopupContainer

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
internal extension ViewType {
    struct PopupContainer<Popup: KnownViewType>: CustomViewIdentityMapping {
        let popup: Any
        let presenter: BasePopupPresenter
        var viewTypeForSearch: KnownViewType.Type { Popup.self }
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
internal extension ViewType {
    static var popupContainerTypePrefix = "ViewInspector.ViewType.PopupContainer"
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
internal extension ViewType.PopupContainer {
    static var typePrefix: String {
        return ViewType.popupContainerTypePrefix +
            "<ViewInspector.ViewType.\(Inspector.typeName(type: Popup.self))>"
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
internal extension Content {
    func popup<Popup: KnownViewType>(
        parent: UnwrappedView, index: Int?,
        name: String = Inspector.typeName(type: Popup.self),
        modifierPredicate: ModifierLookupClosure,
        standardPredicate: (String) throws -> Any
    ) throws -> InspectableView<Popup> {
        guard let popupPresenter = try? self.modifierAttribute(
                modifierLookup: modifierPredicate, path: "modifier",
                type: BasePopupPresenter.self, call: "", index: index ?? 0)
        else {
            _ = try standardPredicate(name)
            throw InspectionError.notSupported(
                """
                Please refer to the Guide for inspecting the \(name): \
                https://github.com/nalexn/ViewInspector/blob/master/guide_popups.md#\(name.lowercased())
                """)
        }
        let popup: Any = try {
            do {
                return try popupPresenter.buildPopup()
            } catch {
                if case InspectionError.viewNotFound = error {
                    throw InspectionError.viewNotFound(parent: name)
                }
                throw error
            }
        }()
        let container = ViewType.PopupContainer<Popup>(popup: popup, presenter: popupPresenter)
        let medium = self.medium.resettingViewModifiers()
        let content = Content(container, medium: medium)
        let call = ViewType.inspectionCall(
            base: Popup.inspectionCall(typeName: name), index: index)
        return try .init(content, parent: parent, call: call, index: index)
    }
}
