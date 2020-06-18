import SwiftUI

public extension ViewType {
    
    struct Section: KnownViewType {
        public static let typePrefix: String = "Section"
    }
}

// MARK: - Content Extraction

extension ViewType.Section: MultipleViewContent {
    
    public static func children(_ content: Content) throws -> LazyGroup<Content> {
        let content = try Inspector.attribute(label: "content", value: content.view)
        return try Inspector.viewsInContainer(view: content)
    }
}

// MARK: - Extraction from SingleViewContent parent

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView where View: SingleViewContent {
    
    func section() throws -> InspectableView<ViewType.Section> {
        return try .init(try child())
    }
}

// MARK: - Extraction from MultipleViewContent parent

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView where View: MultipleViewContent {
    
    func section(_ index: Int) throws -> InspectableView<ViewType.Section> {
        return try .init(try child(at: index))
    }
}
