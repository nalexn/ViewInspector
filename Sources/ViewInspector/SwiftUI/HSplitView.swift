import SwiftUI

#if os(macOS)

public extension ViewType {
    
    struct HSplitView: KnownViewType {
        public static let typePrefix: String = "HSplitView"
    }
}

// MARK: - Content Extraction

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

public extension InspectableView where View: SingleViewContent {
    
    func hSplitView() throws -> InspectableView<ViewType.HSplitView> {
        return try .init(try child())
    }
}

// MARK: - Extraction from MultipleViewContent parent

public extension InspectableView where View: MultipleViewContent {
    
    func hSplitView(_ index: Int) throws -> InspectableView<ViewType.HSplitView> {
        return try .init(try child(at: index))
    }
}

#endif
