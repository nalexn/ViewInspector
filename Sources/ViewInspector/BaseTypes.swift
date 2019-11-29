import SwiftUI

// MARK: - Protocols

public protocol Inspectable {
    var content: Any { get }
}

public extension Inspectable where Self: View {
    var content: Any { body }
}

public protocol InspectableWithEnvObject: EnvironmentObjectInjection {
    associatedtype Body
    associatedtype Object: ObservableObject
    func content(_ object: Object) -> Body
}

public protocol EnvironmentObjectInjection {
    func content(_ object: Any) throws -> Any
}

public protocol SingleViewContent {
    static func content(view: Any, envObject: Any) throws -> Any
}

public protocol MultipleViewContent {
    static func content(view: Any, envObject: Any) throws -> LazyGroup<Any>
}

public protocol KnownViewType {
    static var typePrefix: String { get }
}

public protocol CustomViewType {
    associatedtype T
}

public struct ViewType { }

// MARK: - Error

public enum InspectionError: Swift.Error {
    case typeMismatch(factual: String, expected: String)
    case attributeNotFound(label: String, type: String)
    case viewIndexOutOfBounds(index: Int, count: Int)
    case viewNotFound(parent: String)
    case notSupported(String)
}

extension InspectionError: LocalizedError {
    
    public var errorDescription: String? {
        switch self {
        case let .typeMismatch(factual, expected):
            return "Type mismatch: \(factual) is not \(expected)"
        case let .attributeNotFound(label, type):
            return "\(type) does not have '\(label)' attribute"
        case let .viewIndexOutOfBounds(index, count):
            return "Enclosed view index '\(index)' is out of bounds: '0 ..< \(count)'"
        case let .viewNotFound(parent):
            return "View for \(parent) is absent"
        case let .notSupported(message):
            return "ViewInspector: " + message
        }
    }
}

// MARK: - LazyGroup

public struct LazyGroup<T> {
    
    private let access: (Int) throws -> T
    let count: Int
    
    init(count: Int, _ access: @escaping (Int) throws -> T) {
        self.count = count
        self.access = access
    }
    
    func elementAt(_ index: Int) throws -> T {
        try access(index)
    }
}
