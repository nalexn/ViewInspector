import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension ViewType {
    
    struct LazyVGrid: KnownViewType {
        public static var typePrefix: String = "LazyVGrid"
    }
}

// MARK: - Extraction from SingleViewContent parent

@available(iOS 14.0, macOS 11.0, tvOS 14.0, *)
public extension InspectableView where View: SingleViewContent {
    
    func lazyVGrid() throws -> InspectableView<ViewType.LazyVGrid> {
        return try .init(try child(), parent: self)
    }
}

// MARK: - Extraction from MultipleViewContent parent

@available(iOS 14.0, macOS 11.0, tvOS 14.0, *)
public extension InspectableView where View: MultipleViewContent {
    
    func lazyVGrid(_ index: Int) throws -> InspectableView<ViewType.LazyVGrid> {
        return try .init(try child(at: index), parent: self, index: index)
    }
}

// MARK: - Content Extraction

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension ViewType.LazyVGrid: MultipleViewContent {
    
    public static func children(_ content: Content) throws -> LazyGroup<Content> {
        let view = try Inspector.attribute(path: "tree|content", value: content.view)
        return try Inspector.viewsInContainer(view: view, medium: content.medium)
    }
}

// MARK: - Custom Attributes

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
public extension InspectableView where View == ViewType.LazyVGrid {
    
    func alignment() throws -> HorizontalAlignment {
        return try Inspector.attribute(
            label: "alignment", value: lazyVGridLayout(), type: HorizontalAlignment.self)
    }
    
    func spacing() throws -> CGFloat? {
        return try Inspector.attribute(
            label: "spacing", value: lazyVGridLayout(), type: CGFloat?.self)
    }
    
    func pinnedViews() throws -> PinnedScrollableViews {
        return try Inspector.attribute(
            label: "pinnedViews", value: lazyVGridLayout(), type: PinnedScrollableViews.self)
    }
    
    func columns() throws -> [GridItem] {
        return try Inspector.attribute(
            label: "columns", value: lazyVGridLayout(), type: [GridItem].self)
    }
    
    private func lazyVGridLayout() throws -> Any {
        return try Inspector.attribute(path: "tree|root", value: content.view)
    }
}
