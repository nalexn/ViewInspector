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
    
    static func typeName(value: Any) -> String {
        return typeName(type: type(of: value))
    }
    
    static func typeName(type: Any.Type) -> String {
        let typeName = String(describing: type)
        return typeName.components(separatedBy: "<").first!
    }
    
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
    
    static func viewsInContainer(view: Any) throws -> [Any] {
        guard Inspector.isTupleView(view)
            else { return [view] }
        let tupleViews = try Inspector.attribute(label: "value", value: view)
        let childrenCount = Mirror(reflecting: tupleViews).children.count
        return try stride(from: 0, to: childrenCount, by: 1).map { index in
            return try Inspector.attribute(label: ".\(index)", value: tupleViews)
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
}

extension InspectionError {
    static func typeMismatch<V, T>(_ value: V, _ expectedType: T.Type) -> InspectionError {
        return .typeMismatch(
            factual: Inspector.typeName(value: value),
            expected: Inspector.typeName(type: expectedType))
    }
}
