import SwiftUI

public extension ViewType {
    
    struct Form: KnownViewType {
        public static let typePrefix: String = "Form"
    }
}

public extension Form {
    
    func inspect() throws -> InspectableView<ViewType.Form> {
        return try .init(ViewInspector.Content(self))
    }
}

// MARK: - Content Extraction

extension ViewType.Form: MultipleViewContent {
    
    public static func children(_ content: Content, injection: Any) throws -> LazyGroup<Content> {
        let content = try Inspector.attribute(label: "content", value: content.view)
        return try Inspector.viewsInContainer(view: content)
    }
}

// MARK: - Extraction from SingleViewContent parent

public extension InspectableView where View: SingleViewContent {
    
    func form() throws -> InspectableView<ViewType.Form> {
        return try .init(try child())
    }
}

// MARK: - Extraction from MultipleViewContent parent

public extension InspectableView where View: MultipleViewContent {
    
    func form(_ index: Int) throws -> InspectableView<ViewType.Form> {
        return try .init(try child(at: index))
    }
}
