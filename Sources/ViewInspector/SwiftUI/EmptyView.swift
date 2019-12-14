import SwiftUI

public extension ViewType {
    
    struct EmptyView: KnownViewType {
        public static var typePrefix: String = "EmptyView"
    }
}

public extension EmptyView {
    
    func inspect() throws -> InspectableView<ViewType.EmptyView> {
        return try .init(ViewInspector.Content(self))
    }
}

// MARK: - Extraction from SingleViewContent parent

public extension InspectableView where View: SingleViewContent {
    
    func emptyView() throws -> InspectableView<ViewType.EmptyView> {
        return try .init(try child())
    }
}

// MARK: - Extraction from MultipleViewContent parent

public extension InspectableView where View: MultipleViewContent {
    
    func emptyView(_ index: Int) throws -> InspectableView<ViewType.EmptyView> {
        return try .init(try child(at: index))
    }
}
