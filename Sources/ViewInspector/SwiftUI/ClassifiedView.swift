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
