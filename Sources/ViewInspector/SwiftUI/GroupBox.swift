import SwiftUI

#if os(macOS)

public extension ViewType {
    
    struct GroupBox: KnownViewType {
        public static let typePrefix: String = "GroupBox"
    }
}

public extension GroupBox {
    
    func inspect() throws -> InspectableView<ViewType.GroupBox> {
        return try .init(ViewInspector.Content(self))
    }
}

// MARK: - Content Extraction

extension ViewType.GroupBox: MultipleViewContent {
    
    public static func children(_ content: Content, injection: Any) throws -> LazyGroup<Content> {
        let content = try Inspector.attribute(label: "content", value: content.view)
        return try Inspector.viewsInContainer(view: content)
    }
}

// MARK: - Extraction from SingleViewContent parent

public extension InspectableView where View: SingleViewContent {
    
    func groupBox() throws -> InspectableView<ViewType.GroupBox> {
        return try .init(try child())
    }
}

// MARK: - Extraction from MultipleViewContent parent

public extension InspectableView where View: MultipleViewContent {
    
    func groupBox(_ index: Int) throws -> InspectableView<ViewType.GroupBox> {
        return try .init(try child(at: index))
    }
}

#endif
