import SwiftUI

public extension ViewType {
    
    struct LazyHGrid: KnownViewType {
        public static var typePrefix: String = "LazyHGrid"
    }
}

// MARK: - Extraction from SingleViewContent parent

@available(iOS 14.0, macOS 11.0, tvOS 14.0, *)
public extension InspectableView where View: SingleViewContent {
    
    func lazyHGrid() throws -> InspectableView<ViewType.LazyHGrid> {
        return try .init(try child())
    }
}

// MARK: - Extraction from MultipleViewContent parent

@available(iOS 14.0, macOS 11.0, tvOS 14.0, *)
public extension InspectableView where View: MultipleViewContent {
    
    func lazyHGrid(_ index: Int) throws -> InspectableView<ViewType.LazyHGrid> {
        return try .init(try child(at: index))
    }
}

// MARK: - Custom Attributes

@available(iOS 14.0, macOS 11.0, tvOS 14.0, *)
public extension InspectableView where View == ViewType.LazyHGrid {
    
    func contentView() throws -> InspectableView<ViewType.ClassifiedView> {
        let view = try Inspector.attribute(path: "tree|content", value: content.view)
        return try .init(try Inspector.unwrap(content: Content(view)))
    }
    
    func alignment() throws -> VerticalAlignment {
        return try Inspector.attribute(
            path: "alignment", value: lazyHGridLayout(), type: VerticalAlignment.self)
    }
    
    func spacing() throws -> CGFloat? {
        return try Inspector.attribute(
            path: "spacing", value: lazyHGridLayout(), type: CGFloat?.self)
    }
    
    func pinnedViews() throws -> PinnedScrollableViews {
        return try Inspector.attribute(
            path: "pinnedViews", value: lazyHGridLayout(), type: PinnedScrollableViews.self)
    }
    
    func rows() throws -> [GridItem] {
        return try Inspector.attribute(
            path: "rows", value: lazyHGridLayout(), type: [GridItem].self)
    }
    
    private func lazyHGridLayout() throws -> Any {
        return try Inspector.attribute(path: "tree|root", value: content.view)
    }
}
