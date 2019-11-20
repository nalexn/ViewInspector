import SwiftUI

public extension ViewType {
    
    struct Stepper: KnownViewType {
        public static var typePrefix: String = "Stepper"
    }
}

public extension Stepper {
    
    func inspect() throws -> InspectableView<ViewType.Stepper> {
        return try InspectableView<ViewType.Stepper>(self)
    }
}

// MARK: - Content Extraction

extension ViewType.Stepper: SingleViewContent {
    
    public static func content(view: Any, envObject: Any) throws -> Any {
        let view = try Inspector.attribute(label: "label", value: view)
        return try Inspector.unwrap(view: view)
    }
}

// MARK: - Extraction from SingleViewContent parent

public extension InspectableView where View: SingleViewContent {
    
    func stepper() throws -> InspectableView<ViewType.Stepper> {
        let content = try View.content(view: view, envObject: envObject)
        return try InspectableView<ViewType.Stepper>(content)
    }
}

// MARK: - Extraction from MultipleViewContent parent

public extension InspectableView where View: MultipleViewContent {
    
    func stepper(_ index: Int) throws -> InspectableView<ViewType.Stepper> {
        let content = try contentView(at: index)
        return try InspectableView<ViewType.Stepper>(content)
    }
}

// MARK: - Custom Attributes

public extension InspectableView where View == ViewType.Stepper {
    
    func increment() throws {
        let action = try Inspector.attribute(label: "onIncrement", value: view)
        typealias Callback = () -> Void
        if let callback = action as? Callback {
            callback()
        }
    }
    
    func decrement() throws {
        let action = try Inspector.attribute(label: "onDecrement", value: view)
        typealias Callback = () -> Void
        if let callback = action as? Callback {
            callback()
        }
    }
    
    func callOnEditingChanged() throws {
        let action = try Inspector.attribute(label: "onEditingChanged", value: view)
        typealias Callback = (Bool) -> Void
        if let callback = action as? Callback {
            callback(false)
        }
    }
}
