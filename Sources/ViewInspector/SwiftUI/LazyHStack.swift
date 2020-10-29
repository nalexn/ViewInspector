import SwiftUI

#if !os(macOS)
public extension ViewType {
    
    struct LazyHStack: KnownViewType {
        public static var typePrefix: String = "LazyHStack"
    }
}

// MARK: - Extraction from SingleViewContent parent

@available(iOS 14.0, macOS 11.0, tvOS 14.0, *)
public extension InspectableView where View: SingleViewContent {
    
    func lazyHStack() throws -> InspectableView<ViewType.LazyHStack> {
        return try .init(try child())
    }
}

// MARK: - Extraction from MultipleViewContent parent

@available(iOS 14.0, macOS 11.0, tvOS 14.0, *)
public extension InspectableView where View: MultipleViewContent {
    
    func lazyHStack(_ index: Int) throws -> InspectableView<ViewType.LazyHStack> {
        return try .init(try child(at: index))
    }
}

// MARK: - Custom Attributes

@available(iOS 14.0, macOS 11.0, tvOS 14.0, *)
public extension InspectableView where View == ViewType.LazyHStack {
    
    func contentView() throws -> InspectableView<ViewType.ClassifiedView> {
        let view = try Inspector.attribute(path: "tree|content", value: content.view)
        return try .init(try Inspector.unwrap(content: Content(view)))
    }
    
    func alignment() throws -> VerticalAlignment {
        return try Inspector.attribute(
            path: "base|alignment", value: lazyHStackLayout(), type: VerticalAlignment.self)
    }
    
    func spacing() throws -> CGFloat? {
        return try Inspector.attribute(
            path: "base|spacing", value: lazyHStackLayout(), type: CGFloat?.self)
    }
    
    func pinnedViews() throws -> PinnedScrollableViews {
        return try Inspector.attribute(
            label: "pinnedViews", value: lazyHStackLayout(), type: PinnedScrollableViews.self)
    }
    
    private func lazyHStackLayout() throws -> Any {
        return try Inspector.attribute(path: "tree|root", value: content.view)
    }
}
#endif
