import SwiftUI

public extension ViewType {
    
    struct AnyView: KnownViewType {
        public static var typePrefix: String = "AnyView"
    }
}

// MARK: - Content Extraction

extension ViewType.AnyView: SingleViewContent {
    
    public static func child(_ content: Content) throws -> Content {
        let view = try Inspector.attribute(path: "storage|view", value: content.view)
        return try Inspector.unwrap(view: view, modifiers: [])
    }
}

// MARK: - Extraction from SingleViewContent parent

public extension InspectableView where View: SingleViewContent {
    
    func anyView() throws -> InspectableView<ViewType.AnyView> {
        return try .init(try child())
    }
}

// MARK: - Extraction from MultipleViewContent parent

public extension InspectableView where View: MultipleViewContent {
    
    func anyView(_ index: Int) throws -> InspectableView<ViewType.AnyView> {
        return try .init(try child(at: index))
    }
}
