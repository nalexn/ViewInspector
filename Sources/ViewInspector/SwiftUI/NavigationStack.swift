import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension ViewType {
    
    struct NavigationStack: KnownViewType {
        public static var typePrefix: String = "NavigationStack"
    }
}

// MARK: - Content Extraction

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension ViewType.NavigationStack: SingleViewContent {
    
    public static func child(_ content: Content) throws -> Content {
        return try children(content).element(at: 0)
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension ViewType.NavigationStack: MultipleViewContent {
    
    public static func children(_ content: Content) throws -> LazyGroup<Content> {
        let view = try Inspector.attribute(label: "root", value: content.view)
        return try Inspector.viewsInContainer(view: view, medium: content.medium)
    }
}

// MARK: - Extraction from SingleViewContent parent

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public extension InspectableView where View: SingleViewContent {
    
    func navigationStack() throws -> InspectableView<ViewType.NavigationStack> {
        return try .init(try child(), parent: self)
    }
}

// MARK: - Extraction from MultipleViewContent parent

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public extension InspectableView where View: MultipleViewContent {
    
    func navigationStack(_ index: Int) throws -> InspectableView<ViewType.NavigationStack> {
        return try .init(try child(at: index), parent: self, index: index)
    }
}
