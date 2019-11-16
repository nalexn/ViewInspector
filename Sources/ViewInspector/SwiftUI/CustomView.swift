import SwiftUI

public extension ViewType {
    struct Custom<T>: KnownViewType, GenericViewType, SingleViewContent where T: Inspectable {
        public static var typePrefix: String {
            return Inspector.typeName(type: T.self)
        }
    }
}

public extension ViewType.Custom {
    static func content(view: Any) throws -> Any {
        guard let body = (view as? Inspectable)?.content else {
            throw InspectionError.typeMismatch(factual: Inspector.typeName(value: view),
                                               expected: Inspector.typeName(type: T.self))
        }
        return body
    }
}

public extension View where Self: Inspectable {
    func inspect() throws -> InspectableView<ViewType.Custom<Self>> {
        return try InspectableView<ViewType.Custom<Self>>(self)
    }
}

// MARK: - Custom Attributes

public extension InspectableView where View: GenericViewType {
    func actualView() throws -> View.T {
        guard let casted = view as? View.T else {
            throw InspectionError.typeMismatch(
                factual: Inspector.typeName(value: view),
                expected: Inspector.typeName(type: View.T.self))
        }
        return casted
    }
}
