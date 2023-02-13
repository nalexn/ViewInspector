import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
internal extension ViewType {
    struct TreeView {}
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension ViewType.TreeView: SingleViewContent {

    static func child(_ content: Content) throws -> Content {
        let view: Any = try {
            guard let rootContent = try? Inspector.attribute(path: "root|content", value: content.view) else {
                // Try to return the `contents` property directly if the tree root does not contain a View.
                // (e.g. Layout, _VariadicView_MultiViewRoot, _VariadicView_UnaryViewRoot)
                return try Inspector.attribute(path: "content", value: content.view)
            }

            return rootContent
        }()
        return try Inspector.unwrap(view: view, medium: content.medium)
    }
}
