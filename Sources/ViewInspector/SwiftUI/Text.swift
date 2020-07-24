import SwiftUI

public extension ViewType {
    
    struct Text: KnownViewType {
        public static let typePrefix: String = "Text"
    }
}

// MARK: - Extraction from SingleViewContent parent

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView where View: SingleViewContent {
    
    func text() throws -> InspectableView<ViewType.Text> {
        return try .init(try child())
    }
}

// MARK: - Extraction from MultipleViewContent parent

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView where View: MultipleViewContent {
    
    func text(_ index: Int) throws -> InspectableView<ViewType.Text> {
        return try .init(try child(at: index))
    }
}

// MARK: - Custom Attributes

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView where View == ViewType.Text {
    
    func string() throws -> String? {
        if let first = try? Inspector.attribute(path: "storage|anyTextStorage|first", value: content.view) as? Text,
            let second = try? Inspector.attribute(path: "storage|anyTextStorage|second", value: content.view) as? Text {
            let firstText = try first.inspect().text().string() ?? ""
            let secondText = try second.inspect().text().string() ?? ""
            return firstText + secondText
        }
        if let externalString = try? Inspector
            .attribute(path: "storage|verbatim", value: content.view) as? String {
            return externalString
        }
        let textStorage = try Inspector
            .attribute(path: "storage|anyTextStorage", value: content.view)
        let localizedStringKey = try Inspector
            .attribute(path: "key", value: textStorage)
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
