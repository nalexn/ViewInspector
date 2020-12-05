import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension ViewType {
    
    struct EmptyView: KnownViewType {
        public static var typePrefix: String = "EmptyView"
    }
}

// MARK: - Extraction from SingleViewContent parent

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView where View: SingleViewContent {
    
    func emptyView() throws -> InspectableView<ViewType.EmptyView> {
        return try .init(try child(), parent: self)
    }
}

// MARK: - Extraction from MultipleViewContent parent

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView where View: MultipleViewContent {
    
    func emptyView(_ index: Int) throws -> InspectableView<ViewType.EmptyView> {
        return try .init(try child(at: index), parent: self, index: index)
    }
}
