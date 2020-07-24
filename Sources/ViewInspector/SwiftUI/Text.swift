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
        if let externalString = try? Inspector
            .attribute(path: "storage|verbatim", value: content.view) as? String {
            return externalString
        }
        let textStorage = try Inspector
            .attribute(path: "storage|anyTextStorage", value: content.view)
        if let first = try? Inspector.attribute(path: "first", value: textStorage) as? Text,
            let second = try? Inspector.attribute(path: "second", value: textStorage) as? Text {
            let firstText = try first.inspect().text().string() ?? ""
            let secondText = try second.inspect().text().string() ?? ""
            return firstText + secondText
        }
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

    func fontWeight() throws -> [Font.Weight?] {
        if let textStorage = try? Inspector.attribute(path: "storage|anyTextStorage", value: content.view),
            let first = try? Inspector.attribute(path: "first", value: textStorage) as? Text,
            let second = try? Inspector.attribute(path: "second", value: textStorage) as? Text {
            let firstWeight = (try? first.inspect().text().fontWeight()) ?? [nil]
            let secondWeight = (try? second.inspect().text().fontWeight()) ?? [nil]
            return firstWeight + secondWeight
        } else {
            guard let viewModifiers = try? Inspector.attribute(path: "modifiers", value: content.view) as? Array<Any>
            else { return [nil] }
            for viewModifier in viewModifiers {
                if let weight = try? Inspector
                    .attribute(path: "weight", value: viewModifier) as? Font.Weight {
                    return [weight]
                }
            }
            return [nil]
        }
    }
}
