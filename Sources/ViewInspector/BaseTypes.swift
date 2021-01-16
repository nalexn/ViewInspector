import SwiftUI

// MARK: - Protocols

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public protocol Inspectable {
    func extractContent() throws -> Any
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension Inspectable where Self: View {
    func extractContent() throws -> Any { body }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension Inspectable where Self: ViewModifier {
    func extractContent() throws -> Any {
        body(content: _ViewModifier_Content<Self>())
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public protocol SingleViewContent {
    static func child(_ content: Content) throws -> Content
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public protocol MultipleViewContent {
    static func children(_ content: Content) throws -> LazyGroup<Content>
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
internal typealias SupplementaryView = InspectableView<ViewType.ClassifiedView>

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
internal protocol SupplementaryChildren {
    static func supplementaryChildren(_ parent: UnwrappedView) throws -> LazyGroup<SupplementaryView>
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
internal protocol SupplementaryChildrenLabelView: SupplementaryChildren {
    static var labelViewPath: String { get }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension SupplementaryChildrenLabelView {
    static var labelViewPath: String { "label" }
    static func supplementaryChildren(_ parent: UnwrappedView) throws -> LazyGroup<SupplementaryView> {
        return .init(count: 1) { _ in
            let child = try Inspector.attribute(path: labelViewPath, value: parent.content.view)
            let content = try Inspector.unwrap(content: Content(child))
            return try .init(content, parent: parent, call: "labelView()")
        }
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public protocol KnownViewType {
    static var typePrefix: String { get }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public protocol CustomViewType {
    associatedtype T: Inspectable
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public struct ViewType { }

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public struct Content {
    let view: Any
    let modifiers: [Any]
    
    internal init(_ view: Any, modifiers: [Any] = []) {
        self.view = view
        self.modifiers = modifiers
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension Binding {
    init(wrappedValue: Value) {
        var value = wrappedValue
        self.init(get: { value }, set: { value = $0 })
    }
}

// MARK: - Error

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public enum InspectionError: Swift.Error {
    case inspection(path: String, factual: String, expected: String)
    case typeMismatch(factual: String, expected: String)
    case attributeNotFound(label: String, type: String)
    case viewIndexOutOfBounds(index: Int, count: Int)
    case viewNotFound(parent: String)
    case parentViewNotFound(view: String)
    case modifierNotFound(parent: String, modifier: String)
    case notSupported(String)
    case textAttribute(String)
    case searchFailure(blockers: [String])
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension InspectionError: CustomStringConvertible, LocalizedError {
    
    public var description: String {
        switch self {
        case let .inspection(path, factual, expected):
            return "\(path) found \(factual) instead of \(expected)"
        case let .typeMismatch(factual, expected):
            return "Type mismatch: \(factual) is not \(expected)"
        case let .attributeNotFound(label, type):
            return "\(type) does not have '\(label)' attribute"
        case let .viewIndexOutOfBounds(index, count):
            return "Enclosed view index '\(index)' is out of bounds: '0 ..< \(count)'"
        case let .viewNotFound(parent):
            return "View for \(parent) is absent"
        case let .parentViewNotFound(view):
            return "\(view) does not have parent"
        case let .modifierNotFound(parent, modifier):
            return "\(parent) does not have '\(modifier)' modifier"
        case let .notSupported(message), let .textAttribute(message):
            return message
        case let .searchFailure(blockers):
            let suffix = blockers.count == 0 ? "" :
                ". Possible blockers: \(blockers.joined(separator: ", "))"
            return "Search did not find a match" + suffix
        }
    }
    
    public var errorDescription: String? {
        return description
    }
}

// MARK: - LazyGroup

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public struct LazyGroup<T> {
    
    private let access: (Int) throws -> T
    let count: Int
    
    init(count: Int, _ access: @escaping (Int) throws -> T) {
        self.count = count
        self.access = access
    }
    
    func element(at index: Int) throws -> T {
        guard 0 ..< count ~= index else {
            throw InspectionError.viewIndexOutOfBounds(index: index, count: count)
        }
        return try access(index)
    }
    
    static var empty: Self {
        return .init(count: 0) { _ in fatalError() }
    }
    
    static func + (lhs: LazyGroup, rhs: LazyGroup) -> LazyGroup {
        return .init(count: lhs.count + rhs.count) { index -> T in
            if index < lhs.count {
                return try lhs.element(at: index)
            } else {
                return try rhs.element(at: index - lhs.count)
            }
        }
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension LazyGroup: Sequence {
    
    public struct Iterator: IteratorProtocol {
        public typealias Element = T
        internal var index = -1
        private var group: LazyGroup<Element>
        
        init(group: LazyGroup<Element>) {
            self.group = group
        }
        
        mutating public func next() -> Element? {
            index += 1
            do {
                return try group.element(at: index)
            } catch _ {
                return nil
            }
        }
    }

    public func makeIterator() -> Iterator {
        .init(group: self)
    }

    public var underestimatedCount: Int { count }
}

// MARK: - BinaryEquatable

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
internal protocol BinaryEquatable: Equatable { }

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension BinaryEquatable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        withUnsafeBytes(of: lhs) { lhsBytes -> Bool in
            withUnsafeBytes(of: rhs) { rhsBytes -> Bool in
                lhsBytes.elementsEqual(rhsBytes)
            }
        }
    }
}

// MARK: - ViewModifier content allocation

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
internal extension _ViewModifier_Content {
    private struct Allocator { }
    init() {
        self = unsafeBitCast(Allocator(), to: Self.self)
    }
}
