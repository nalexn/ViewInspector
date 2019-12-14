import SwiftUI

public extension ViewType {
    
    struct Toggle: KnownViewType {
        public static var typePrefix: String = "Toggle"
    }
}

public extension Toggle {
    
    func inspect() throws -> InspectableView<ViewType.Toggle> {
        return try .init(ViewInspector.Content(self))
    }
}

// MARK: - Content Extraction

extension ViewType.Toggle: SingleViewContent {
    
    public static func child(_ content: Content, envObject: Any) throws -> Content {
        let view = try Inspector.attribute(label: "_label", value: content.view)
        return try Inspector.unwrap(view: view, modifiers: [])
    }
}

// MARK: - Extraction from SingleViewContent parent

public extension InspectableView where View: SingleViewContent {
    
    func toggle() throws -> InspectableView<ViewType.Toggle> {
        return try .init(try child())
    }
}

// MARK: - Extraction from MultipleViewContent parent

public extension InspectableView where View: MultipleViewContent {
    
    func toggle(_ index: Int) throws -> InspectableView<ViewType.Toggle> {
        return try .init(try child(at: index))
    }
}
