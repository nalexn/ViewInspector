import SwiftUI

#if os(iOS) || os(macOS)

public extension ViewType {
    
    struct Stepper: KnownViewType {
        public static var typePrefix: String = "Stepper"
    }
}

public extension Stepper {
    
    func inspect() throws -> InspectableView<ViewType.Stepper> {
        return try .init(ViewInspector.Content(self))
    }
}

// MARK: - Content Extraction

extension ViewType.Stepper: SingleViewContent {
    
    public static func child(_ content: Content) throws -> Content {
        let view = try Inspector.attribute(label: "label", value: content.view)
        return try Inspector.unwrap(view: view, modifiers: [])
    }
}

// MARK: - Extraction from SingleViewContent parent

public extension InspectableView where View: SingleViewContent {
    
    func stepper() throws -> InspectableView<ViewType.Stepper> {
        return try .init(try child())
    }
}

// MARK: - Extraction from MultipleViewContent parent

public extension InspectableView where View: MultipleViewContent {
    
    func stepper(_ index: Int) throws -> InspectableView<ViewType.Stepper> {
        return try .init(try child(at: index))
    }
}

// MARK: - Custom Attributes

public extension InspectableView where View == ViewType.Stepper {
    
    func increment() throws {
        let action = try Inspector.attribute(label: "onIncrement", value: content.view)
        typealias Callback = () -> Void
        if let callback = action as? Callback {
            callback()
        }
    }
    
    func decrement() throws {
        let action = try Inspector.attribute(label: "onDecrement", value: content.view)
        typealias Callback = () -> Void
        if let callback = action as? Callback {
            callback()
        }
    }
    
    func callOnEditingChanged() throws {
        let action = try Inspector.attribute(label: "onEditingChanged", value: content.view)
        typealias Callback = (Bool) -> Void
        if let callback = action as? Callback {
            callback(false)
        }
    }
}

#endif
