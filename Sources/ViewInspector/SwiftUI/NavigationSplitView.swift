import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension ViewType {
    
    struct NavigationSplitView: KnownViewType {
        public static var typePrefix: String = "NavigationSplitView"
    }
}

// MARK: - Content Extraction

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension ViewType.NavigationSplitView: SingleViewContent {
    
    public static func child(_ content: Content) throws -> Content {
        return try children(content).element(at: 0)
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension ViewType.NavigationSplitView: MultipleViewContent {
    
    public static func children(_ content: Content) throws -> LazyGroup<Content> {
        let view = try Inspector.attribute(label: "content", value: content.view)
        return try Inspector.viewsInContainer(view: view, medium: content.medium)
    }
}

// MARK: - Extraction from SingleViewContent parent

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public extension InspectableView where View: SingleViewContent {
    
    func navigationSplitView() throws -> InspectableView<ViewType.NavigationSplitView> {
        return try .init(try child(), parent: self)
    }
}

// MARK: - Extraction from MultipleViewContent parent

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public extension InspectableView where View: MultipleViewContent {
    
    func navigationSplitView(_ index: Int) throws -> InspectableView<ViewType.NavigationSplitView> {
        return try .init(try child(at: index), parent: self, index: index)
    }
}

// MARK: - Non Standard Children

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension ViewType.NavigationSplitView: SupplementaryChildren {
    static func supplementaryChildren(_ parent: UnwrappedView) throws -> LazyGroup<SupplementaryView> {
        return .init(count: 2) { index in
            let medium = parent.content.medium.resettingViewModifiers()
            if index == 0 {
                let child = try Inspector.attribute(label: "detail", value: parent.content.view)
                let content = try Inspector.unwrap(content: Content(child, medium: medium))
                return try InspectableView<ViewType.ClassifiedView>(
                    content, parent: parent, call: "detailView()")
            } else {
                let child = try Inspector.attribute(label: "sidebar", value: parent.content.view)
                let content = try Inspector.unwrap(content: Content(child, medium: medium))
                return try InspectableView<ViewType.ClassifiedView>(
                    content, parent: parent, call: "sidebarView()")
            }
        }
    }
}

// MARK: - Custom Attributes

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public extension InspectableView where View == ViewType.NavigationSplitView {
    
    func detailView() throws -> InspectableView<ViewType.ClassifiedView> {
        return try View.supplementaryChildren(self).element(at: 0)
            .asInspectableView(ofType: ViewType.ClassifiedView.self)
    }
    
    func sidebarView() throws -> InspectableView<ViewType.ClassifiedView> {
        return try View.supplementaryChildren(self).element(at: 1)
            .asInspectableView(ofType: ViewType.ClassifiedView.self)
    }
}
