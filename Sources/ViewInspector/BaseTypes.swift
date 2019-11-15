import SwiftUI

public struct ViewType { }

// MARK: - Error

public enum InspectionError: Swift.Error {
    case typeMismatch(factual: String, expected: String)
    case childViewNotFound
    case childAttributeNotFound(label: String, type: String)
}

// MARK: - Protocols

public protocol Inspectable {
    var content: Any { get }
}

public extension Inspectable where Self: View {
    var content: Any { body }
}

public protocol SingleViewContent {
    static func content(view: Any) throws -> Any
}

public protocol MultipleViewContent {
    static func content(view: Any) throws -> [Any]
}

public protocol ViewTypeGuard {
    static var typePrefix: String? { get }
}
