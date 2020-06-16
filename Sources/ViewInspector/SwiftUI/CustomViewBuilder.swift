import SwiftUI

public extension ViewType {
    
    struct ViewBuilder<T>: KnownViewType, CustomViewType where T: Inspectable {
        public static var typePrefix: String {
            return Inspector.typeName(type: T.self, prefixOnly: true)
        }
    }
}

// MARK: - Content Extraction

extension ViewType.ViewBuilder: MultipleViewContent {
    
    public static func children(_ content: Content) throws -> LazyGroup<Content> {
        let content = try Inspector.attribute(label: "content", value: content.view)
        return try Inspector.viewsInContainer(view: content)
    }
}
