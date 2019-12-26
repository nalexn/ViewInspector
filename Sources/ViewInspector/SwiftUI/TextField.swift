import SwiftUI

public extension ViewType {
    
    struct TextField: KnownViewType {
        public static var typePrefix: String = "TextField"
    }
}

public extension TextField {
    
    func inspect() throws -> InspectableView<ViewType.TextField> {
        return try .init(ViewInspector.Content(self))
    }
}

// MARK: - Content Extraction

extension ViewType.TextField: SingleViewContent {
    
    public static func child(_ content: Content, injection: Any) throws -> Content {
        let view = try Inspector.attribute(label: "label", value: content.view)
        return try Inspector.unwrap(view: view, modifiers: [])
    }
}

// MARK: - Extraction from SingleViewContent parent

public extension InspectableView where View: SingleViewContent {
    
    func textField() throws -> InspectableView<ViewType.TextField> {
        return try .init(try child())
    }
}

// MARK: - Extraction from MultipleViewContent parent

public extension InspectableView where View: MultipleViewContent {
    
    func textField(_ index: Int) throws -> InspectableView<ViewType.TextField> {
        return try .init(try child(at: index))
    }
}

// MARK: - Custom Attributes

public extension InspectableView where View == ViewType.TextField {
    
    func callOnEditingChanged() throws {
        let action = try Inspector.attribute(label: "onEditingChanged", value: content.view)
        typealias Callback = (Bool) -> Void
        if let callback = action as? Callback {
            callback(false)
        }
    }
    
    func callOnCommit() throws {
        let action = try Inspector.attribute(label: "onCommit", value: content.view)
        typealias Callback = () -> Void
        if let callback = action as? Callback {
            callback()
        }
    }
}
