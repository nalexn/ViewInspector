import SwiftUI

#if os(macOS)

@available(macOS 10.15, *)
@available(iOS, unavailable)
@available(tvOS, unavailable)
public extension ViewType {
    
    struct HSplitView: KnownViewType {
        public static let typePrefix: String = "HSplitView"
    }
}

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
        return try Inspector.viewsInContainer(view: container)
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
        return try .init(try child(at: index), parent: self)
    }
}

#endif
