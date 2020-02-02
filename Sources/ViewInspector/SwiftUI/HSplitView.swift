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
        return try ViewType.HStack.children(content)
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
