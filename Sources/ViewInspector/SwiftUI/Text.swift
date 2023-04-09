import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension Locale {
    /**
     A global value used as a default parameter for `Text` string inspection
     and `find` functions. You can set to other value before the tests run:
     ````
     override class func setUp() {
        Locale.testsDefault = .current
     }
     ````
     */
    static var testsDefault: Locale = Locale(identifier: "en")
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension ViewType {
    
    struct Text: KnownViewType {
        public static let typePrefix: String = "Text"
    }
}

// MARK: - Extraction from SingleViewContent parent

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView where View: SingleViewContent {
    
    func text() throws -> InspectableView<ViewType.Text> {
        return try .init(try child(), parent: self)
    }
}

// MARK: - Extraction from MultipleViewContent parent

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView where View: MultipleViewContent {
    
    func text(_ index: Int) throws -> InspectableView<ViewType.Text> {
        return try .init(try child(at: index), parent: self, index: index)
    }
}

// MARK: - Custom Attributes

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView where View == ViewType.Text {
    
    /**
     Extracts the formatted and localized string value from the Text view

      - Parameter locale: Defaults to `Locale(identifier: "en")`,
      which is a global default value in the tests scope.
      You can change it by assigning a value to Locale.testsDefault
    */
    func string(locale: Locale = .testsDefault) throws -> String {
        return try ViewType.Text.extractString(from: self, locale: locale)
    }
    
    func attributes() throws -> ViewType.Text.Attributes {
        return try ViewType.Text.Attributes.extract(from: self)
    }
    
    func images() throws -> [Image] {
        return try ViewType.Text.extractImages(from: self)
    }

    /**
     Returns `AttributedString` only for `Text` views constructed this way.
     If you used explicit style modifiers, for example, `Text("Hi").bold()`,
     consider using `attributes()` instead.
     */
    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
    func attributedString() throws -> AttributedString {
        return try ViewType.Text.extractAttributedString(from: self)
    }
}

// MARK: - String extraction

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
private extension ViewType.Text {
    
    static func extractString(from view: InspectableView<ViewType.Text>,
                              locale: Locale) throws -> String {
        let storage = try Inspector.attribute(label: "storage", value: view.content.view)
        if let verbatim = try? Inspector
            .attribute(label: "verbatim", value: storage, type: String.self) {
            return verbatim
        }
        let textStorage = try Inspector.attribute(path: "anyTextStorage", value: storage)
        let storageType = Inspector.typeName(value: textStorage)
        switch storageType {
        case "ConcatenatedTextStorage":
            return try extractString(concatenatedTextStorage: textStorage, locale)
        case "LocalizedTextStorage":
            return try extractString(localizedTextStorage: textStorage, locale)
        case "AttachmentTextStorage":
            return try extractString(attachmentTextStorage: textStorage)
        case "DateTextStorage":
            return try extractString(dateTextStorage: textStorage)
        case "FormatterTextStorage":
            return try extractString(formatterTextStorage: textStorage)
        case "AttributedStringTextStorage":
            guard #available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *) else {
                throw InspectionError.notSupported("AttributedString is not supported in this OS version")
            }
            return String(try view.attributedString().characters)
        default:
            throw InspectionError.notSupported("Unknown text storage: \(storageType)")
        }
    }
    
    // MARK: - ConcatenatedTextStorage
    
    private static func extractTexts(concatenatedTextStorage: Any) throws -> (Text, Text) {
        let firstText = try Inspector
            .attribute(label: "first", value: concatenatedTextStorage, type: Text.self)
        let secondText = try Inspector
            .attribute(label: "second", value: concatenatedTextStorage, type: Text.self)
        return (firstText, secondText)
    }
    
    private static func extractString(concatenatedTextStorage: Any, _ locale: Locale) throws -> String {
        let (firstText, secondText) = try extractTexts(concatenatedTextStorage: concatenatedTextStorage)
        return (try firstText.inspect().text().string(locale: locale))
            + (try secondText.inspect().text().string(locale: locale))
    }
    
    // MARK: - FormatterTextStorage
    
    private static func extractString(formatterTextStorage: Any) throws -> String {
        let formatter = try Inspector
            .attribute(label: "formatter", value: formatterTextStorage, type: Formatter.self)
        let object = try Inspector.attribute(label: "object", value: formatterTextStorage)
        return formatter.string(for: object) ?? ""
    }
    
    // MARK: - AttachmentTextStorage
    
    private static func extractString(attachmentTextStorage: Any) throws -> String {
        let image = try extractImage(attachmentTextStorage: attachmentTextStorage)
        let description: String = {
            guard let name = try? image.inspect().image().actualImage().name()
            else { return "" }
            return "'\(name)'"
        }()
        return "Image(\(description))"
    }
    
    // MARK: - DateTextStorage
    
    private static func extractString(dateTextStorage: Any) throws -> String {
        throw InspectionError.notSupported("Inspection of formatted Date is currently not supported")
    }
    
    // MARK: - LocalizedTextStorage
    
    private static func extractString(localizedTextStorage: Any, _ locale: Locale) throws -> String {
        let stringContainer = try Inspector
            .attribute(label: "key", value: localizedTextStorage)
        let format = try Inspector
            .attribute(label: "key", value: stringContainer, type: String.self)
        let hasFormatting = try Inspector
            .attribute(label: "hasFormatting", value: stringContainer, type: Bool.self)
        let bundle = try? Inspector
            .attribute(label: "bundle", value: localizedTextStorage, type: Bundle.self)
        let table = try? Inspector
            .attribute(label: "table", value: localizedTextStorage, type: String?.self)
        let localized = (bundle ?? Bundle.main)?
            .path(forResource: locale.identifier
                    .replacingOccurrences(of: "_", with: "-"),
                  ofType: "lproj").flatMap({ Bundle(path: $0) })?
            .localizedString(forKey: format, value: format, table: table) ?? format
        guard hasFormatting else { return localized }
        let arguments = try formattingArguments(stringContainer, locale: locale)
        return String(format: localized, arguments: arguments)
    }
    
    private static func formattingArguments(_ container: Any, locale: Locale) throws -> [CVarArg] {
        return try Inspector
            .attribute(label: "arguments", value: container, type: [Any].self)
            .map { try formattingArgument($0, locale) }
    }
    
    private static func formattingArgument(_ container: Any, _ locale: Locale) throws -> CVarArg {
        if let text = try? Inspector.attribute(path: "storage|text|.0", value: container, type: Text.self) {
            return try text.inspect().text().string(locale: locale)
        }

        if #available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *) {
            if
                let formatStyle = try? Inspector.attribute(
                    path: "storage|formatStyleValue|format", value: container, type: (any FormatStyle).self),
                let input = try? Inspector.attribute(
                    path: "storage|formatStyleValue|input", value: container),
                let string = formatStyle.string(for: input, locale: locale)
            {
                return string
            }
        }

        let valuePath: String
        let formatterPath: String
        if #available(iOS 14, macOS 10.16, tvOS 14, *) {
            valuePath = "storage|value|.0"
            formatterPath = "storage|value|.1"
        } else {
            valuePath = "value"
            formatterPath = "formatter"
        }
        let value = try Inspector.attribute(path: valuePath, value: container, type: CVarArg.self)
        let formatter = try Inspector.attribute(path: formatterPath, value: container, type: Formatter?.self)
        return formatter.flatMap({ $0.string(for: value) }) ?? value
    }
}

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
extension FormatStyle {
    fileprivate func string(for input: Any, locale: Locale) -> String? {
        guard let input = input as? FormatInput else { return nil }
        let formatter = self.locale(locale)
        return formatter.format(input) as? String
    }
}

// MARK: - Image extraction

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
private extension ViewType.Text {
    
    static func extractImages(from view: InspectableView<ViewType.Text>) throws -> [Image] {
        let storage = try Inspector.attribute(label: "storage", value: view.content.view)
        let textStorage = try Inspector.attribute(path: "anyTextStorage", value: storage)
        let storageType = Inspector.typeName(value: textStorage)
        switch storageType {
        case "ConcatenatedTextStorage":
            return try extractImages(concatenatedTextStorage: textStorage)
        case "AttachmentTextStorage":
            return [try extractImage(attachmentTextStorage: textStorage)]
        case "LocalizedTextStorage":
            return try extractImages(localizedTextStorage: textStorage)
        default:
            return []
        }
    }
    
    // MARK: - ConcatenatedTextStorage
    
    private static func extractImages(concatenatedTextStorage: Any) throws -> [Image] {
        let (firstText, secondText) = try extractTexts(concatenatedTextStorage: concatenatedTextStorage)
        return try firstText.inspect().text().images() + secondText.inspect().text().images()
    }
    
    // MARK: - AttachmentTextStorage
    
    private static func extractImage(attachmentTextStorage: Any) throws -> Image {
        return try Inspector
            .attribute(label: "image", value: attachmentTextStorage, type: Image.self)
    }
    
    // MARK: - LocalizedTextStorage
    
    private static func extractImages(localizedTextStorage: Any) throws -> [Image] {
        let stringContainer = try Inspector
            .attribute(label: "key", value: localizedTextStorage)
        let hasFormatting = try Inspector
            .attribute(label: "hasFormatting", value: stringContainer, type: Bool.self)
        guard hasFormatting else { return [] }
        return try extractImageArguments(stringContainer)
    }
    
    private static func extractImageArguments(_ container: Any) throws -> [Image] {
        return try Inspector
            .attribute(label: "arguments", value: container, type: [Any].self)
            .map { try imageArguments($0) }
            .flatMap { $0 }
    }
    
    private static func imageArguments(_ container: Any) throws -> [Image] {
        if let text = try? Inspector.attribute(path: "storage|text|.0", value: container, type: Text.self) {
            return try text.inspect().text().images()
        }
        return []
    }
}

// MARK: - AttributedString extraction

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
private extension ViewType.Text {
    static func extractAttributedString(from view: InspectableView<ViewType.Text>) throws -> AttributedString {
        let textStorage = try Inspector.attribute(path: "storage|anyTextStorage", value: view.content.view)
        let storageType = Inspector.typeName(value: textStorage)
        switch storageType {
        case "AttributedStringTextStorage":
            return try Inspector.attribute(label: "str", value: textStorage, type: AttributedString.self)
        default:
            throw InspectionError.notSupported("Please use attributes() for accessing the text styles on this view")
        }
    }
}
