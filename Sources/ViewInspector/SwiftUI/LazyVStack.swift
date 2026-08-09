import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension ViewType {
    
    struct LazyVStack: KnownViewType {
        public static let typePrefix: String = "LazyVStack"
    }
}

// MARK: - Extraction from SingleViewContent parent

@available(iOS 14.0, macOS 11.0, tvOS 14.0, *)
public extension InspectableView where View: SingleViewContent {
    
    func lazyVStack() throws -> InspectableView<ViewType.LazyVStack> {
        return try .init(try child(), parent: self)
    }
}

// MARK: - Extraction from MultipleViewContent parent

@available(iOS 14.0, macOS 11.0, tvOS 14.0, *)
public extension InspectableView where View: MultipleViewContent {
    
    func lazyVStack(_ index: Int) throws -> InspectableView<ViewType.LazyVStack> {
        return try .init(try child(at: index), parent: self, index: index)
    }
}

// MARK: - Content Extraction

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension ViewType.LazyVStack: MultipleViewContent {
    
    public static func children(_ content: Content) throws -> LazyGroup<Content> {
        return try ViewType.LazyHStack.children(content)
    }
}

// MARK: - Custom Attributes

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
public extension InspectableView where View == ViewType.LazyVStack {
    
    func alignment() throws -> HorizontalAlignment {
        guard let layout = try? lazyVStackLayout() else {
            return try Inspector.attribute(
                label: "alignment", value: content.view, type: HorizontalAlignment.self)
        }
        return try Inspector.attribute(
            path: "base|alignment", value: layout, type: HorizontalAlignment.self)
    }

    func spacing() throws -> CGFloat? {
        guard let layout = try? lazyVStackLayout() else {
            return try Inspector.attribute(
                label: "spacing", value: content.view, type: CGFloat?.self)
        }
        return try Inspector.attribute(
            path: "base|spacing", value: layout, type: CGFloat?.self)
    }

    func pinnedViews() throws -> PinnedScrollableViews {
        guard let layout = try? lazyVStackLayout() else {
            return try Inspector.attribute(
                label: "pinnedViews", value: content.view, type: PinnedScrollableViews.self)
        }
        return try Inspector.attribute(
            label: "pinnedViews", value: layout, type: PinnedScrollableViews.self)
    }

    // Absent on iOS 27, where these values live directly on the view.

    private func lazyVStackLayout() throws -> Any {
        if let layout = try? Inspector.attribute(path: "tree|content|root", value: content.view) {
            return layout
        }
        return try Inspector.attribute(path: "tree|root", value: content.view)
    }
}
