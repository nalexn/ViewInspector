import SwiftUI

public extension ViewType {
    
    struct List: KnownViewType {
        public static let typePrefix: String = "List"
    }
}

public extension List {
    
    func inspect() throws -> InspectableView<ViewType.List> {
        return try .init(ViewInspector.Content(self))
    }
}

// MARK: - Content Extraction

extension ViewType.List: MultipleViewContent {
    
    public static func children(_ content: Content, envObject: Any) throws -> LazyGroup<Content> {
        let content = try Inspector.attribute(label: "content", value: content.view)
        return try Inspector.viewsInContainer(view: content)
    }
}

// MARK: - Extraction from SingleViewContent parent

public extension InspectableView where View: SingleViewContent {
    
    func list() throws -> InspectableView<ViewType.List> {
        return try .init(try child())
    }
}

// MARK: - Extraction from MultipleViewContent parent

public extension InspectableView where View: MultipleViewContent {
    
    func list(_ index: Int) throws -> InspectableView<ViewType.List> {
        return try .init(try child(at: index))
    }
}
