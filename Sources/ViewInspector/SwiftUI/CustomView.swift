import SwiftUI

public extension ViewType {
    struct Custom: ViewTypeGuard, SingleViewContent {
        public static let typePrefix: String? = nil
    }
}

public extension ViewType.Custom {
    static func content(view: Any) throws -> Any {
        guard let body = (view as? Inspectable)?.content else {
            throw InspectionError.typeMismatch(factual: Inspector.typeName(value: view),
                                               expected: "View")
        }
        return body
    }
}

public extension View {
    func inspect() throws -> InspectableView<ViewType.Custom> {
        return try InspectableView<ViewType.Custom>(self)
    }
}

// MARK: - Custom Attributes

public extension InspectableView where View == ViewType.Custom {
    func actualView<T>(_ type: T.Type) throws -> T where T: Inspectable {
        guard let casted = view as? T else {
            throw InspectionError.typeMismatch(
                factual: Inspector.typeName(value: view),
                expected: Inspector.typeName(type: type))
        }
        return casted
    }
}
