import SwiftUI

public extension ViewType {
    
    struct Picker: KnownViewType {
        public static let typePrefix: String = "Picker"
    }
}

public extension ViewType.Picker {
    
    struct Label: KnownViewType {
        public static var typePrefix: String = "Picker"
    }
}

// MARK: - Content Extraction

extension ViewType.Picker: MultipleViewContent {
    
    public static func children(_ content: Content) throws -> LazyGroup<Content> {
        let content = try Inspector.attribute(label: "content", value: content.view)
        return try Inspector.viewsInContainer(view: content)
    }
}

extension ViewType.Picker.Label: SingleViewContent {
    
    public static func child(_ content: Content) throws -> Content {
        let view = try Inspector.attribute(label: "label", value: content.view)
        return try Inspector.unwrap(view: view, modifiers: [])
    }
}

// MARK: - Extraction from SingleViewContent parent

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView where View: SingleViewContent {
    
    func picker() throws -> InspectableView<ViewType.Picker> {
        return try .init(try child())
    }
}

// MARK: - Extraction from MultipleViewContent parent

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView where View: MultipleViewContent {
    
    func picker(_ index: Int) throws -> InspectableView<ViewType.Picker> {
        return try .init(try child(at: index))
    }
}

// MARK: - Custom Attributes

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView where View == ViewType.Picker {
    
    func label() throws -> InspectableView<ViewType.Picker.Label> {
        return try .init(content)
    }
}
