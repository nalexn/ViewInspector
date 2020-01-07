import SwiftUI

internal extension ViewType {
    struct OptionalContent {}
}

extension ViewType.OptionalContent: SingleViewContent {

    static func child(_ content: Content) throws -> Content {
        guard let child = try (content.view as? OptionalViewContentProvider)?.view() else {
            throw InspectionError.typeMismatch(content.view, OptionalViewContentProvider.self)
        }
        return try Inspector.unwrap(view: child, modifiers: [])
    }
}

// MARK: - Private

private protocol OptionalViewContentProvider {
    func view() throws -> Any
}

extension Optional: OptionalViewContentProvider {
    
    func view() throws -> Any {
        switch self {
        case let .some(view):
            return view
        case .none:
            throw InspectionError.viewNotFound(parent: Inspector.typeName(value: self as Any))
        }
    }
}
