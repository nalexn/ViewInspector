import SwiftUI

internal extension ViewType {
    struct IDView { }
}

// MARK: - Content Extraction

extension ViewType.IDView: SingleViewContent {
    
    static func child(_ content: Content, envObject: Any) throws -> Content {
        let view = try Inspector.attribute(label: "content", value: content.view)
        return try Inspector.unwrap(view: view)
    }
}
