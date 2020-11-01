import SwiftUI

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
        return try .init(try child())
    }
}

// MARK: - Extraction from MultipleViewContent parent

@available(iOS 14.0, macOS 11.0, *)
@available(tvOS, unavailable)
public extension InspectableView where View: MultipleViewContent {
    
    func menu(_ index: Int) throws -> InspectableView<ViewType.Menu> {
        return try .init(try child(at: index))
    }
}

// MARK: - Content Extraction

extension ViewType.Menu: MultipleViewContent {
    
    public static func children(_ content: Content) throws -> LazyGroup<Content> {
        let content = try Inspector.attribute(path: "content", value: content.view)
        return try Inspector.viewsInContainer(view: content)
    }
}

// MARK: - Custom Attributes

@available(iOS 14.0, macOS 11.0, *)
@available(tvOS, unavailable)
public extension InspectableView where View == ViewType.Menu {
    
    func labelView() throws -> InspectableView<ViewType.ClassifiedView> {
        let view = try Inspector.attribute(label: "label", value: content.view)
        return try .init(try Inspector.unwrap(content: Content(view)))
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

#if !os(macOS) && !targetEnvironment(macCatalyst)
// MARK: - MenuStyle inspection

@available(iOS 14.0, macOS 11.0, *)
@available(tvOS, unavailable)
public extension MenuStyle {
    func inspect() throws -> InspectableView<ViewType.ClassifiedView> {
        let config = MenuStyleConfiguration()
        let view = try makeBody(configuration: config).inspect()
        return try .init(view.content)
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
#endif
