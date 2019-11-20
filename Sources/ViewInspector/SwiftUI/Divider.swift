import SwiftUI

public extension ViewType {
    
    struct Divider: KnownViewType {
        public static var typePrefix: String = "Divider"
    }
}

public extension Divider {
    
    func inspect() throws -> InspectableView<ViewType.Divider> {
        return try InspectableView<ViewType.Divider>(self)
    }
}

// MARK: - Extraction from SingleViewContent parent

public extension InspectableView where View: SingleViewContent {
    
    func divider() throws -> InspectableView<ViewType.Divider> {
        let content = try View.content(view: view, envObject: envObject)
        return try InspectableView<ViewType.Divider>(content)
    }
}

// MARK: - Extraction from MultipleViewContent parent

public extension InspectableView where View: MultipleViewContent {
    
    func divider(_ index: Int) throws -> InspectableView<ViewType.Divider> {
        let content = try contentView(at: index)
        return try InspectableView<ViewType.Divider>(content)
    }
}
