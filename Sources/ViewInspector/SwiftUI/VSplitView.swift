import SwiftUI

#if os(macOS)

public extension ViewType {
    
    struct VSplitView: KnownViewType {
        public static let typePrefix: String = "VSplitView"
    }
}

public extension VSplitView {
    
    func inspect() throws -> InspectableView<ViewType.VSplitView> {
        return try .init(ViewInspector.Content(self))
    }
}

// MARK: - Content Extraction

extension ViewType.VSplitView: MultipleViewContent {
    
    public static func children(_ content: Content) throws -> LazyGroup<Content> {
        return try ViewType.HSplitView.children(content)
    }
}

// MARK: - Extraction from SingleViewContent parent

public extension InspectableView where View: SingleViewContent {
    
    func vSplitView() throws -> InspectableView<ViewType.VSplitView> {
        return try .init(try child())
    }
}

// MARK: - Extraction from MultipleViewContent parent

public extension InspectableView where View: MultipleViewContent {
    
    func vSplitView(_ index: Int) throws -> InspectableView<ViewType.VSplitView> {
        return try .init(try child(at: index))
    }
}

#endif
