import SwiftUI

// MARK: - Protocols

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public protocol Inspectable {
    func extractContent(environmentObjects: [AnyObject]) throws -> Any
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension Inspectable where Self: View {
    func extractContent(environmentObjects: [AnyObject]) throws -> Any {
        var copy = self
        environmentObjects.forEach { copy.inject(environmentObject: $0) }
        return copy.body
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension Inspectable where Self: ViewModifier {
    func extractContent(environmentObjects: [AnyObject]) throws -> Any {
        var copy = self
        environmentObjects.forEach { copy.inject(environmentObject: $0) }
        return copy.body(content: _ViewModifier_Content<Self>())
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
            let medium = parent.content.medium.resettingViewModifiers()
            let content = try Inspector.unwrap(content: Content(child, medium: medium))
            return try .init(content, parent: parent, call: "labelView()")
        }
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public protocol KnownViewType {
    static var typePrefix: String { get }
    static var namespacedPrefixes: [String] { get }
    static func inspectionCall(typeName: String) -> String
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension KnownViewType {
    static var namespacedPrefixes: [String] {
        guard !typePrefix.isEmpty else { return [] }
        return ["SwiftUI." + typePrefix]
    }
    static func inspectionCall(typeName: String) -> String {
        let baseName = typePrefix.prefix(1).lowercased() + typePrefix.dropFirst()
        return "\(baseName)(\(ViewType.indexPlaceholder))"
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public protocol CustomViewType {
    associatedtype T: Inspectable
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public struct ViewType { }

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
internal extension ViewType {
    static let indexPlaceholder = "###"
    static let commaPlaceholder = "~~~"
    
    static func inspectionCall(base: String, index: Int?) -> String {
        if let index = index {
            return base
                .replacingOccurrences(of: commaPlaceholder, with: ", ")
                .replacingOccurrences(of: indexPlaceholder, with: "\(index)")
        } else {
            return base
                .replacingOccurrences(of: commaPlaceholder, with: "")
                .replacingOccurrences(of: indexPlaceholder, with: "")
        }
    }
}

// MARK: - Content

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public struct Content {
    let view: Any
    let medium: Medium
    
    internal init(_ view: Any, medium: Medium = .empty) {
        self.view = view
        self.medium = medium
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
internal extension Content {
    struct Medium {
        let viewModifiers: [Any]
        let environmentModifiers: [EnvironmentModifier]
        let environmentObjects: [AnyObject]
        
        static var empty: Medium {
            return .init(viewModifiers: [],
                         environmentModifiers: [],
                         environmentObjects: [])
        }
        
        func appending(viewModifier: Any) -> Medium {
            return .init(viewModifiers: viewModifiers + [viewModifier],
                         environmentModifiers: environmentModifiers,
                         environmentObjects: environmentObjects)
        }
        
        func appending(environmentModifier: EnvironmentModifier) -> Medium {
            return .init(viewModifiers: viewModifiers,
                         environmentModifiers: environmentModifiers + [environmentModifier],
                         environmentObjects: environmentObjects)
        }
        
        func appending(environmentObject: AnyObject) -> Medium {
            return .init(viewModifiers: viewModifiers,
                         environmentModifiers: environmentModifiers,
                         environmentObjects: environmentObjects + [environmentObject])
        }
        
        func resettingViewModifiers() -> Medium {
            return .init(viewModifiers: [],
                         environmentModifiers: environmentModifiers,
                         environmentObjects: environmentObjects)
        }
    }
}

// MARK: - Binding helper

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

// MARK: - EnvironmentObject injection

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension Inspectable {
    mutating func inject(environmentObject: AnyObject) {
        let type = "SwiftUI.EnvironmentObject<\(Inspector.typeName(value: environmentObject, namespaced: true))>"
        let mirror = Mirror(reflecting: self)
        guard let label = mirror.children
                .first(where: {
                    Inspector.typeName(value: $0.value, namespaced: true) == type
                })?.label
        else { return }
        let envObjSize = EnvObject.structSize
        let viewSize = MemoryLayout<Self>.size
        var offset = MemoryLayout<Self>.stride - envObjSize
        let step = MemoryLayout<Self>.alignment
        while offset + envObjSize > viewSize {
            offset -= step
        }
        withUnsafeBytes(of: EnvObject.Forgery(object: nil)) { reference in
            while offset >= 0 {
                var copy = self
                withUnsafeMutableBytes(of: &copy) { bytes in
                    guard bytes[offset..<offset + envObjSize].elementsEqual(reference)
                    else { return }
                    let rawPointer = bytes.baseAddress! + offset + EnvObject.seedOffset
                    let pointerToValue = rawPointer.assumingMemoryBound(to: Int.self)
                    pointerToValue.pointee = -1
                }
                if let seed = try? Inspector.attribute(path: label + "|_seed", value: copy, type: Int.self),
                   seed == -1 {
                    withUnsafeMutableBytes(of: &copy) { bytes in
                        let rawPointer = bytes.baseAddress! + offset
                        let pointerToValue = rawPointer.assumingMemoryBound(to: EnvObject.Forgery.self)
                        pointerToValue.pointee = .init(object: environmentObject)
                    }
                    self = copy
                    return
                }
                offset -= step
            }
        }
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
internal struct EnvObject {
    static var seedOffset: Int { 8 }
    static var structSize: Int { 16 }
    
    struct Forgery {
        let object: AnyObject?
        let seed: Int = 0
    }
}
