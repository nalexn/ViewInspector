import SwiftUI

internal struct Inspector { }

extension Inspector {
    static func attribute(label: String, value: Any) throws -> Any {
        let mirror = Mirror(reflecting: value)
        let children = mirror.children
        guard let child = children.first(where: { $0.label == label })?.value else {
            throw InspectionError.childAttributeNotFound(
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
        return (typeName.components(separatedBy: "<").first ?? typeName)
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
