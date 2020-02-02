import SwiftUI

public extension ViewType {
    
    struct Divider: KnownViewType {
        public static var typePrefix: String = "Divider"
    }
}

// MARK: - Extraction from SingleViewContent parent

public extension InspectableView where View: SingleViewContent {
    
    func divider() throws -> InspectableView<ViewType.Divider> {
        return try .init(try child())
    }
}

// MARK: - Extraction from MultipleViewContent parent

public extension InspectableView where View: MultipleViewContent {
    
    func divider(_ index: Int) throws -> InspectableView<ViewType.Divider> {
        return try .init(try child(at: index))
    }
}
