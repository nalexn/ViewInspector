import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension ViewType {

    struct HelpView: KnownViewType {
        public static var typePrefix: String = "HelpView"
    }
}

// MARK: - Children

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension ViewType.HelpView: SingleViewContent {

    public static func child(_ content: Content) throws -> Content {
        let view = try Inspector.attribute(label: "content", value: content.view)
        let medium = content.medium.appending(viewModifier: Container(content: content.view))
        return try Inspector.unwrap(view: view, medium: medium)
    }
}

// MARK: - Help modifier

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView {

    @available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
    func help() throws -> InspectableView<ViewType.Text> {
        return try contentForModifierLookup.help(parent: self, index: nil)
    }
}

// MARK: - Internal

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
internal extension Content {
    func help(parent: UnwrappedView, index: Int?) throws -> InspectableView<ViewType.Text> {
        let text: Any = try {
            if let text = try? modifierAttribute(
                modifierName: ViewType.HelpView.Container.name,
                path: "content|text", type: Any.self, call: "help()") {
                return text
            }
            return try modifierAttribute(
                modifierName: "_TooltipModifier", path: "modifier|text",
                type: Any.self, call: "help()")
        }()
        let medium = self.medium.resettingViewModifiers()
        var view = try InspectableView<ViewType.Text>(Content(text, medium: medium), parent: parent, call: "help()")
        view.isUnwrappedSupplementaryChild = true
        return view
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
internal extension ViewType.HelpView {
    struct Container: ModifierNameProvider {
        let content: Any
        var customModifier: Any? { nil }
        func modifierType(prefixOnly: Bool) -> String { Self.name }
        static var name: String { "_helpView" }
    }
}
