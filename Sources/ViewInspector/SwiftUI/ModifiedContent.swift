import SwiftUI

public extension ViewType {
    
    struct ModifiedContent: KnownViewType {
        public static var typePrefix: String = "ModifiedContent"
    }
}

public extension ModifiedContent {
    
    func inspect() throws -> InspectableView<ViewType.ModifiedContent> {
        return try .init(ViewInspector.Content(self))
    }
}

// MARK: - Content Extraction

extension ViewType.ModifiedContent: SingleViewContent {
    
    public static func child(_ content: Content, envObject: Any) throws -> Content {
        let view = try Inspector.attribute(label: "content", value: content.view)
        return try Inspector.unwrap(view: view, modifiers: content.modifiers + [content.view])
    }
}
