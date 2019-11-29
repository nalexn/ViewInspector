import SwiftUI

#if !os(watchOS)

public extension ViewType {
    
    struct TabView: KnownViewType {
        public static var typePrefix: String = "TabView"
    }
}

public extension TabView {
    
    func inspect() throws -> InspectableView<ViewType.TabView> {
        return try InspectableView<ViewType.TabView>(self)
    }
}

// MARK: - Content Extraction

extension ViewType.TabView: MultipleViewContent {
    
    public static func content(view: Any, envObject: Any) throws -> LazyGroup<Any> {
        let content = try Inspector.attribute(label: "content", value: view)
        return try Inspector.viewsInContainer(view: content)
    }
}

// MARK: - Extraction from SingleViewContent parent

public extension InspectableView where View: SingleViewContent {
    
    func tabView() throws -> InspectableView<ViewType.TabView> {
        let content = try View.content(view: view, envObject: envObject)
        return try InspectableView<ViewType.TabView>(content)
    }
}

// MARK: - Extraction from MultipleViewContent parent

public extension InspectableView where View: MultipleViewContent {
    
    func tabView(_ index: Int) throws -> InspectableView<ViewType.TabView> {
        let content = try contentView(at: index)
        return try InspectableView<ViewType.TabView>(content)
    }
}

#endif
