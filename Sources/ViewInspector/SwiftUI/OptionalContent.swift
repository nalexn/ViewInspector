import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
internal extension ViewType {
    struct OptionalContent {}
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension ViewType.OptionalContent: SingleViewContent {

    static func child(_ content: Content) throws -> Content {
        guard let child = try? Inspector.attribute(label: "some", value: content.view) else {
            throw InspectionError.viewNotFound(parent: Inspector.typeName(value: content.view as Any))
        }
        return try Inspector.unwrap(view: child, medium: content.medium)
    }
}
