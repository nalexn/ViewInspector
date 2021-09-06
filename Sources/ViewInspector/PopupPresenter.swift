import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public protocol PopupPresenter {
    func buildPopup() throws -> Any
    func dismissPopup()
    func content() throws -> ViewInspector.Content
    var isAlertPresenter: Bool { get }
    var isActionSheetPresenter: Bool { get }
    var isPopoverPresenter: Bool { get }
    var isSheetPresenter: Bool { get }
    var isFullScreenCoverPresenter: Bool { get }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public protocol SimplePopupPresenter: PopupPresenter {
    associatedtype Popup
    var isPresented: Binding<Bool> { get }
    var popupBuilder: () -> Popup { get }
    var onDismiss: (() -> Void)? { get }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public protocol ItemPopupPresenter: PopupPresenter {
    associatedtype Popup
    associatedtype Item: Identifiable
    var item: Binding<Item?> { get }
    var popupBuilder: (Item) -> Popup { get }
    var onDismiss: (() -> Void)? { get }
}

// MARK: - Extensions

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension PopupPresenter {
    func subject<T>(_ type: T.Type) -> String {
        if isPopoverPresenter { return "Popover" }
        if isSheetPresenter { return "Sheet" }
        if isFullScreenCoverPresenter { return "FullScreenCover" }
        return Inspector.typeName(type: T.self)
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension SimplePopupPresenter {
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
public extension SimplePopupPresenter where Popup == Alert {
    var isAlertPresenter: Bool { true }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension ItemPopupPresenter where Popup == Alert {
    var isAlertPresenter: Bool { true }
}

// MARK: - ActionSheet

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension SimplePopupPresenter where Popup == ActionSheet {
    var isActionSheetPresenter: Bool { true }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension ItemPopupPresenter where Popup == ActionSheet {
    var isActionSheetPresenter: Bool { true }
}

// MARK: - Popover, Sheet & FullScreenCover

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension ViewModifier where Self: PopupPresenter {
    func content() throws -> ViewInspector.Content {
        let view = body(content: _ViewModifier_Content())
        return try view.inspect().viewModifierContent().content
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension ViewModifier where Self: SimplePopupPresenter {
    var isPopoverPresenter: Bool {
        return (try? content().standardPopoverModifier()) != nil
    }
    var isSheetPresenter: Bool {
        return (try? content().standardSheetModifier()) != nil
    }
    var isFullScreenCoverPresenter: Bool {
        return (try? content().standardFullScreenCoverModifier()) != nil
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
    var isFullScreenCoverPresenter: Bool {
        return (try? content().standardFullScreenCoverModifier()) != nil
    }
}

// MARK: - Default

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension PopupPresenter {
    var isAlertPresenter: Bool { false }
    var isActionSheetPresenter: Bool { false }
    var isPopoverPresenter: Bool { false }
    var isSheetPresenter: Bool { false }
    var isFullScreenCoverPresenter: Bool { false }
}
