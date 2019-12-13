import SwiftUI

internal extension ViewType {
    struct TreeView {}
}

extension ViewType.TreeView: SingleViewContent {

    static func content(view: Any, envObject: Any) throws -> Any {
        let view = try Inspector.attribute(path: "root|content", value: view)
        return try Inspector.unwrap(view: view)
    }
}
