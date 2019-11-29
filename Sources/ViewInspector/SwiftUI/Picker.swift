import SwiftUI

public extension ViewType {
    
    struct Picker: KnownViewType {
        public static let typePrefix: String = "Picker"
    }
}

public extension Picker {
    
    func inspect() throws -> InspectableView<ViewType.Picker> {
        return try InspectableView<ViewType.Picker>(self)
    }
}

public extension ViewType.Picker {
    
    struct Label: KnownViewType {
        public static var typePrefix: String = "Picker"
    }
}

// MARK: - Content Extraction

extension ViewType.Picker: MultipleViewContent {
    
    public static func content(view: Any, envObject: Any) throws -> LazyGroup<Any> {
        let content = try Inspector.attribute(label: "content", value: view)
        return try Inspector.viewsInContainer(view: content)
    }
}

extension ViewType.Picker.Label: SingleViewContent {
    
    public static func content(view: Any, envObject: Any) throws -> Any {
        let view = try Inspector.attribute(label: "label", value: view)
        return try Inspector.unwrap(view: view)
    }
}

// MARK: - Extraction from SingleViewContent parent

public extension InspectableView where View: SingleViewContent {
    
    func picker() throws -> InspectableView<ViewType.Picker> {
        let content = try View.content(view: view, envObject: envObject)
        return try InspectableView<ViewType.Picker>(content)
    }
}

// MARK: - Extraction from MultipleViewContent parent

public extension InspectableView where View: MultipleViewContent {
    
    func picker(_ index: Int) throws -> InspectableView<ViewType.Picker> {
        let content = try contentView(at: index)
        return try InspectableView<ViewType.Picker>(content)
    }
}

// MARK: - Custom Attributes

public extension InspectableView where View == ViewType.Picker {
    
    func label() throws -> InspectableView<ViewType.Picker.Label> {
        return try InspectableView<ViewType.Picker.Label>(view)
    }
}
