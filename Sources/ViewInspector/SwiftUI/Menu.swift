import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension ViewType {
    
    struct Menu: KnownViewType {
        public static let typePrefix: String = "Menu"
    }
}

// MARK: - Extraction from SingleViewContent parent

@available(iOS 14.0, macOS 11.0, *)
@available(tvOS, unavailable)
public extension InspectableView where View: SingleViewContent {
    
    func menu() throws -> InspectableView<ViewType.Menu> {
        return try .init(try child(), parent: self)
    }
}

// MARK: - Extraction from MultipleViewContent parent

@available(iOS 14.0, macOS 11.0, *)
@available(tvOS, unavailable)
public extension InspectableView where View: MultipleViewContent {
    
    func menu(_ index: Int) throws -> InspectableView<ViewType.Menu> {
        return try .init(try child(at: index), parent: self, index: index)
    }
}

// MARK: - Content Extraction

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension ViewType.Menu: MultipleViewContent {
    
    public static func children(_ content: Content) throws -> LazyGroup<Content> {
        let view = try Inspector.attribute(path: "content", value: content.view)
        return try Inspector.viewsInContainer(view: view, medium: content.medium)
    }
}

// MARK: - Non Standard Children

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension ViewType.Menu: SupplementaryChildrenLabelView { }

// MARK: - Custom Attributes

@available(iOS 14.0, macOS 11.0, *)
@available(tvOS, unavailable)
public extension InspectableView where View == ViewType.Menu {
    
    func labelView() throws -> InspectableView<ViewType.ClassifiedView> {
        return try View.supplementaryChildren(self).element(at: 0)
    }
}

// MARK: - Global View Modifiers

@available(iOS 14.0, macOS 11.0, *)
@available(tvOS, unavailable)
public extension InspectableView {

    func menuStyle() throws -> Any {
        let modifier = try self.modifier({ modifier -> Bool in
            return modifier.modifierType.hasPrefix("MenuStyleModifier")
        }, call: "menuStyle")
        return try Inspector.attribute(path: "modifier|style", value: modifier)
    }
}

// MARK: - MenuStyle inspection

@available(iOS 14.0, macOS 11.0, *)
@available(tvOS, unavailable)
public extension MenuStyle {
    func inspect() throws -> InspectableView<ViewType.ClassifiedView> {
        let config = MenuStyleConfiguration()
        let view = try makeBody(configuration: config).inspect()
        return try .init(view.content, parent: nil, index: nil)
    }
}

// MARK: - Style Configuration initializer

@available(iOS 14.0, macOS 11.0, *)
@available(tvOS, unavailable)
private extension MenuStyleConfiguration {
    struct Allocator { }
    init() {
        self = unsafeBitCast(Allocator(), to: Self.self)
    }
}
