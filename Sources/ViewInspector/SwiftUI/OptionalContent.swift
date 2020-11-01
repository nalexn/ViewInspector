import SwiftUI

internal extension ViewType {
    struct OptionalContent {}
}

extension ViewType.OptionalContent: SingleViewContent {

    static func child(_ content: Content) throws -> Content {
        guard let child = try? Inspector.attribute(label: "some", value: content.view) else {
            throw InspectionError.viewNotFound(parent: Inspector.typeName(value: content.view as Any))
        }
        return try Inspector.unwrap(view: child, modifiers: content.modifiers)
    }
}
