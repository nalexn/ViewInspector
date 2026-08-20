import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
internal extension ViewType {
    /// The view produced by `Group(subviews:transform:)` and used as the substitute
    /// view of `ForEach(subviews:content:)`.
    struct GroupElementsOfContent { }
}

// MARK: - Content Extraction

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension ViewType.GroupElementsOfContent: SingleViewContent {

    static func child(_ content: Content) throws -> Content {
        // The `transform` closure takes a `SubviewsCollection`, which only the SwiftUI
        // rendering engine can produce, so the closure cannot be called during inspection.
        // The original view is inspected instead: the views it contains are the subviews
        // the closure would receive, just without the transformation applied.
        let view: Any = try {
            if let stored = try? Inspector.attribute(path: "storage|view", value: content.view) {
                return stored
            }
            return try Inspector.attribute(label: "view", value: content.view)
        }()
        return try Inspector.unwrap(view: view, medium: content.medium)
    }
}
