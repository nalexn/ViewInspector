import SwiftUI

public extension ViewType {
    
    struct List: KnownViewType {
        public static let typePrefix: String = "List"
    }
}

// MARK: - Content Extraction

extension ViewType.List: MultipleViewContent {
    
    public static func children(_ content: Content) throws -> LazyGroup<Content> {
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
