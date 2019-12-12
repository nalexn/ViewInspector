import SwiftUI

internal struct Inspector { }

extension Inspector {
    
    static func attribute(label: String, value: Any) throws -> Any {
        let mirror = Mirror(reflecting: value)
        guard let child = mirror.descendant(label) else {
            throw InspectionError.attributeNotFound(
                label: label, type: typeName(value: value))
        }
        return child
    }
    
    static func attribute(path: String, value: Any) throws -> Any {
        let labels = path.components(separatedBy: "|")
        return try labels.reduce(value, { (value, label) -> Any in
            try attribute(label: label, value: value)
        })
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
    
    static var stubEnvObject: Any { EnvironmentObjectNotSet() }
    
    static func viewsInContainer(view: Any) throws -> LazyGroup<Any> {
        let view = try Inspector.unwrap(view: view)
        guard Inspector.isTupleView(view) else {
            return LazyGroup(count: 1) { _ in view }
        }
        let tupleViews = try Inspector.attribute(label: "value", value: view)
        let childrenCount = Mirror(reflecting: tupleViews).children.count
        return LazyGroup(count: childrenCount) { index in
            let child = try Inspector.attribute(label: ".\(index)", value: tupleViews)
            return try Inspector.unwrap(view: child)
        }
    }
    
    static func unwrap(view: Any, envObject: Any = stubEnvObject) throws -> Any {
        
        switch Inspector.typeName(value: view, prefixOnly: true) {
        case "EnvironmentReaderView":
            return try ViewType.EnvironmentReaderView
                .content(view: view, envObject: envObject)
        case "_ConditionalContent":
            return try ViewType.ConditionalContent.content(view: view, envObject: envObject)
        #if !os(watchOS)
        case "ModifiedContent":
            return try ViewType.ModifiedContent.content(view: view, envObject: envObject)
        #endif
        case "Optional":
            return try ViewType.OptionalContent.content(view: view, envObject: envObject)
        case "SubscriptionView":
            return try ViewType.SubscriptionView.content(view: view, envObject: envObject)
        default:
            return view
        }
    }
    
    static func isTupleView(_ view: Any) -> Bool {
        return String(describing: type(of: view)).hasPrefix("TupleView")
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

extension Inspector {
    struct EnvironmentObjectNotSet { }
}
