import SwiftUI

public extension ViewType {
    
    struct Button: KnownViewType {
        public static var typePrefix: String = "Button"
    }
}

public extension Button {
    
    func inspect() throws -> InspectableView<ViewType.Button> {
        return try InspectableView<ViewType.Button>(self)
    }
}

// MARK: - SingleViewContent

extension ViewType.Button: SingleViewContent {
    
    public static func content(view: Any, envObject: Any) throws -> Any {
        let view = try Inspector.attribute(label: "_label", value: view)
        return try Inspector.unwrap(view: view)
    }
}

// MARK: - SingleViewContent

public extension InspectableView where View: SingleViewContent {
    
    func button() throws -> InspectableView<ViewType.Button> {
        let content = try View.content(view: view, envObject: envObject)
        return try InspectableView<ViewType.Button>(content)
    }
}

// MARK: - MultipleViewContent

public extension InspectableView where View: MultipleViewContent {
    
    func button(_ index: Int) throws -> InspectableView<ViewType.Button> {
        let content = try contentView(at: index)
        return try InspectableView<ViewType.Button>(content)
    }
}

// MARK: - Custom Attributes

public extension InspectableView where View == ViewType.Button {
    
    func tap() throws {
        let action = try Inspector.attribute(label: "action", value: view)
        typealias Callback = () -> Void
        if let callback = action as? Callback {
            callback()
        }
    }
}
