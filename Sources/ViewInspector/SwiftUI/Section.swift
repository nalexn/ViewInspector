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

// MARK: - Non Standard Children

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension ViewType.Section: SupplementaryChildren {
    static func supplementaryChildren(_ content: Content) throws -> LazyGroup<Content> {
        return .init(count: 2) { index -> Content in
            let label = index == 0 ? "header" : "footer"
            let child = try Inspector.attribute(label: label, value: content.view)
            return try Inspector.unwrap(content: Content(child))
        }
    }
}

// MARK: - Custom Attributes

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView where View == ViewType.Section {
    
    func header() throws -> InspectableView<ViewType.ClassifiedView> {
        let child = try View.supplementaryChildren(content).element(at: 0)
        return try .init(child, parent: self)
    }
    
    func footer() throws -> InspectableView<ViewType.ClassifiedView> {
        let child = try View.supplementaryChildren(content).element(at: 1)
        return try .init(child, parent: self)
    }
}
