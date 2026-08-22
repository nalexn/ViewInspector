import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
internal extension ViewType {
    /// The view produced by `Group(sections:transform:)` and used as the substitute
    /// view of `ForEach(sections:content:)`.
    struct GroupSectionsOfContent { }
}

// MARK: - Content Extraction

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension ViewType.GroupSectionsOfContent: SingleViewContent {

    static func child(_ content: Content) throws -> Content {
        // The `transform` closure takes a `SectionCollection`, which only the SwiftUI
        // rendering engine can produce, so the closure cannot be called during inspection.
        // The original view is inspected instead: the sections it contains are the ones
        // the closure would receive, just without the transformation applied.
        let view = try Inspector.attribute(label: "sections", value: content.view)
        return try Inspector.unwrap(view: view, medium: content.medium)
    }
}
