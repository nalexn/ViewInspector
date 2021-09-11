import SwiftUI

// MARK: - Alert

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension ViewType {
    
    struct ConfirmationDialog: KnownViewType {
        public static var typePrefix: String = "ConfirmationDialogModifier"
        public static func inspectionCall(typeName: String) -> String {
            return "confirmationDialog(\(ViewType.indexPlaceholder))"
        }
    }
}

// MARK: - Extraction

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
public extension InspectableView {

    func confirmationDialog(_ index: Int? = nil) throws -> InspectableView<ViewType.ConfirmationDialog> {
        return try contentForModifierLookup.confirmationDialog(parent: self, index: index)
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
internal extension Content {
    
    func confirmationDialog(parent: UnwrappedView, index: Int?) throws -> InspectableView<ViewType.ConfirmationDialog> {
        let modifier = try self.modifierAttribute(
            modifierLookup: isConfirmationDialog(modifier:), path: "modifier",
            type: Any.self, call: "confirmationDialog", index: index ?? 0)
        let medium = self.medium.resettingViewModifiers()
        let content = Content(modifier, medium: medium)
        let call = ViewType.inspectionCall(
            base: ViewType.ConfirmationDialog.inspectionCall(typeName: ""), index: index)
        let view = try InspectableView<ViewType.ConfirmationDialog>(
            content, parent: parent, call: call, index: index)
        guard try view.isPresentedBinding().wrappedValue else {
            throw InspectionError.viewNotFound(parent: "ConfirmationDialog")
        }
        return view
    }
    
    private func isConfirmationDialog(modifier: Any) -> Bool {
        guard let modifier = modifier as? ModifierNameProvider
        else { return false }
        return modifier.modifierType.contains(ViewType.ConfirmationDialog.typePrefix)
    }
}

// MARK: - Non Standard Children

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension ViewType.ConfirmationDialog: SupplementaryChildren {
    static func supplementaryChildren(_ parent: UnwrappedView) throws -> LazyGroup<SupplementaryView> {
        return .init(count: 3) { index in
            let medium = parent.content.medium.resettingViewModifiers()
            switch index {
            case 0:
                let view = try Inspector.attribute(path: "title", value: parent.content.view)
                let content = try Inspector.unwrap(content: Content(view, medium: medium))
                return try InspectableView<ViewType.Text>(
                    content, parent: parent, call: "title()")
            case 1:
                let view = try Inspector.attribute(path: "message", value: parent.content.view)
                let content = try Inspector.unwrap(content: Content(view, medium: medium))
                return try InspectableView<ViewType.ClassifiedView>(
                    content, parent: parent, call: "message()")
            default:
                let view = try Inspector.attribute(path: "actions", value: parent.content.view)
                let content = try Inspector.unwrap(content: Content(view, medium: medium))
                return try InspectableView<ViewType.ClassifiedView>(
                    content, parent: parent, call: "actions()")
            }
        }
    }
}

// MARK: - Custom Attributes

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
public extension InspectableView where View == ViewType.ConfirmationDialog {
    
    func title() throws -> InspectableView<ViewType.Text> {
        return try View.supplementaryChildren(self).element(at: 0)
            .asInspectableView(ofType: ViewType.Text.self)
    }
    
    func message() throws -> InspectableView<ViewType.ClassifiedView> {
        return try View.supplementaryChildren(self).element(at: 1)
            .asInspectableView(ofType: ViewType.ClassifiedView.self)
    }
    
    func actions() throws -> InspectableView<ViewType.ClassifiedView> {
        return try View.supplementaryChildren(self).element(at: 2)
            .asInspectableView(ofType: ViewType.ClassifiedView.self)
    }
    
    func titleVisibility() throws -> Visibility {
        return try Inspector.attribute(
            label: "titleVisibility", value: content.view, type: Visibility.self)
    }
    
    func dismiss() throws {
        try isPresentedBinding().wrappedValue = false
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
private extension InspectableView where View == ViewType.ConfirmationDialog {
    func isPresentedBinding() throws -> Binding<Bool> {
        return try Inspector.attribute(
            label: "isPresented", value: content.view, type: Binding<Bool>.self)
    }
}
