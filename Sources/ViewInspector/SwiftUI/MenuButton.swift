import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension ViewType {
    
    struct MenuButton: KnownViewType {
        public static var typePrefix: String = "MenuButton"
    }
}

#if os(macOS)

// MARK: - Content Extraction

@available(macOS 10.15, *)
@available(iOS, unavailable)
@available(tvOS, unavailable)
extension ViewType.MenuButton: SingleViewContent {
    
    public static func child(_ content: Content) throws -> Content {
        let view = try Inspector.attribute(label: "content", value: content.view)
        let medium = content.medium.resettingViewModifiers()
        return try Inspector.unwrap(view: view, medium: medium)
    }
}

// MARK: - Extraction from SingleViewContent parent

@available(macOS 10.15, *)
@available(iOS, unavailable)
@available(tvOS, unavailable)
public extension InspectableView where View: SingleViewContent {
    
    func menuButton() throws -> InspectableView<ViewType.MenuButton> {
        return try .init(try child(), parent: self)
    }
}

// MARK: - Extraction from MultipleViewContent parent

@available(macOS 10.15, *)
@available(iOS, unavailable)
@available(tvOS, unavailable)
public extension InspectableView where View: MultipleViewContent {
    
    func menuButton(_ index: Int) throws -> InspectableView<ViewType.MenuButton> {
        return try .init(try child(at: index), parent: self, index: index)
    }
}

// MARK: - Non Standard Children

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension ViewType.MenuButton: SupplementaryChildrenLabelView { }

// MARK: - Custom Attributes

@available(macOS 10.15, *)
@available(iOS, unavailable)
@available(tvOS, unavailable)
public extension InspectableView where View == ViewType.MenuButton {
    
    func labelView() throws -> InspectableView<ViewType.ClassifiedView> {
        return try View.supplementaryChildren(self).element(at: 0)
            .asInspectableView(ofType: ViewType.ClassifiedView.self)
    }
}

// MARK: - Global View Modifiers

@available(macOS 10.15, *)
@available(iOS, unavailable)
@available(tvOS, unavailable)
public extension InspectableView {

    func menuButtonStyle() throws -> Any {
        let modifier = try self.modifier({ modifier -> Bool in
            return modifier.modifierType.hasPrefix("MenuButtonStyleWriter")
        }, call: "menuButtonStyle")
        return try Inspector.attribute(path: "modifier|style", value: modifier)
    }
}

#endif
