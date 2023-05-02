import SwiftUI

@available(macOS 10.15, *)
internal extension ViewType {
    struct PopoverContent { }
}

// MARK: - Content Extraction

@available(macOS 10.15, *)
extension ViewType.PopoverContent: SingleViewContent {

    static func child(_ content: Content) throws -> Content {
        let view = try Inspector.attribute(label: "content", value: content.view)
        return try Inspector.unwrap(view: view, medium: content.medium)
    }
}
