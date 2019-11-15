import SwiftUI

public extension ViewType {
    struct Text: ViewTypeGuard {
        public static let typePrefix: String? = "Text"
    }
}

public extension Text {
    func inspect() throws -> InspectableView<ViewType.Text> {
        return try InspectableView<ViewType.Text>(self)
    }
}

// MARK: - Custom Attributes

public extension InspectableView where View == ViewType.Text {
    func string() throws -> String? {
        return try Inspector.attribute(path: "storage|anyTextStorage|key|key",
                                       value: view) as? String
    }
}
