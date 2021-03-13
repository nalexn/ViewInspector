import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
internal extension ViewType {
    struct TreeView {}
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension ViewType.TreeView: SingleViewContent {

    static func child(_ content: Content) throws -> Content {
        let view = try Inspector.attribute(path: "root|content", value: content.view)
        return try Inspector.unwrap(view: view, medium: content.medium)
    }
}
