import SwiftUI

@available(iOS 16.0, macOS 13.0, tvOS 16.0, *)
internal extension ViewType {
    struct ViewThatFits {}
}

@available(iOS 16.0, macOS 13.0, tvOS 16.0, *)
extension ViewType.ViewThatFits: SingleViewContent {

    static func child(_ content: Content) throws -> Content {
        let view: Any = try {
            guard let rootContent = try? Inspector.attribute(path: "_tree|content", value: content.view) else {
                // A ViewThatFits View renders only one of its child Views based on the available horizontal space.
                // This inspection returns all children that can potentially be picked by `ViewThatFits`.
                // https://developer.apple.com/documentation/swiftui/viewthatfits
                return try Inspector.attribute(path: "content", value: content.view)
            }

            return rootContent
        }()
        return try Inspector.unwrap(view: view, medium: content.medium)
    }
}
