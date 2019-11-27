import SwiftUI

#if !os(tvOS)

public extension ViewType {
    
    struct Slider: KnownViewType {
        public static var typePrefix: String = "Slider"
    }
}

public extension Slider {
    
    func inspect() throws -> InspectableView<ViewType.Slider> {
        return try InspectableView<ViewType.Slider>(self)
    }
}

// MARK: - Content Extraction

extension ViewType.Slider: SingleViewContent {
    
    public static func content(view: Any, envObject: Any) throws -> Any {
        let view = try Inspector.attribute(label: "label", value: view)
        return try Inspector.unwrap(view: view)
    }
}

// MARK: - Extraction from SingleViewContent parent

public extension InspectableView where View: SingleViewContent {
    
    func slider() throws -> InspectableView<ViewType.Slider> {
        let content = try View.content(view: view, envObject: envObject)
        return try InspectableView<ViewType.Slider>(content)
    }
}

// MARK: - Extraction from MultipleViewContent parent

public extension InspectableView where View: MultipleViewContent {
    
    func slider(_ index: Int) throws -> InspectableView<ViewType.Slider> {
        let content = try contentView(at: index)
        return try InspectableView<ViewType.Slider>(content)
    }
}

// MARK: - Custom Attributes

public extension InspectableView where View == ViewType.Slider {
    
    func callOnEditingChanged() throws {
        let action = try Inspector.attribute(label: "onEditingChanged", value: view)
        typealias Callback = (Bool) -> Void
        if let callback = action as? Callback {
            callback(false)
        }
    }
}

#endif
