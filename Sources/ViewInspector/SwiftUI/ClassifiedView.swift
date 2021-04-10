import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension ViewType {
    
    struct ClassifiedView: KnownViewType {
        public static var typePrefix: String = ""
        public static var isTransitive: Bool { true }
    }
    
    struct ParentView: KnownViewType {
        public static var typePrefix: String = ""
    }
}

// MARK: - Content Extraction

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension ViewType.ClassifiedView: SingleViewContent {
    
    public static func child(_ content: Content) throws -> Content {
        return content
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension ViewType.ParentView: SingleViewContent {
    
    public static func child(_ content: Content) throws -> Content {
        return content
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension ViewType.ClassifiedView: MultipleViewContent {
    
    public static func children(_ content: Content) throws -> LazyGroup<Content> {
        return try Inspector.viewsInContainer(view: content.view, medium: content.medium)
    }
}
