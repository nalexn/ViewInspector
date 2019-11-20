import SwiftUI

public extension ViewType {
    
    struct ScrollView: KnownViewType {
        public static var typePrefix: String = "ScrollView"
    }
}

public extension ScrollView {
    
    func inspect() throws -> InspectableView<ViewType.ScrollView> {
        return try InspectableView<ViewType.ScrollView>(self)
    }
}

// MARK: - Content Extraction

extension ViewType.ScrollView: SingleViewContent {
    
    public static func content(view: Any, envObject: Any) throws -> Any {
        let view = try Inspector.attribute(path: "content", value: view)
        return try Inspector.unwrap(view: view)
    }
}

// MARK: - Extraction from SingleViewContent parent

public extension InspectableView where View: SingleViewContent {
    
    func scrollView() throws -> InspectableView<ViewType.ScrollView> {
        let content = try View.content(view: view, envObject: envObject)
        return try InspectableView<ViewType.ScrollView>(content)
    }
}

// MARK: - Extraction from MultipleViewContent parent

public extension InspectableView where View: MultipleViewContent {
    
    func scrollView(_ index: Int) throws -> InspectableView<ViewType.ScrollView> {
        let content = try contentView(at: index)
        return try InspectableView<ViewType.ScrollView>(content)
    }
}

// MARK: - Custom Attributes

public extension InspectableView where View == ViewType.ScrollView {
    
    func contentInsets() throws -> EdgeInsets {
        let value = try Inspector
            .attribute(path: "configuration|contentInsets", value: view)
        return (value as? EdgeInsets) ?? EdgeInsets()
    }
}
