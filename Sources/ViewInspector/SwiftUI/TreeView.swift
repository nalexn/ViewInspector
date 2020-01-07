import SwiftUI

internal extension ViewType {
    struct TreeView {}
}

extension ViewType.TreeView: SingleViewContent {

    static func child(_ content: Content) throws -> Content {
        let view = try Inspector.attribute(path: "root|content", value: content.view)
        return try Inspector.unwrap(view: view, modifiers: content.modifiers)
    }
}
