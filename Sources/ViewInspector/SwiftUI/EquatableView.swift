import SwiftUI

public extension ViewType {
    
    struct EquatableView: KnownViewType {
        public static var typePrefix: String = "EquatableView"
    }
}

public extension EquatableView {
    
    func inspect() throws -> InspectableView<ViewType.EquatableView> {
        return try InspectableView<ViewType.EquatableView>(self)
    }
}

// MARK: - Content Extraction

extension ViewType.EquatableView: SingleViewContent {
    
    public static func content(view: Any, envObject: Any) throws -> Any {
        let view = try Inspector.attribute(label: "content", value: view)
        return try Inspector.unwrap(view: view)
    }
}

// MARK: - Extraction from SingleViewContent parent

public extension InspectableView where View: SingleViewContent {
    
    func equatableView() throws -> InspectableView<ViewType.EquatableView> {
        let content = try View.content(view: view, envObject: envObject)
        return try InspectableView<ViewType.EquatableView>(content)
    }
}

// MARK: - Extraction from MultipleViewContent parent

public extension InspectableView where View: MultipleViewContent {
    
    func equatableView(_ index: Int) throws -> InspectableView<ViewType.EquatableView> {
        let content = try contentView(at: index)
        return try InspectableView<ViewType.EquatableView>(content)
    }
}
