import SwiftUI

public extension ViewType {
    
    struct EmptyView: KnownViewType {
        public static var typePrefix: String = "EmptyView"
    }
}

public extension EmptyView {
    
    func inspect() throws -> InspectableView<ViewType.EmptyView> {
        return try InspectableView<ViewType.EmptyView>(self)
    }
}

// MARK: - Extraction from SingleViewContent parent

public extension InspectableView where View: SingleViewContent {
    
    func emptyView() throws -> InspectableView<ViewType.EmptyView> {
        let content = try View.content(view: view, envObject: envObject)
        return try InspectableView<ViewType.EmptyView>(content)
    }
}

// MARK: - Extraction from MultipleViewContent parent

public extension InspectableView where View: MultipleViewContent {
    
    func emptyView(_ index: Int) throws -> InspectableView<ViewType.EmptyView> {
        let content = try contentView(at: index)
        return try InspectableView<ViewType.EmptyView>(content)
    }
}
