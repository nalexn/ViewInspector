import SwiftUI

public extension ViewType {
    
    struct Button: KnownViewType {
        public static var typePrefix: String = "Button"
    }
}

public extension Button {
    
    func inspect() throws -> InspectableView<ViewType.Button> {
        return try .init(ViewInspector.Content(self))
    }
}

// MARK: - Content Extraction

extension ViewType.Button: SingleViewContent {
    
    public static func child(_ content: Content) throws -> Content {
        let view = try Inspector.attribute(label: "_label", value: content.view)
        return try Inspector.unwrap(view: view, modifiers: [])
    }
}

// MARK: - Extraction from SingleViewContent parent

public extension InspectableView where View: SingleViewContent {
    
    func button() throws -> InspectableView<ViewType.Button> {
        return try .init(try child())
    }
}

// MARK: - Extraction from MultipleViewContent parent

public extension InspectableView where View: MultipleViewContent {
    
    func button(_ index: Int) throws -> InspectableView<ViewType.Button> {
        return try .init(try child(at: index))
    }
}

// MARK: - Custom Attributes

public extension InspectableView where View == ViewType.Button {
    
    func tap() throws {
        let action = try Inspector.attribute(label: "action", value: content.view)
        typealias Callback = () -> Void
        if let callback = action as? Callback {
            callback()
        }
    }
}
