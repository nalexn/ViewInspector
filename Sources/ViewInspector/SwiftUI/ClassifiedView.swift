import SwiftUI

public extension ViewType {
    
    struct ClassifiedView: KnownViewType {
        public static var typePrefix: String = ""
    }
}

// MARK: - Content Extraction

extension ViewType.ClassifiedView: SingleViewContent {
    
    public static func child(_ content: Content) throws -> Content {
        return content
    }
}

extension ViewType.ClassifiedView: MultipleViewContent {
    
    public static func children(_ content: Content) throws -> LazyGroup<Content> {
        return try Inspector.viewsInContainer(view: content.view)
    }
}
