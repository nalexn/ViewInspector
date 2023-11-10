import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension ViewType {
    
    struct TextField: KnownViewType {
        public static var typePrefix: String = "TextField"
    }
}

// MARK: - Extraction from SingleViewContent parent

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView where View: SingleViewContent {
    
    func textField() throws -> InspectableView<ViewType.TextField> {
        return try .init(try child(), parent: self)
    }
}

// MARK: - Extraction from MultipleViewContent parent

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView where View: MultipleViewContent {
    
    func textField(_ index: Int) throws -> InspectableView<ViewType.TextField> {
        return try .init(try child(at: index), parent: self, index: index)
    }
}

// MARK: - Non Standard Children

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension ViewType.TextField: SupplementaryChildren {
    
    static func supplementaryChildren(_ parent: UnwrappedView) throws -> LazyGroup<SupplementaryView> {
            return .init(count: 2) { index in
                switch index {
                case 0:
                    let child = try Inspector.attribute(path: "label", value: parent.content.view)
                    let medium = parent.content.medium.resettingViewModifiers()
                    let content = try Inspector.unwrap(content: Content(child, medium: medium))
                    return try InspectableView<ViewType.ClassifiedView>(content, parent: parent, call: "labelView()")
                default:
                    let child = try Inspector.attribute(path: "prompt|some", value: parent.content.view)
                    let medium = parent.content.medium.resettingViewModifiers()
                    let content = try Inspector.unwrap(content: Content(child, medium: medium))
                    return try InspectableView<ViewType.ClassifiedView>(content, parent: parent, call: "prompt()")
                }
            }
        }
}

// MARK: - Custom Attributes

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView where View == ViewType.TextField {
    
    func labelView() throws -> InspectableView<ViewType.ClassifiedView> {
        return try View.supplementaryChildren(self).element(at: 0)
            .asInspectableView(ofType: ViewType.ClassifiedView.self)
    }
    
    func callOnEditingChanged() throws {
        try guardIsResponsive()
        typealias Callback = (Bool) -> Void
        let callback: Callback = try {
            if let value = try? Inspector
                .attribute(label: "onEditingChanged", value: content.view, type: Callback.self) {
                return value
            }
            return try Inspector
                .attribute(path: deprecatedActionsPath("editingChanged"), value: content.view, type: Callback.self)
        }()
        callback(false)
    }
    
    func callOnCommit() throws {
        try guardIsResponsive()
        typealias Callback = () -> Void
        let callback: Callback = try {
            if let value = try? Inspector
                .attribute(label: "onCommit", value: content.view, type: Callback.self) {
                return value
            }
            return try Inspector
                .attribute(path: deprecatedActionsPath("commit"), value: content.view, type: Callback.self)
        }()
        callback()
    }
    
    private func deprecatedActionsPath(_ action: String) -> String {
        return "_state|state|_value|deprecatedActions|some|\(action)"
    }
    
    func input() throws -> String {
        return try inputBinding().wrappedValue
    }
    
    func setInput(_ value: String) throws {
        try guardIsResponsive()
        try inputBinding().wrappedValue = value
    }
    
    private func inputBinding() throws -> Binding<String> {
        let label: String
        if #available(iOS 13.2, macOS 10.17, tvOS 13.2, *) {
            label = "_text"
        } else {
            label = "text"
        }
        return try Inspector.attribute(label: label, value: content.view, type: Binding<String>.self)
    }
    
    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
    func prompt() throws -> InspectableView<ViewType.Text> {
        do {
            return try View.supplementaryChildren(self).element(at: 1)
                .asInspectableView(ofType: ViewType.Text.self)
        } catch {
            throw InspectionError.viewNotFound(parent: "prompt")
        }
    }
}

// MARK: - Global View Modifiers

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView {

    func textFieldStyle() throws -> Any {
        let modifier = try self.modifier({ modifier -> Bool in
            return modifier.modifierType.hasPrefix("TextFieldStyleModifier")
        }, call: "textFieldStyle")
        return try Inspector.attribute(path: "modifier|style", value: modifier)
    }
}
