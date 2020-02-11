import SwiftUI

internal struct Inspector { }

extension Inspector {
    
    static func attribute(label: String, value: Any) throws -> Any {
        if label == "super", let superclass = Mirror(reflecting: value).superclassMirror {
            return superclass
        }
        return try attribute(label: label, value: value, type: Any.self)
    }
    
    static func attribute<T>(label: String, value: Any, type: T.Type) throws -> T {
        let mirror = (value as? Mirror) ?? Mirror(reflecting: value)
        guard let child = mirror.descendant(label) else {
            throw InspectionError.attributeNotFound(
                label: label, type: typeName(value: value))
        }
        guard let casted = child as? T else {
            throw InspectionError.typeMismatch(child, T.self)
        }
        return casted
    }
    
    static func attribute(path: String, value: Any) throws -> Any {
        return try attribute(path: path, value: value, type: Any.self)
    }
    
    static func attribute<T>(path: String, value: Any, type: T.Type) throws -> T {
        let labels = path.components(separatedBy: "|")
        let child = try labels.reduce(value, { (value, label) -> Any in
            try attribute(label: label, value: value)
        })
        guard let casted = child as? T else {
            throw InspectionError.typeMismatch(child, T.self)
        }
        return casted
    }
    
    static func typeName(value: Any, prefixOnly: Bool = false) -> String {
        return typeName(type: type(of: value), prefixOnly: prefixOnly)
    }
    
    static func typeName(type: Any.Type, prefixOnly: Bool = false) -> String {
        let typeName = String(describing: type)
        guard prefixOnly else { return typeName }
        return typeName.components(separatedBy: "<").first!
    }
}

// MARK: - View Inspection

extension Inspector {
    
    static func viewsInContainer(view: Any) throws -> LazyGroup<Content> {
        let unwrappedContainer = try Inspector.unwrap(content: Content(view))
        guard Inspector.isTupleView(unwrappedContainer.view) else {
            return LazyGroup(count: 1) { index in
                guard index == 0 else {
                    throw InspectionError.viewIndexOutOfBounds(index: index, count: 1)
                }
                return unwrappedContainer
            }
        }
        let tupleViews = try Inspector.attribute(label: "value", value: unwrappedContainer.view)
        let childrenCount = Mirror(reflecting: tupleViews).children.count
        return LazyGroup(count: childrenCount) { index in
            let child = try Inspector.attribute(label: ".\(index)", value: tupleViews)
            return try Inspector.unwrap(content: Content(child))
        }
    }
    
    static func isTupleView(_ view: Any) -> Bool {
        return Inspector.typeName(value: view, prefixOnly: true) == "TupleView"
    }
    
    static func unwrap(view: Any, modifiers: [Any]) throws -> Content {
        return try unwrap(content: Content(view, modifiers: modifiers))
    }
    
    static func unwrap(content: Content) throws -> Content {
        switch Inspector.typeName(value: content.view, prefixOnly: true) {
        case "Tree":
            return try ViewType.TreeView.child(content)
        case "IDView":
            return try ViewType.IDView.child(content)
        case "Optional":
            return try ViewType.OptionalContent.child(content)
        case "EquatableView":
            return try ViewType.EquatableView.child(content)
        case "ModifiedContent":
            return try ViewType.ModifiedContent.child(content)
        case "SubscriptionView":
            return try ViewType.SubscriptionView.child(content)
        case "_ConditionalContent":
            return try ViewType.ConditionalContent.child(content)
        case "EnvironmentReaderView":
            return try ViewType.EnvironmentReaderView.child(content)
        case "_DelayedPreferenceView":
            return try ViewType.DelayedPreferenceView.child(content)
        default:
            return content
        }
    }
    
    static func guardType(value: Any, prefix: String) throws {
        let name = typeName(type: type(of: value))
        if name.hasPrefix("EnvironmentReaderView") {
            throw InspectionError.notSupported(
                "Please use 'navigationBarItems()' for unwrapping the underlying view hierarchy.")
        }
        guard name.hasPrefix(prefix) else {
            throw InspectionError.typeMismatch(factual: name, expected: prefix)
        }
    }
}

extension InspectionError {
    static func typeMismatch<V, T>(_ value: V, _ expectedType: T.Type) -> InspectionError {
        return .typeMismatch(
            factual: Inspector.typeName(value: value),
            expected: Inspector.typeName(type: expectedType))
    }
}
