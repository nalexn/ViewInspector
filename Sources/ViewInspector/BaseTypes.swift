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
    static func child(_ content: Content, envObject: Any) throws -> Content
}

public protocol MultipleViewContent {
    static func children(_ content: Content, envObject: Any) throws -> LazyGroup<Content>
}

public protocol KnownViewType {
    static var typePrefix: String { get }
}

public protocol CustomViewType {
    associatedtype T
}

public struct ViewType { }

public struct Content {
    let view: Any
    let modifiers: [Any]
    
    internal init(_ view: Any, modifiers: [Any] = []) {
        self.view = view
        self.modifiers = modifiers
    }
}

// MARK: - Error

public enum InspectionError: Swift.Error {
    case typeMismatch(factual: String, expected: String)
    case attributeNotFound(label: String, type: String)
    case viewIndexOutOfBounds(index: Int, count: Int)
    case viewNotFound(parent: String)
    case modifierNotFound(parent: String, modifier: String)
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
        case let .modifierNotFound(parent, modifier):
            return "\(parent) does not have '\(modifier)' modifier"
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
    
    func element(at index: Int) throws -> T {
        try access(index)
    }
}

// MARK: - BinaryEquatable

public protocol BinaryEquatable: Equatable { }

extension BinaryEquatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        withUnsafeBytes(of: lhs) { lhsBytes -> Bool in
            withUnsafeBytes(of: rhs) { rhsBytes -> Bool in
                lhsBytes.elementsEqual(rhsBytes)
            }
        }
    }
}
