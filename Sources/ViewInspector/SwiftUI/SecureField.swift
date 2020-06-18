import SwiftUI

public extension ViewType {
    
    struct SecureField: KnownViewType {
        public static var typePrefix: String = "SecureField"
    }
}

// MARK: - Content Extraction

extension ViewType.SecureField: SingleViewContent {
    
    public static func child(_ content: Content) throws -> Content {
        let view = try Inspector.attribute(label: "label", value: content.view)
        return try Inspector.unwrap(view: view, modifiers: [])
    }
}

// MARK: - Extraction from SingleViewContent parent

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView where View: SingleViewContent {
    
    func secureField() throws -> InspectableView<ViewType.SecureField> {
        return try .init(try child())
    }
}

// MARK: - Extraction from MultipleViewContent parent

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView where View: MultipleViewContent {
    
    func secureField(_ index: Int) throws -> InspectableView<ViewType.SecureField> {
        return try .init(try child(at: index))
    }
}

// MARK: - Custom Attributes

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView where View == ViewType.SecureField {
    
    func callOnCommit() throws {
        let action = try Inspector.attribute(label: "onCommit", value: content.view)
        typealias Callback = () -> Void
        if let callback = action as? Callback {
            callback()
        }
    }
}
