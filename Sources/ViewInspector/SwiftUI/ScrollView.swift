import SwiftUI

public extension ViewType {
    
    struct ScrollView: KnownViewType {
        public static var typePrefix: String = "ScrollView"
    }
}

public extension ScrollView {
    
    func inspect() throws -> InspectableView<ViewType.ScrollView> {
        return try .init(ViewInspector.Content(self))
    }
}

// MARK: - Content Extraction

extension ViewType.ScrollView: SingleViewContent {
    
    public static func child(_ content: Content, injection: Any) throws -> Content {
        let view = try Inspector.attribute(label: "content", value: content.view)
        return try Inspector.unwrap(view: view, modifiers: [])
    }
}

// MARK: - Extraction from SingleViewContent parent

public extension InspectableView where View: SingleViewContent {
    
    func scrollView() throws -> InspectableView<ViewType.ScrollView> {
        return try .init(try child())
    }
}

// MARK: - Extraction from MultipleViewContent parent

public extension InspectableView where View: MultipleViewContent {
    
    func scrollView(_ index: Int) throws -> InspectableView<ViewType.ScrollView> {
        return try .init(try child(at: index))
    }
}

// MARK: - Custom Attributes

public extension InspectableView where View == ViewType.ScrollView {
    
    func contentInsets() throws -> EdgeInsets {
        let value = try Inspector
            .attribute(path: "configuration|contentInsets", value: content.view)
        return (value as? EdgeInsets) ?? EdgeInsets()
    }
}
