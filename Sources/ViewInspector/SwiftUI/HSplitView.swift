import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension ViewType {
    
    struct HSplitView: KnownViewType {
        public static let typePrefix: String = "HSplitView"
    }
}

#if os(macOS)

// MARK: - Content Extraction

@available(macOS 10.15, *)
@available(iOS, unavailable)
@available(tvOS, unavailable)
extension ViewType.HSplitView: MultipleViewContent {
    
    public static func children(_ content: Content) throws -> LazyGroup<Content> {
        let path: String
        if #available(macOS 11.0, *) {
            path = "content"
        } else {
            path = "_tree|content"
        }
        let container = try Inspector.attribute(path: path, value: content.view)
        return try Inspector.viewsInContainer(view: container, medium: content.medium)
    }
}

// MARK: - Extraction from SingleViewContent parent

@available(macOS 10.15, *)
@available(iOS, unavailable)
@available(tvOS, unavailable)
public extension InspectableView where View: SingleViewContent {
    
    func hSplitView() throws -> InspectableView<ViewType.HSplitView> {
        return try .init(try child(), parent: self)
    }
}

// MARK: - Extraction from MultipleViewContent parent

@available(macOS 10.15, *)
@available(iOS, unavailable)
@available(tvOS, unavailable)
public extension InspectableView where View: MultipleViewContent {
    
    func hSplitView(_ index: Int) throws -> InspectableView<ViewType.HSplitView> {
        return try .init(try child(at: index), parent: self, index: index)
    }
}

#endif
