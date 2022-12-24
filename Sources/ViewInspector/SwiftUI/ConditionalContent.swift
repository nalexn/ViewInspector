import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
internal extension ViewType {
    struct ConditionalContent { }
}

// MARK: - Content Extraction

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension ViewType.ConditionalContent: SingleViewContent {
    
    static func child(_ content: Content) throws -> Content {
        let storage = try Inspector.attribute(label: "storage", value: content.view)
        let medium = content.medium
        if let trueContent = try? Inspector.attribute(label: "trueContent", value: storage) {
            return try Inspector.unwrap(view: trueContent, medium: medium)
        }
        let falseContent = try Inspector.attribute(label: "falseContent", value: storage)
        return try Inspector.unwrap(view: falseContent, medium: medium)
    }
}
