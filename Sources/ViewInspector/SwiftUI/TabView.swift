import SwiftUI

public extension ViewType {
    
    struct TabView: KnownViewType {
        public static var typePrefix: String = "TabView"
    }
}

// MARK: - Content Extraction

extension ViewType.TabView: MultipleViewContent {
    
    public static func children(_ content: Content) throws -> LazyGroup<Content> {
        let content = try Inspector.attribute(label: "content", value: content.view)
        return try Inspector.viewsInContainer(view: content)
    }
}

// MARK: - Extraction from SingleViewContent parent

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView where View: SingleViewContent {
    
    func tabView() throws -> InspectableView<ViewType.TabView> {
        return try .init(try child())
    }
}

// MARK: - Extraction from MultipleViewContent parent

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView where View: MultipleViewContent {
    
    func tabView(_ index: Int) throws -> InspectableView<ViewType.TabView> {
        return try .init(try child(at: index))
    }
}

// MARK: - Global View Modifiers

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView {
    
    func tag() throws -> AnyHashable {
        return try modifierAttribute(
            modifierName: "TagValueTraitKey",
            path: "modifier|value|tagged", type: AnyHashable.self, call: "tag")
    }
    
    func tabItem() throws -> InspectableView<ViewType.ClassifiedView> {
        let rootView = try modifierAttribute(
            modifierName: "TabItemTraitKey", path: "modifier|value|some|storage|view|content",
            type: Any.self, call: "tabItem")
        return try .init(try Inspector.unwrap(content: Content(rootView)))
    }
}
