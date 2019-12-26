import SwiftUI

public extension ViewType {
    
    struct SecureField: KnownViewType {
        public static var typePrefix: String = "SecureField"
    }
}

public extension SecureField {
    
    func inspect() throws -> InspectableView<ViewType.SecureField> {
        return try .init(ViewInspector.Content(self))
    }
}

// MARK: - Content Extraction

extension ViewType.SecureField: SingleViewContent {
    
    public static func child(_ content: Content, injection: Any) throws -> Content {
        let view = try Inspector.attribute(label: "label", value: content.view)
        return try Inspector.unwrap(view: view, modifiers: [])
    }
}

// MARK: - Extraction from SingleViewContent parent

public extension InspectableView where View: SingleViewContent {
    
    func secureField() throws -> InspectableView<ViewType.SecureField> {
        return try .init(try child())
    }
}

// MARK: - Extraction from MultipleViewContent parent

public extension InspectableView where View: MultipleViewContent {
    
    func secureField(_ index: Int) throws -> InspectableView<ViewType.SecureField> {
        return try .init(try child(at: index))
    }
}

// MARK: - Custom Attributes

public extension InspectableView where View == ViewType.SecureField {
    
    func callOnCommit() throws {
        let action = try Inspector.attribute(label: "onCommit", value: content.view)
        typealias Callback = () -> Void
        if let callback = action as? Callback {
            callback()
        }
    }
}
