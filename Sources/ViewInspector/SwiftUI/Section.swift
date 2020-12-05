import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension ViewType {
    
    struct Section: KnownViewType {
        public static let typePrefix: String = "Section"
    }
}

// MARK: - Content Extraction

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
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
        return try .init(try child(), parent: self)
    }
}

// MARK: - Extraction from MultipleViewContent parent

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView where View: MultipleViewContent {
    
    func section(_ index: Int) throws -> InspectableView<ViewType.Section> {
        return try .init(try child(at: index), parent: self, index: index)
    }
}

// MARK: - Custom Attributes

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView where View == ViewType.Section {
    
    func header() throws -> InspectableView<ViewType.ClassifiedView> {
        let view = try Inspector.attribute(label: "header", value: content.view)
        return try .init(try Inspector.unwrap(content: Content(view)), parent: self)
    }
    
    func footer() throws -> InspectableView<ViewType.ClassifiedView> {
        let view = try Inspector.attribute(label: "footer", value: content.view)
        return try .init(try Inspector.unwrap(content: Content(view)), parent: self)
    }
}
