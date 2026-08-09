import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension ViewType {
    
    struct LazyHStack: KnownViewType {
        public static let typePrefix: String = "LazyHStack"
    }
}

// MARK: - Extraction from SingleViewContent parent

@available(iOS 14.0, macOS 11.0, tvOS 14.0, *)
public extension InspectableView where View: SingleViewContent {
    
    func lazyHStack() throws -> InspectableView<ViewType.LazyHStack> {
        return try .init(try child(), parent: self)
    }
}

// MARK: - Extraction from MultipleViewContent parent

@available(iOS 14.0, macOS 11.0, tvOS 14.0, *)
public extension InspectableView where View: MultipleViewContent {
    
    func lazyHStack(_ index: Int) throws -> InspectableView<ViewType.LazyHStack> {
        return try .init(try child(at: index), parent: self, index: index)
    }
}

// MARK: - Content Extraction

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *) 
extension ViewType.LazyHStack: MultipleViewContent {

    public static func children(_ content: Content) throws -> LazyGroup<Content> {
        // iOS 27 flattened LazyVStack and LazyHStack: the content sits directly on the view,
        // and there is no longer a `tree` wrapper. LazyVGrid and LazyHGrid delegate here and
        // kept the earlier layout, so `tree|content` is attempted first.
        let view: Any
        if let tree = try? Inspector.attribute(path: "tree|content", value: content.view) {
            view = tree
        } else {
            view = try Inspector.attribute(label: "content", value: content.view)
        }
        return try Inspector.viewsInContainer(view: view, medium: content.medium)
    }
}

// MARK: - Custom Attributes

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
public extension InspectableView where View == ViewType.LazyHStack {
    
    func alignment() throws -> VerticalAlignment {
        guard let layout = try? lazyHStackLayout() else {
            return try Inspector.attribute(
                label: "alignment", value: content.view, type: VerticalAlignment.self)
        }
        return try Inspector.attribute(
            path: "base|alignment", value: layout, type: VerticalAlignment.self)
    }

    func spacing() throws -> CGFloat? {
        guard let layout = try? lazyHStackLayout() else {
            return try Inspector.attribute(
                label: "spacing", value: content.view, type: CGFloat?.self)
        }
        return try Inspector.attribute(
            path: "base|spacing", value: layout, type: CGFloat?.self)
    }

    func pinnedViews() throws -> PinnedScrollableViews {
        guard let layout = try? lazyHStackLayout() else {
            return try Inspector.attribute(
                label: "pinnedViews", value: content.view, type: PinnedScrollableViews.self)
        }
        return try Inspector.attribute(
            label: "pinnedViews", value: layout, type: PinnedScrollableViews.self)
    }

    // Absent on iOS 27, where these values live directly on the view.

    private func lazyHStackLayout() throws -> Any {
        if let layout = try? Inspector.attribute(path: "tree|content|root", value: content.view) {
            return layout
        }
        return try Inspector.attribute(path: "tree|root", value: content.view)
    }
}
