import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension ViewType {
    
    struct VSplitView: KnownViewType {
        public static let typePrefix: String = "VSplitView"
    }
}

#if os(macOS)

// MARK: - Content Extraction

@available(macOS 10.15, *)
@available(iOS, unavailable)
@available(tvOS, unavailable)
extension ViewType.VSplitView: MultipleViewContent {
    
    public static func children(_ content: Content) throws -> LazyGroup<Content> {
        return try ViewType.HSplitView.children(content)
    }
}

// MARK: - Extraction from SingleViewContent parent

@available(macOS 10.15, *)
@available(iOS, unavailable)
@available(tvOS, unavailable)
public extension InspectableView where View: SingleViewContent {
    
    func vSplitView() throws -> InspectableView<ViewType.VSplitView> {
        return try .init(try child(), parent: self)
    }
}

// MARK: - Extraction from MultipleViewContent parent

@available(macOS 10.15, *)
@available(iOS, unavailable)
@available(tvOS, unavailable)
public extension InspectableView where View: MultipleViewContent {
    
    func vSplitView(_ index: Int) throws -> InspectableView<ViewType.VSplitView> {
        return try .init(try child(at: index), parent: self, index: index)
    }
}

#endif
