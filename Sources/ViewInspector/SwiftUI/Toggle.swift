import SwiftUI

public extension ViewType {
    
    struct Toggle: KnownViewType {
        public static var typePrefix: String = "Toggle"
    }
}

// MARK: - Content Extraction

extension ViewType.Toggle: SingleViewContent {
    
    public static func child(_ content: Content) throws -> Content {
        let view = try Inspector.attribute(label: "_label", value: content.view)
        return try Inspector.unwrap(view: view, modifiers: [])
    }
}

// MARK: - Extraction from SingleViewContent parent

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView where View: SingleViewContent {
    
    func toggle() throws -> InspectableView<ViewType.Toggle> {
        return try .init(try child())
    }
}

// MARK: - Extraction from MultipleViewContent parent

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView where View: MultipleViewContent {
    
    func toggle(_ index: Int) throws -> InspectableView<ViewType.Toggle> {
        return try .init(try child(at: index))
    }
}
