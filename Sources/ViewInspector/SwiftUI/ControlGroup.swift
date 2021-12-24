import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension ViewType {

    struct ControlGroup: KnownViewType {
        public static let typePrefix: String = "ControlGroup"
    }
}

// MARK: - Content Extraction

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension ViewType.ControlGroup: SingleViewContent {
    
    public static func child(_ content: Content) throws -> Content {
        return try children(content).element(at: 0)
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension ViewType.ControlGroup: MultipleViewContent {

    public static func children(_ content: Content) throws -> LazyGroup<Content> {
        let container = try Inspector.attribute(label: "content", value: content.view)
        return try Inspector.viewsInContainer(view: container, medium: content.medium)
    }
}

// MARK: - Extraction from SingleViewContent parent

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView where View: SingleViewContent {

    func controlGroup() throws -> InspectableView<ViewType.ControlGroup> {
        return try .init(try child(), parent: self)
    }
}

// MARK: - Extraction from MultipleViewContent parent

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView where View: MultipleViewContent {

    func controlGroup(_ index: Int) throws -> InspectableView<ViewType.ControlGroup> {
        return try .init(try child(at: index), parent: self, index: index)
    }
}
