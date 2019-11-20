import SwiftUI

public extension ViewType {
    
    struct SecureField: KnownViewType {
        public static var typePrefix: String = "SecureField"
    }
}

public extension SecureField {
    
    func inspect() throws -> InspectableView<ViewType.SecureField> {
        return try InspectableView<ViewType.SecureField>(self)
    }
}

// MARK: - Content Extraction

extension ViewType.SecureField: SingleViewContent {
    
    public static func content(view: Any, envObject: Any) throws -> Any {
        let view = try Inspector.attribute(path: "label", value: view)
        return try Inspector.unwrap(view: view)
    }
}

// MARK: - Extraction from SingleViewContent parent

public extension InspectableView where View: SingleViewContent {
    
    func secureField() throws -> InspectableView<ViewType.SecureField> {
        let content = try View.content(view: view, envObject: envObject)
        return try InspectableView<ViewType.SecureField>(content)
    }
}

// MARK: - Extraction from MultipleViewContent parent

public extension InspectableView where View: MultipleViewContent {
    
    func secureField(_ index: Int) throws -> InspectableView<ViewType.SecureField> {
        let content = try contentView(at: index)
        return try InspectableView<ViewType.SecureField>(content)
    }
}

// MARK: - Custom Attributes

public extension InspectableView where View == ViewType.SecureField {
    
    func callOnCommit() throws {
        let action = try Inspector.attribute(label: "onCommit", value: view)
        typealias Callback = () -> Void
        if let callback = action as? Callback {
            callback()
        }
    }
}
