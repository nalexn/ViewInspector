import SwiftUI

#if os(macOS)
public extension ViewType {
    
    struct MenuButton: KnownViewType {
        public static var typePrefix: String = "MenuButton"
    }
}

public extension ViewType.MenuButton {
    
    struct Label: KnownViewType {
        public static var typePrefix: String = "MenuButton"
    }
}

// MARK: - Content Extraction

extension ViewType.MenuButton: SingleViewContent {
    
    public static func child(_ content: Content) throws -> Content {
        let view = try Inspector.attribute(label: "content", value: content.view)
        return try Inspector.unwrap(view: view, modifiers: [])
    }
}

// MARK: - Extraction from SingleViewContent parent

public extension InspectableView where View: SingleViewContent {
    
    func menuButton() throws -> InspectableView<ViewType.MenuButton> {
        return try .init(try child())
    }
}

extension ViewType.MenuButton.Label: SingleViewContent {
    
    public static func child(_ content: Content) throws -> Content {
        let view = try Inspector.attribute(label: "label", value: content.view)
        return try Inspector.unwrap(view: view, modifiers: [])
    }
}

// MARK: - Extraction from MultipleViewContent parent

public extension InspectableView where View: MultipleViewContent {
    
    func menuButton(_ index: Int) throws -> InspectableView<ViewType.MenuButton> {
        return try .init(try child(at: index))
    }
}

// MARK: - Custom Attributes

public extension InspectableView where View == ViewType.MenuButton {
    
    func label() throws -> InspectableView<ViewType.MenuButton.Label> {
        return try .init(content)
    }
}

// MARK: - Global View Modifiers

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView {

    func menuButtonStyle() throws -> Any {
        let modifier = try self.modifier({ modifier -> Bool in
            return modifier.modifierType.hasPrefix("MenuButtonStyleWriter")
        }, call: "menuButtonStyle")
        return try Inspector.attribute(path: "modifier|style", value: modifier)
    }
}

#endif
