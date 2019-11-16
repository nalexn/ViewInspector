import SwiftUI

public extension ViewType {
    
    struct Text: KnownViewType {
        public static let typePrefix: String = "Text"
    }
}

public extension Text {
    
    func inspect() throws -> InspectableView<ViewType.Text> {
        return try InspectableView<ViewType.Text>(self)
    }
}

// MARK: - SingleViewContent

public extension InspectableView where View: SingleViewContent {
    
    func text() throws -> InspectableView<ViewType.Text> {
        let content = try View.content(view: view)
        return try InspectableView<ViewType.Text>(content)
    }
}

// MARK: - MultipleViewContent

public extension InspectableView where View: MultipleViewContent {
    
    func text(_ index: Int) throws -> InspectableView<ViewType.Text> {
        let content = try contentView(at: index)
        return try InspectableView<ViewType.Text>(content)
    }
}

// MARK: - Custom Attributes

public extension InspectableView where View == ViewType.Text {
    
    func string() throws -> String? {
        if let externalString = try? Inspector
            .attribute(path: "storage|verbatim", value: view) as? String {
            return externalString
        }
        let localizedStringKey = try Inspector
            .attribute(path: "storage|anyTextStorage|key", value: view)
        guard let baseString = try Inspector
            .attribute(label: "key", value: localizedStringKey) as? String,
            let hasFormatting = try Inspector
            .attribute(label: "hasFormatting", value: localizedStringKey) as? Bool
        else { return nil }
        guard hasFormatting else { return baseString }
        guard let arguments = try Inspector
            .attribute(label: "arguments", value: localizedStringKey) as? [Any]
        else { return nil }
        let values: [CVarArg] = try arguments.map {
            String(describing: try Inspector.attribute(label: "value", value: $0))
        }
        let argPatterns = ["%lld", "%ld", "%d", "%lf", "%f"]
        let format: String = argPatterns.reduce(baseString) { (format, pattern) in
            format.replacingOccurrences(of: pattern, with: "%@")
        }
        return String(format: format, arguments: values)
    }
}
