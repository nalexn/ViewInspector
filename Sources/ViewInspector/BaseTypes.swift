import SwiftUI

// MARK: - Protocols

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
@available(*, deprecated, message: "Conformance to Inspectable is no longer required")
public protocol Inspectable { }

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public protocol SingleViewContent {
    static func child(_ content: Content) throws -> Content
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public protocol MultipleViewContent {
    static func children(_ content: Content) throws -> LazyGroup<Content>
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
internal typealias SupplementaryView = UnwrappedView

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
            return try InspectableView<ViewType.ClassifiedView>(content, parent: parent, call: "labelView()")
        }
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public protocol BaseViewType {
    static var typePrefix: String { get }
    static var namespacedPrefixes: [String] { get }
    static var isTransitive: Bool { get }
    static func inspectionCall(typeName: String) -> String
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension BaseViewType {
    static var namespacedPrefixes: [String] {
        guard !typePrefix.isEmpty else { return [] }
        return [.swiftUINamespaceRegex + typePrefix]
    }
    static var isTransitive: Bool { false }
    static func inspectionCall(typeName: String) -> String {
        let baseName = typePrefix.firstLetterLowercased
        return "\(baseName)(\(ViewType.indexPlaceholder))"
    }
}

internal extension String {
    var firstLetterLowercased: String {
        prefix(1).lowercased() + dropFirst()
    }
    
    static var swiftUINamespaceRegex: String { "SwiftUI(|[a-zA-Z0-9]{0,2}\\))\\." }
    
    func removingSwiftUINamespace() -> String {
        return removing(prefix: .swiftUINamespaceRegex)
            .removing(prefix: "SwiftUI.")
    }
    
    func removing(prefix: String) -> String {
        guard hasPrefix(prefix) else { return self }
        return String(suffix(count - prefix.count))
    }
    
    fileprivate func hasPrefix(regex: String, wholeMatch: Bool) -> Bool {
        let range = NSRange(location: 0, length: utf16.count)
        guard let ex = try? NSRegularExpression(pattern: regex),
              let match = ex.firstMatch(in: self, range: range)
        else { return false }
        if wholeMatch {
            return match.range == range
        }
        return match.range.lowerBound == 0
    }
}

internal extension Array where Element == String {
    func containsPrefixRegex(matching name: String, wholeMatch: Bool = true) -> Bool {
        return contains(where: { name.hasPrefix(regex: $0, wholeMatch: wholeMatch) })
    }
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
        let transitiveViewModifiers: [Any]
        let environmentModifiers: [EnvironmentModifier]
        let environmentObjects: [AnyObject]
        
        static var empty: Medium {
            return .init(viewModifiers: [],
                         transitiveViewModifiers: [],
                         environmentModifiers: [],
                         environmentObjects: [])
        }
        
        func appending(viewModifier: Any) -> Medium {
            return .init(viewModifiers: viewModifiers + [viewModifier],
                         transitiveViewModifiers: transitiveViewModifiers,
                         environmentModifiers: environmentModifiers,
                         environmentObjects: environmentObjects)
        }
        
        func appending(transitiveViewModifier: Any) -> Medium {
            return .init(viewModifiers: viewModifiers,
                         transitiveViewModifiers: transitiveViewModifiers + [transitiveViewModifier],
                         environmentModifiers: environmentModifiers,
                         environmentObjects: environmentObjects)
        }
        
        func appending(environmentModifier: EnvironmentModifier) -> Medium {
            return .init(viewModifiers: viewModifiers,
                         transitiveViewModifiers: transitiveViewModifiers,
                         environmentModifiers: environmentModifiers + [environmentModifier],
                         environmentObjects: environmentObjects)
        }
        
        func appending(environmentObject: AnyObject) -> Medium {
            return .init(viewModifiers: viewModifiers,
                         transitiveViewModifiers: transitiveViewModifiers,
                         environmentModifiers: environmentModifiers,
                         environmentObjects: environmentObjects + [environmentObject])
        }
        
        func resettingViewModifiers() -> Medium {
            return .init(viewModifiers: [],
                         transitiveViewModifiers: transitiveViewModifiers,
                         environmentModifiers: environmentModifiers,
                         environmentObjects: environmentObjects)
        }
        
        func removingCustomViewModifiers() -> Medium {
            let modifiers = viewModifiers
                .filter {
                    guard let modifier = $0 as? ModifierNameProvider else { return true }
                    return modifier.customModifier == nil
                }
            return .init(viewModifiers: modifiers,
                         transitiveViewModifiers: transitiveViewModifiers,
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
    case modifierNotFound(parent: String, modifier: String, index: Int)
    case missingEnvironmentObjects(view: String, objects: [String])
    case notSupported(String)
    case textAttribute(String)
    case searchFailure(skipped: Int, blockers: [String])
    case callbackNotFound(parent: String, callback: String)
    case unresponsiveControl(name: String, reason: String)
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
        case let .modifierNotFound(parent, modifier, index):
            return "\(parent) does not have '\(modifier)' modifier"
                + (index == 0 ? "" : " at index \(index)")
        case let .missingEnvironmentObjects(view, objects):
            return "\(view) is missing EnvironmentObjects: \(objects)"
        case let .notSupported(message), let .textAttribute(message):
            return message
        case let .searchFailure(skipped, blockers):
             let blockersDescription = blockers.count == 0 ? "" :
                 ". Possible blockers: \(blockers.joined(separator: ", "))"
             let conclusion = skipped == 0 ?
                 "Search did not find a match" : "Search did only find \(skipped) matches"
             return conclusion + blockersDescription
        case let .callbackNotFound(parent, callback):
            return "\(parent) does not have '\(callback)' callback"
        case let .unresponsiveControl(name, reason):
            return "\(name) is unresponsive: \(reason)"
        }
    }
    
    public var errorDescription: String? {
        return description
    }
}

// MARK: - ViewProvider

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
internal protocol SingleViewProvider {
    func view() throws -> Any
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
internal protocol MultipleViewProvider {
    func views() throws -> LazyGroup<Any>
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
internal protocol ElementViewProvider {
    func view(_ element: Any) throws -> Any
}

// MARK: - BinaryEquatable

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public protocol BinaryEquatable: Equatable { }

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension BinaryEquatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        withUnsafeBytes(of: lhs) { lhsBytes -> Bool in
            withUnsafeBytes(of: rhs) { rhsBytes -> Bool in
                lhsBytes.elementsEqual(rhsBytes)
            }
        }
    }
}

internal extension MemoryLayout {
    static func actualSize() -> String {
        fatalError("New size of \(String(describing: type(of: T.self))) is \(Self.size)")
    }
}
