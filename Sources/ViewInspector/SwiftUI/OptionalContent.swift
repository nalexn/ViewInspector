import SwiftUI

public extension ViewType {
    struct OptionalContent {}
}

extension ViewType.OptionalContent: SingleViewContent {

    public static func content(view: Any, envObject: Any) throws -> Any {
        guard let content = try (view as? OptionalViewContentProvider)?.content() else {
            throw InspectionError.typeMismatch(view, OptionalViewContentProvider.self)
        }
        return try Inspector.unwrap(view: content)
    }
}

// MARK: - Private

private protocol OptionalViewContentProvider {
    func content() throws -> Any
}

extension Optional: OptionalViewContentProvider {
    
    func content() throws -> Any {
        switch self {
        case let .some(view):
            return try Inspector.unwrap(view: view)
        case .none:
            throw InspectionError.viewNotFound(parent: Inspector.typeName(value: self as Any))
        }
    }
}
