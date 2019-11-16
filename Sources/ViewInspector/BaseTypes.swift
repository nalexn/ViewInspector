import SwiftUI

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

public protocol KnownViewType {
    static var typePrefix: String { get }
}

public protocol GenericViewType {
    associatedtype T: Inspectable
}

public struct ViewType { }

// MARK: - Error

public enum InspectionError: Swift.Error {
    case typeMismatch(factual: String, expected: String)
    case childViewNotFound
    case childAttributeNotFound(label: String, type: String)
}

extension InspectionError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case let .typeMismatch(factual, expected):
            return "Type mismatch: \(factual) is not \(expected)"
        case .childViewNotFound:
            return "Child view not found"
        case let .childAttributeNotFound(label, type):
            return "\(type) does not have '\(label)' attribute"
        }
    }
}
