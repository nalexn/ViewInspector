import SwiftUI

internal extension ViewType {
    struct ConditionalContent { }
}

// MARK: - Content Extraction

extension ViewType.ConditionalContent: SingleViewContent {
    
    static func child(_ content: Content, injection: Any) throws -> Content {
        let storage = try Inspector.attribute(label: "storage", value: content.view)
        if let trueContent = try? Inspector.attribute(label: "trueContent", value: storage) {
            return try Inspector.unwrap(view: trueContent, modifiers: [])
        }
        let falseContent = try Inspector.attribute(label: "falseContent", value: storage)
        return try Inspector.unwrap(view: falseContent, modifiers: [])
    }
}
