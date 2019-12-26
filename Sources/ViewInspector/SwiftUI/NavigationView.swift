import SwiftUI

#if !os(watchOS)

public extension ViewType {
    
    struct NavigationView: KnownViewType {
        public static var typePrefix: String = "NavigationView"
    }
}

public extension NavigationView {
    
    func inspect() throws -> InspectableView<ViewType.NavigationView> {
        return try .init(ViewInspector.Content(self))
    }
}

// MARK: - Content Extraction

extension ViewType.NavigationView: MultipleViewContent {
    
    public static func children(_ content: Content, injection: Any) throws -> LazyGroup<Content> {
        let content = try Inspector.attribute(label: "content", value: content.view)
        return try Inspector.viewsInContainer(view: content)
    }
}

// MARK: - Extraction from SingleViewContent parent

public extension InspectableView where View: SingleViewContent {
    
    func navigationView() throws -> InspectableView<ViewType.NavigationView> {
        return try .init(try child())
    }
}

// MARK: - Extraction from MultipleViewContent parent

public extension InspectableView where View: MultipleViewContent {
    
    func navigationView(_ index: Int) throws -> InspectableView<ViewType.NavigationView> {
        return try .init(try child(at: index))
    }
}

#endif
