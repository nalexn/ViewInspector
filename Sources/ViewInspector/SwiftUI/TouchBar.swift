import SwiftUI

#if os(macOS)
public extension ViewType {
    
    struct TouchBar: KnownViewType {
        public static var typePrefix: String = "TouchBar"
    }
}

public extension TouchBar {
    
    func inspect() throws -> InspectableView<ViewType.TouchBar> {
        return try .init(ViewInspector.Content(self))
    }
}

// MARK: - Content Extraction

extension ViewType.TouchBar: SingleViewContent {
    
    public static func child(_ content: Content, injection: Any) throws -> Content {
        let view = try Inspector.attribute(label: "content", value: content.view)
        return try Inspector.unwrap(view: view, modifiers: [])
    }
}

// MARK: - Custom Attributes

public extension InspectableView where View == ViewType.TouchBar {
    
    func touchBarID() throws -> String {
        return try Inspector
            .attribute(path: "container|id", value: content.view, type: String.self)
    }
}

// MARK: - Global View Modifiers

public extension InspectableView {
    
    func touchBar() throws -> InspectableView<ViewType.TouchBar> {
        let touchBarView = try modifierAttribute(
            modifierName: "_TouchBarModifier", path: "modifier|touchBar",
            type: Any.self, call: "touchBar")
        return try .init(Content(touchBarView))
    }
    
    func touchBarItemPrincipal() throws -> Bool {
        return try modifierAttribute(
            modifierName: "TouchBarItemPrincipalTraitKey", path: "modifier|value",
            type: Bool.self, call: "touchBarItemPrincipal")
    }
    
    func touchBarCustomizationLabel() throws -> InspectableView<ViewType.Text> {
        let view = try modifierAttribute(
            modifierName: "TouchBarCustomizationLabelTraitKey", path: "modifier|value",
            type: Any.self, call: "touchBarCustomizationLabel")
        return try .init(Content(view))
    }
    
    func touchBarItemPresence() throws -> TouchBarItemPresence {
        return try modifierAttribute(
            modifierName: "TouchBarItemPresenceTraitKey", path: "modifier|value|some",
            type: TouchBarItemPresence.self, call: "touchBarItemPresence")
    }
}
#endif
