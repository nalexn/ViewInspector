import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public struct Inspector {

    /// Removes the "(unknown context at <memory_address>)" portion of a type name.
    /// Calls to this method are memoized and retained for the lifetime of the program.
    /// - Parameter typeName: The raw type name. (e.g. `SomeTypeName.(unknown context at $138b3290c).SomePropertyName`)
    /// - Returns: The sanitized type name. (e.g. `SomeTypeName.SomePropertyName`)
    static func sanitizeNamespace(ofTypeName typeName: String) -> String {
        var str = typeName

        if let sanitized = sanitizedNamespacesCache[typeName] {
            return sanitized
        }

        let range = NSRange(location: 0, length: str.utf16.count)
        str = sanitizeNamespaceRegex.stringByReplacingMatches(in: str,
                                                              options: [],
                                                              range: range,
                                                              withTemplate: "")

        // For Objective-C classes String(reflecting:) sometimes adds the namespace __C, drop it too
        str = str.replacingOccurrences(of: "<__C.", with: "<")

        Inspector.sanitizedNamespacesCache[typeName] = str

        return str

    }

    /// Replaces the generic types of a given type name with a string.
    /// Calls to this method are memoized and retained for the lifetime of the program.
    /// - Parameters:
    ///   - typeName: The original type name. (e.g. `SomeTypeName<SomeGenericTypeParameter>`)
    ///   - replacement: The string to replace the generic parameters with. (e.g. "<EmptyView>")
    /// - Returns: The type name with its generic parameters replaced. (e.g. `SomeTypeName<EmptyView>`)
    static func replaceGenericParameters(inTypeName typeName: String,
                                         withReplacement replacement: String) -> String {
        // Check memoized value
        if let typeNameDict = Inspector.replacedGenericParametersCache[typeName],
           let cachedResult = typeNameDict[replacement] {
            return cachedResult
        }

        // Compute value
        let result = computeReplacementOfGenericParameters(inTypeName: typeName,
                                                           withReplacement: replacement)

        // Store memoized value
        var typeNameDict = Inspector.replacedGenericParametersCache[typeName] ?? [:]
        typeNameDict[replacement] = result
        Inspector.replacedGenericParametersCache[typeName] = typeNameDict

        return result
    }

    private static func computeReplacementOfGenericParameters(inTypeName typeName: String,
                                                              withReplacement replacement: String) -> String {
        guard let start = typeName.firstIndex(of: "<") else {
            return typeName
        }

        var balance = 1
        var current = typeName.index(after: start)
        while balance > 0 && current < typeName.endIndex {
            let char = typeName[current]
            if char == "<" { balance += 1 }
            if char == ">" {
                guard let indexOfPreviousChar = typeName.index(current,
                                                               offsetBy: -1,
                                                               limitedBy: typeName.startIndex) else {
                    return typeName
                }
                let previousChar = typeName[indexOfPreviousChar]
                if previousChar == "-" {
                    // We've found the "->" arrow for a closure type. Ignore this ">".
                } else {
                    balance -= 1
                }
            }
            current = typeName.index(after: current)
        }

        if balance == 0 {
            return String(typeName[..<start]) +
            replacement +
            replaceGenericParameters(inTypeName: String(typeName[current...]),
                                     withReplacement: replacement)
        }

        return typeName
    }

    private static var replacedGenericParametersCache: [String: [String: String]] = [:]
    private static var sanitizedNamespacesCache: [String: String] = [:]

    private static let sanitizeNamespacePatterns = [
        "(\\.\\(unknown context at ..........\\))",
        // This pattern may be helpful to solve issue #268.
        // It will remain disabled until it is confirmed.
        // https://github.com/nalexn/ViewInspector/issues/268
        // "(\\(extension in [a-zA-Z0-9]*\\)\\:)",
    ]

    private static let sanitizeNamespaceRegex = {
        // swiftlint:disable force_try
        try! NSRegularExpression(pattern: sanitizeNamespacePatterns.joined(separator: "|"))
        // swiftlint:enable force_try
    }()
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
internal extension Inspector {

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
        return try cast(value: child, type: T.self)
    }

    static func attribute(path: String, value: Any) throws -> Any {
        return try attribute(path: path, value: value, type: Any.self)
    }

    static func attribute<T>(path: String, value: Any, type: T.Type) throws -> T {
        let labels = path.components(separatedBy: "|")
        let child = try labels.reduce(value, { (value, label) -> Any in
            try attribute(label: label, value: value)
        })
        return try cast(value: child, type: T.self)
    }

    static func cast<T>(value: Any, type: T.Type) throws -> T {
        guard let casted = value as? T else {
            throw InspectionError.typeMismatch(value, T.self)
        }
        return casted
    }

    static func unsafeMemoryRebind<V, T>(value: V, type: T.Type) throws -> T {
        guard MemoryLayout<V>.size == MemoryLayout<T>.size else {
            throw InspectionError.notSupported(
                """
                Unable to rebind value of type \(Inspector.typeName(value: value, namespaced: true)) \
                to \(Inspector.typeName(type: type, namespaced: true)). \
                This is an internal library error, please open a ticket with these details.
                """)
        }
        return withUnsafeBytes(of: value) { bytes in
            return bytes.baseAddress!
                .assumingMemoryBound(to: T.self).pointee
        }
    }

    enum GenericParameters {
        case keep
        case remove
        case customViewPlaceholder
    }

    static func typeName(value: Any,
                         namespaced: Bool = false,
                         generics: GenericParameters = .keep) -> String {
        if value is Any.Type {
            // Accessing Type reference causes EXC_BAD_ACCESS
            return "Any.Type"
        }
        return typeName(type: type(of: value), namespaced: namespaced,
                        generics: generics)
    }

    static func isSystemType(value: Any) -> Bool {
        let name = typeName(value: value, namespaced: true)
        return isSystemType(name: name)
    }

    static func isSystemType(type: Any.Type) -> Bool {
        let name = typeName(type: type, namespaced: true)
        return isSystemType(name: name)
    }

    private static func isSystemType(name: String) -> Bool {
        return [
            String.swiftUINamespaceRegex, "Swift\\.",
            "_CoreLocationUI_SwiftUI\\.", "_MapKit_SwiftUI\\.",
            "_AuthenticationServices_SwiftUI\\.", "_AVKit_SwiftUI\\.",
        ].containsPrefixRegex(matching: name, wholeMatch: false)
    }

    static func typeName(type: Any.Type,
                         namespaced: Bool = false,
                         generics: GenericParameters = .keep) -> String {
        let typeName = namespaced ? sanitizeNamespace(ofTypeName: String(reflecting: type)) : String(describing: type)
        switch generics {
        case .keep:
            return typeName
        case .remove:
            return replaceGenericParameters(inTypeName: typeName,
                                            withReplacement: "")
        case .customViewPlaceholder:
            let parameters = ViewType.customViewGenericsPlaceholder
            return replaceGenericParameters(inTypeName: typeName,
                                            withReplacement: parameters)
        }
    }
}

// MARK: - Attributes lookup

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension Inspector {

    /**
     Use this function to lookup the struct content:
     ```
     (lldb) po Inspector.print(view) as AnyObject
     ```
     */
    static func print(_ value: Any) -> String {
        let tree = attributesTree(value: value, medium: .empty, visited: [])
        return typeName(value: value) + print(tree, level: 1)
    }

    fileprivate static func print(_ value: Any, level: Int) -> String {
        let prefix = Inspector.newline(value: value)
        if let array = value as? [Any] {
            return prefix + array.description(level: level)
        } else if let dict = value as? [String: Any] {
            return prefix + dict.description(level: level)
        }
        return prefix + String(describing: value) + "\n"
    }

    fileprivate static func indent(level: Int) -> String {
        return Array(repeating: "  ", count: level).joined()
    }

    private static func newline(value: Any) -> String {
        let needsNewLine: Bool = {
            if let array = value as? [Any] {
                return array.count > 0
            }
            return value is [String: Any]
        }()
        return needsNewLine ? "\n" : ""
    }

    private static func attributesTree(value: Any, medium: Content.Medium, visited: [AnyObject]) -> Any {
        var visited = visited
        if type(of: value) is AnyClass {
            let ref = value as AnyObject
            guard !visited.contains(where: { $0 === ref })
            else { return " = { cyclic reference }" }
            visited.append(ref)
        }
        if let array = value as? [Any] {
            return array.map { attributesTree(value: $0, medium: medium, visited: visited) }
        }
        let medium = (try? unwrap(content: Content(value, medium: medium)).medium) ?? medium
        var mirror = Mirror(reflecting: value)
        var children = Array(mirror.children)
        while let superclass = mirror.superclassMirror {
            mirror = superclass
            children.append(contentsOf: superclass.children)
        }
        var dict: [String: Any] = [:]
        children.enumerated().forEach { child in
            let childName = child.element.label ?? "[\(child.offset)]"
            let childType = typeName(value: child.element.value)
            dict[childName + ": " + childType] = attributesTree(
                value: child.element.value, medium: medium, visited: visited)
        }
        if let contentExtractor = try? ContentExtractor(source: value),
           let content = try? contentExtractor.extractContent(environmentObjects: medium.environmentObjects) {
            let childType = typeName(value: content)
            dict["body: " + childType] = attributesTree(value: content, medium: medium, visited: visited)
        }
        if dict.count == 0 {
            if value is Any.Type {
                return ""
            }
            return " = " + String(describing: value)
        }
        return dict
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
fileprivate extension Dictionary where Key == String {
    func description(level: Int) -> String {
        let indent = Inspector.indent(level: level)
        return sorted(by: { $0.key < $1.key }).reduce("") { (str, pair) -> String in
            return str + indent + pair.key + Inspector.print(pair.value, level: level + 1)
        }
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
fileprivate extension Array {
    func description(level: Int) -> String {
        guard count > 0 else {
            return " = []\n"
        }
        let indent = Inspector.indent(level: level)
        return enumerated().reduce("") { (str, pair) -> String in
            return str + indent + "[\(pair.offset)]" + Inspector.print(pair.element, level: level + 1)
        }
    }
}
// MARK: - View Inspection

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
internal extension Inspector {

    static func viewsInContainer(view: Any, medium: Content.Medium) throws -> LazyGroup<Content> {
        let unwrappedContainer = try Inspector.unwrap(content: Content(view, medium: medium.resettingViewModifiers()))
        guard Inspector.isTupleView(unwrappedContainer.view) else {
            return LazyGroup(count: 1) { _ in unwrappedContainer }
        }
        return try ViewType.TupleView.children(unwrappedContainer)
    }

    static func isTupleView(_ view: Any) -> Bool {
        return Inspector.typeName(value: view, generics: .remove) == ViewType.TupleView.typePrefix
    }

    static func unwrap(view: Any, medium: Content.Medium) throws -> Content {
        return try unwrap(content: Content(view, medium: medium))
    }

    // swiftlint:disable cyclomatic_complexity
    static func unwrap(content: Content) throws -> Content {
        switch Inspector.typeName(value: content.view, generics: .remove) {
        case "Tree":
            return try ViewType.TreeView.child(content)
        case "IDView":
            return try ViewType.IDView.child(content)
        case "Optional":
            return try ViewType.OptionalContent.child(content)
        case "EquatableView":
            return try ViewType.EquatableView.child(content)
        case "HelpView":
            return try ViewType.HelpView.child(content)
        case "ModifiedContent":
            return try ViewType.ViewModifier<ViewType.Stub>.child(content)
        case "SubscriptionView":
            return try ViewType.SubscriptionView.child(content)
        case "_UnaryViewAdaptor":
            return try ViewType.UnaryViewAdaptor.child(content)
        case "_ConditionalContent":
            return try ViewType.ConditionalContent.child(content)
        case "EnvironmentReaderView":
            return try ViewType.EnvironmentReaderView.child(content)
        case "_DelayedPreferenceView":
            return try ViewType.DelayedPreferenceView.child(content)
        case "_PreferenceReadingView":
            return try ViewType.PreferenceReadingView.child(content)
        case "PopoverContent":
            return try ViewType.PopoverContent.child(content)
        case "WrappedContent":
            return try ViewType.WrappedContent.child(content)
        default:
            return content
        }
    }
    // swiftlint:enable cyclomatic_complexity

    static func guardType(value: Any, namespacedPrefixes: [String], inspectionCall: String) throws {

        var typePrefix = typeName(type: type(of: value), namespaced: true, generics: .remove)
        if typePrefix == ViewType.popupContainerTypePrefix {
            typePrefix = typeName(type: type(of: value), namespaced: true)
        }
        if typePrefix == "SwiftUI.EnvironmentReaderView" {
            let typeWithParams = typeName(type: type(of: value))
            if typeWithParams.contains("NavigationBarItemsKey") {
                throw InspectionError.notSupported(
                    """
                    Please insert '.navigationBarItems()' before \(inspectionCall) \
                    for unwrapping the underlying view hierarchy.
                    """)
            }
        }
        if namespacedPrefixes.containsPrefixRegex(matching: typePrefix) {
            return
        }
        if var prefix = namespacedPrefixes.first {
            prefix = prefix.replacingOccurrences(of: String.swiftUINamespaceRegex, with: "SwiftUI.")
            let typePrefix = typeName(type: type(of: value), namespaced: true)
            throw InspectionError.typeMismatch(factual: typePrefix, expected: prefix)
        }
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension InspectionError {
    static func typeMismatch<V, T>(_ value: V, _ expectedType: T.Type) -> InspectionError {
        var factual = Inspector.typeName(value: value)
        var expected = Inspector.typeName(type: expectedType)
        if factual == expected {
            factual = Inspector.typeName(value: value, namespaced: true)
            expected = Inspector.typeName(type: expectedType, namespaced: true)
        }
        return .typeMismatch(factual: factual, expected: expected)
    }
}
