import SwiftUI

// MARK: - Protocols

public protocol Inspectable {
    var content: Any { get }
}

public extension Inspectable where Self: View {
    var content: Any { body }
}

public protocol InspectableWithOneParam: SingleParameterInjection {
    associatedtype InspectableBody
    associatedtype Parameter
    func body(_ parameter: Parameter) -> InspectableBody
}

public protocol InspectableWithTwoParam: DualParameterInjection {
    associatedtype InspectableBody
    associatedtype Parameter1
    associatedtype Parameter2
    func body(_ parameter1: Parameter1, _ parameter2: Parameter2) -> InspectableBody
}

public protocol InspectableWithThreeParam: TripleParameterInjection {
    associatedtype InspectableBody
    associatedtype Parameter1
    associatedtype Parameter2
    associatedtype Parameter3
    func body(_ parameter1: Parameter1, _ parameter2: Parameter2,
              _ parameter3: Parameter3) -> InspectableBody
}

public protocol SingleParameterInjection {
    func inject(_ parameter: Any) throws -> Any
}

public protocol DualParameterInjection {
    func inject(_ parameter1: Any, _ parameter2: Any) throws -> Any
}

public protocol TripleParameterInjection {
    func inject(_ parameter1: Any, _ parameter2: Any, _ parameter3: Any) throws -> Any
}

public protocol SingleViewContent {
    static func child(_ content: Content, injection: Any) throws -> Content
}

public protocol MultipleViewContent {
    static func children(_ content: Content, injection: Any) throws -> LazyGroup<Content>
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

internal protocol BinaryEquatable: Equatable { }

extension BinaryEquatable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        withUnsafeBytes(of: lhs) { lhsBytes -> Bool in
            withUnsafeBytes(of: rhs) { rhsBytes -> Bool in
                lhsBytes.elementsEqual(rhsBytes)
            }
        }
    }
}

// MARK: - Deprecated

@available(*, deprecated, renamed: "InspectableWithOneParam")
public typealias InspectableWithEnvObject = InspectableWithOneParam

@available(*, deprecated, renamed: "InspectableWithTwoParam")
public typealias InspectableWithEnvObject2 = InspectableWithTwoParam

@available(*, deprecated, renamed: "InspectableWithThreeParam")
public typealias InspectableWithEnvObject3 = InspectableWithThreeParam
