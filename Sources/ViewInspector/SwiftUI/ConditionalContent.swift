import SwiftUI

internal extension ViewType {
    struct ConditionalContent { }
}

// MARK: - Content Extraction

extension ViewType.ConditionalContent: SingleViewContent {
    
    static func content(view: Any, envObject: Any) throws -> Any {
        let storage = try Inspector.attribute(label: "storage", value: view)
        if let trueContent = try? Inspector.attribute(label: "trueContent", value: storage) {
            return try Inspector.unwrap(view: trueContent)
        }
        let falseContent = try Inspector.attribute(label: "falseContent", value: storage)
        return try Inspector.unwrap(view: falseContent)
    }
}
