import SwiftUI

public extension ViewType {
    
    struct TextField: KnownViewType {
        public static var typePrefix: String = "TextField"
    }
}

public extension TextField {
    
    func inspect() throws -> InspectableView<ViewType.TextField> {
        return try InspectableView<ViewType.TextField>(self)
    }
}

// MARK: - Content Extraction

extension ViewType.TextField: SingleViewContent {
    
    public static func content(view: Any, envObject: Any) throws -> Any {
        let view = try Inspector.attribute(label: "label", value: view)
        return try Inspector.unwrap(view: view)
    }
}

// MARK: - Extraction from SingleViewContent parent

public extension InspectableView where View: SingleViewContent {
    
    func textField() throws -> InspectableView<ViewType.TextField> {
        let content = try View.content(view: view, envObject: envObject)
        return try InspectableView<ViewType.TextField>(content)
    }
}

// MARK: - Extraction from MultipleViewContent parent

public extension InspectableView where View: MultipleViewContent {
    
    func textField(_ index: Int) throws -> InspectableView<ViewType.TextField> {
        let content = try contentView(at: index)
        return try InspectableView<ViewType.TextField>(content)
    }
}

// MARK: - Custom Attributes

public extension InspectableView where View == ViewType.TextField {
    
    func callOnEditingChanged() throws {
        let action = try Inspector.attribute(label: "onEditingChanged", value: view)
        typealias Callback = (Bool) -> Void
        if let callback = action as? Callback {
            callback(false)
        }
    }
    
    func callOnCommit() throws {
        let action = try Inspector.attribute(label: "onCommit", value: view)
        typealias Callback = () -> Void
        if let callback = action as? Callback {
            callback()
        }
    }
}
