import SwiftUI

#if os(macOS)

public extension ViewType {
    
    struct HSplitView: KnownViewType {
        public static let typePrefix: String = "HSplitView"
    }
}

public extension HSplitView {
    
    func inspect() throws -> InspectableView<ViewType.HSplitView> {
        return try InspectableView<ViewType.HSplitView>(self)
    }
}

// MARK: - Content Extraction

extension ViewType.HSplitView: MultipleViewContent {
    
    public static func content(view: Any, envObject: Any) throws -> [Any] {
        return try ViewType.HStack.content(view: view, envObject: envObject)
    }
}

// MARK: - Extraction from SingleViewContent parent

public extension InspectableView where View: SingleViewContent {
    
    func hSplitView() throws -> InspectableView<ViewType.HSplitView> {
        let content = try View.content(view: view, envObject: envObject)
        return try InspectableView<ViewType.HSplitView>(content)
    }
}

// MARK: - Extraction from MultipleViewContent parent

public extension InspectableView where View: MultipleViewContent {
    
    func hSplitView(_ index: Int) throws -> InspectableView<ViewType.HSplitView> {
        let content = try contentView(at: index)
        return try InspectableView<ViewType.HSplitView>(content)
    }
}

#endif
