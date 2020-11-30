import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension ViewType {
    
    struct ViewBuilder<T>: KnownViewType, CustomViewType where T: Inspectable {
        public static var typePrefix: String {
            return Inspector.typeName(type: T.self, prefixOnly: true)
        }
        
        public static func inspectionCall(index: Int?) -> String {
            if let index = index {
                return ".view(\(typePrefix), \(index))"
            }
            return ".view(\(typePrefix))"
        }
    }
}

// MARK: - Content Extraction

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension ViewType.ViewBuilder: MultipleViewContent {
    
    public static func children(_ content: Content) throws -> LazyGroup<Content> {
        let content = try Inspector.attribute(label: "content", value: content.view)
        return try Inspector.viewsInContainer(view: content)
    }
}
