import SwiftUI

internal extension ViewType {
    struct EquatableView { }
}

// MARK: - Content Extraction

extension ViewType.EquatableView: SingleViewContent {
    
    static func child(_ content: Content, envObject: Any) throws -> Content {
        let view = try Inspector.attribute(label: "content", value: content.view)
        return try Inspector.unwrap(view: view)
    }
}
