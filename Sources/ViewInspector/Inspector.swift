import SwiftUI

internal struct Inspector { }

extension Inspector {
    
    static func attribute(label: String, value: Any) throws -> Any {
        return try attribute(label: label, value: value, type: Any.self)
    }
    
    static func attribute<T>(label: String, value: Any, type: T.Type) throws -> T {
        let mirror = Mirror(reflecting: value)
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

// MARK: - Attributes lookup

extension Inspector {
    
    static func attributesTree(value: Any) -> [String: Any] {
        let mirror = Mirror(reflecting: value)
        var children: [Any] = mirror.children.map { child -> [String: Any] in
            let childName = child.label ?? ""
            return [childName: attributesTree(value: child.value)]
        }
        if let inspectable = value as? Inspectable {
            children.append(["body": attributesTree(value: inspectable.content)])
        }
        let description: Any = children.count > 0 ?
            children : String(describing: value)
        return [">>> " + typeName(value: value) + " <<<": description]
    }
}

// MARK: - View Inspection

extension Inspector {
    
    static func viewsInContainer(view: Any) throws -> LazyGroup<Content> {
        let unwrappedContainer = try Inspector.unwrap(content: Content(view))
        guard Inspector.isTupleView(unwrappedContainer.view) else {
            return LazyGroup(count: 1) { _ in unwrappedContainer }
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
    
    static func unwrap(view: Any, modifiers: [Any], injection: InjectionParameters? = nil)
        throws -> Content {
        return try unwrap(content: Content(view, modifiers: modifiers), injection: injection)
    }
    
    static func unwrap(content: Content, injection: InjectionParameters? = nil) throws -> Content {
        let injection = injection ?? .init()
        switch Inspector.typeName(value: content.view, prefixOnly: true) {
        case "Tree":
            return try ViewType.TreeView.child(content, injection: injection)
        case "IDView":
            return try ViewType.IDView.child(content, injection: injection)
        case "Optional":
            return try ViewType.OptionalContent.child(content, injection: injection)
        case "EquatableView":
            return try ViewType.EquatableView.child(content, injection: injection)
        case "ModifiedContent":
            return try ViewType.ModifiedContent.child(content, injection: injection)
        case "SubscriptionView":
            return try ViewType.SubscriptionView.child(content, injection: injection)
        case "_ConditionalContent":
            return try ViewType.ConditionalContent.child(content, injection: injection)
        case "EnvironmentReaderView":
            return try ViewType.EnvironmentReaderView.child(content, injection: injection)
        case "_DelayedPreferenceView":
            return try ViewType.DelayedPreferenceView.child(content, injection: injection)
        default:
            return content
        }
    }
    
    static func guardType(value: Any, prefix: String) throws {
        let name = typeName(type: type(of: value))
        guard name.hasPrefix(prefix) else {
            throw InspectionError.typeMismatch(factual: name, expected: prefix)
        }
    }
    
    static func guardNoEnvObjects(inspectableView: Inspectable) throws {
        let mirror = Mirror(reflecting: inspectableView)
        try mirror.children.forEach { attribute in
            let attributeType = Inspector.typeName(value: attribute.value, prefixOnly: true)
            if attributeType == "EnvironmentObject" {
                let viewType = Inspector.typeName(value: inspectableView)
                throw InspectionError.notSupported("""
                    \(viewType) references `EnvironmentObject`, but conforms to `Inspectable`
                    Please use `InspectableWithEnvObject` instead. More info in README:
                    https://github.com/nalexn/ViewInspector#custom-views-using-environmentobject
                    """)
            }
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
