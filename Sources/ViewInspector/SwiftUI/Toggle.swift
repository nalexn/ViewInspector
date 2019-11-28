import SwiftUI

public extension ViewType {
    
    struct Toggle: KnownViewType {
        public static var typePrefix: String = "Toggle"
    }
}

public extension Toggle {
    
    func inspect() throws -> InspectableView<ViewType.Toggle> {
        return try InspectableView<ViewType.Toggle>(self)
    }
}

// MARK: - Content Extraction

extension ViewType.Toggle: SingleViewContent {
    
    public static func content(view: Any, envObject: Any) throws -> Any {
        let view = try Inspector.attribute(label: "_label", value: view)
        return try Inspector.unwrap(view: view)
    }
}

// MARK: - Extraction from SingleViewContent parent

public extension InspectableView where View: SingleViewContent {
    
    func toggle() throws -> InspectableView<ViewType.Toggle> {
        let content = try View.content(view: view, envObject: envObject)
        return try InspectableView<ViewType.Toggle>(content)
    }
}

// MARK: - Extraction from MultipleViewContent parent

public extension InspectableView where View: MultipleViewContent {
    
    func toggle(_ index: Int) throws -> InspectableView<ViewType.Toggle> {
        let content = try contentView(at: index)
        return try InspectableView<ViewType.Toggle>(content)
    }
}
