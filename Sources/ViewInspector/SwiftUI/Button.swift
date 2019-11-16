import SwiftUI

public extension ViewType {
    struct Button: KnownViewType, SingleViewContent {
        public static var typePrefix: String = "Button"
    }
}

public extension ViewType.Button {
    static func content(view: Any) throws -> Any {
        return try Inspector.attribute(label: "_label", value: view)
    }
}

public extension Button {
    func inspect() throws -> InspectableView<ViewType.Button> {
        return try InspectableView<ViewType.Button>(self)
    }
}

// MARK: - Custom Attributes

public extension InspectableView where View == ViewType.Button {
    
    func tap() throws {
        let action = try Inspector.attribute(label: "action", value: view)
        typealias Callback = () -> Void
        guard let callback = action as? Callback
            else { throw InspectionError.typeMismatch(
                factual: Inspector.typeName(value: action),
                expected: Inspector.typeName(type: Callback.self)) }
        callback()
    }
}
