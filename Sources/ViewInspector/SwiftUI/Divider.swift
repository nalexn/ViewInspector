import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension ViewType {
    
    struct Divider: KnownViewType {
        public static var typePrefix: String = "Divider"
    }
}

// MARK: - Extraction from SingleViewContent parent

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView where View: SingleViewContent {
    
    func divider() throws -> InspectableView<ViewType.Divider> {
        return try .init(try child(), parent: self)
    }
}

// MARK: - Extraction from MultipleViewContent parent

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView where View: MultipleViewContent {
    
    func divider(_ index: Int) throws -> InspectableView<ViewType.Divider> {
        return try .init(try child(at: index), parent: self, index: index)
    }
}
