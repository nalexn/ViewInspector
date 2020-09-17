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
    
    func string() throws -> String {
        if let first = try? Inspector
                .attribute(path: "storage|anyTextStorage|first", value: content.view, type: Text.self),
            let second = try? Inspector
                .attribute(path: "storage|anyTextStorage|second", value: content.view, type: Text.self) {
            let firstText = try first.inspect().text().string()
            let secondText = try second.inspect().text().string()
            return firstText + secondText
        }
        if let externalString = try? Inspector
            .attribute(path: "storage|verbatim", value: content.view, type: String.self) {
            return externalString
        }
        let textStorage = try Inspector
            .attribute(path: "storage|anyTextStorage", value: content.view)
        let localizedStringKey = try Inspector
            .attribute(path: "key", value: textStorage)
        let baseString = try Inspector
            .attribute(label: "key", value: localizedStringKey, type: String.self)
        let hasFormatting = try Inspector
            .attribute(label: "hasFormatting", value: localizedStringKey, type: Bool.self)
        guard hasFormatting else { return baseString }
        let arguments = try Inspector
            .attribute(label: "arguments", value: localizedStringKey, type: [Any].self)
        let values: [CVarArg] = try arguments.map {
            String(describing: try Inspector.attribute(path: stringArgumentPath, value: $0))
        }
        let argPatterns = ["%lld", "%ld", "%d", "%lf", "%f"]
        let format: String = argPatterns.reduce(baseString) { (format, pattern) in
            format.replacingOccurrences(of: pattern, with: "%@")
        }
        return String(format: format, arguments: values)
    }
    
    var stringArgumentPath: String {
        if #available(iOS 14, tvOS 14, macOS 10.16, *) {
            return "storage|value|.0"
        } else {
            return "value"
        }
    }
    
    func attributes() throws -> TextAttributes {
        if let first = try? Inspector
                .attribute(path: "storage|anyTextStorage|first", value: content.view, type: Text.self),
            let second = try? Inspector
                .attribute(path: "storage|anyTextStorage|second", value: content.view, type: Text.self) {
            let firstAttr = try first.inspect().text().attributes()
            let secondAttr = try second.inspect().text().attributes()
            return firstAttr + secondAttr
        }
        let string = try self.string()
        let modifiers = try Inspector.attribute(label: "modifiers", value: content.view, type: [Any].self)
        return .init(string: string, modifiers: modifiers)
    }
}

// MARK: - TextAttributes

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView.TextAttributes {
    
    subscript<Range>(_ range: Range) -> Self where Range: RangeExpression, Range.Bound == Int {
        let relativeRange = range.relative(to: 0..<string.count)
        let chunksInRange = zip(chunkRanges, chunks)
            .filter { relativeRange.overlaps($0.0) }
            .map { $0.1 }
        return .init(chunks: chunksInRange)
    }

    subscript<Range>(_ range: Range) -> Self where Range: RangeExpression, Range.Bound == String.Index {
        let relativeRange = range.relative(to: string)
        let chunksInRange = zip(chunkStringRanges, chunks)
            .filter { relativeRange.overlaps($0.0) }
            .map { $0.1 }
        return .init(chunks: chunksInRange)
    }
    
    func isItalic() throws -> Bool {
        return try commonTrait(name: "italic") { modifier in
            String(describing: modifier) == "italic" ? true : nil
        } == true
    }
    
    func isBold() throws -> Bool {
        return try commonTrait(name: "bold") { modifier in
            guard let child = try? Inspector.attribute(label: "anyTextModifier", value: modifier)
                else { return nil }
            return Inspector.typeName(value: child) == "BoldTextModifier" ? true : nil
        } == true
    }
    
    func fontWeight() throws -> Font.Weight {
        return try commonTrait(name: "fontWeight") { modifier -> Font.Weight? in
            guard let fontWeight = try? Inspector
                .attribute(path: "weight|some", value: modifier, type: Font.Weight.self)
                else { return nil }
            return fontWeight
        }
    }
    
    func font() throws -> Font {
        return try commonTrait(name: "font") { modifier -> Font? in
            guard let fontProvider = try? Inspector
                .attribute(path: "font|some|provider|base", value: modifier)
                else { return nil }
            let providerName = Inspector.typeName(value: fontProvider)
            if providerName == "SystemProvider" {
                let size = try Inspector.attribute(label: "size", value: fontProvider, type: CGFloat.self)
                let weight = try Inspector.attribute(label: "weight", value: fontProvider, type: Font.Weight.self)
                let design = try Inspector.attribute(label: "design", value: fontProvider, type: Font.Design.self)
                return .system(size: size, weight: weight, design: design)
            }
            if providerName == "NamedProvider" {
                let name = try Inspector.attribute(label: "name", value: fontProvider, type: String.self)
                let size = try Inspector.attribute(label: "size", value: fontProvider, type: CGFloat.self)
                return .custom(name, size: size)
            }
            return nil
        }
    }
    
    func foregroundColor() throws -> Color {
        return try commonTrait(name: "foregroundColor") { modifier -> Color? in
            guard let color = try? Inspector
                .attribute(path: "color|some", value: modifier, type: Color.self)
                else { return nil }
            return color
        }
    }
    
    func strikethrough() throws -> Bool {
        return try commonTrait(name: "strikethrough") { modifier -> Bool? in
            guard let child = try? Inspector.attribute(label: "anyTextModifier", value: modifier),
                Inspector.typeName(value: child) == "StrikethroughTextModifier",
                let active = try? Inspector
                    .attribute(path: "lineStyle|some|active", value: child, type: Bool.self)
                else { return nil }
            return active
        }
    }
    
    func strikethroughColor() throws -> Color? {
        return try commonTrait(name: "strikethrough") { modifier -> Color? in
            guard let child = try? Inspector.attribute(label: "anyTextModifier", value: modifier),
                Inspector.typeName(value: child) == "StrikethroughTextModifier",
                let color = try? Inspector
                    .attribute(path: "lineStyle|some|color", value: child, type: Color?.self)
                else { return nil }
            return color
        }
    }
    
    func underline() throws -> Bool {
        return try commonTrait(name: "underline") { modifier -> Bool? in
            guard let child = try? Inspector.attribute(label: "anyTextModifier", value: modifier),
                Inspector.typeName(value: child) == "UnderlineTextModifier",
                let active = try? Inspector
                    .attribute(path: "lineStyle|some|active", value: child, type: Bool.self)
                else { return nil }
            return active
        }
    }
    
    func underlineColor() throws -> Color? {
        return try commonTrait(name: "underline") { modifier -> Color? in
            guard let child = try? Inspector.attribute(label: "anyTextModifier", value: modifier),
                Inspector.typeName(value: child) == "UnderlineTextModifier",
                let color = try? Inspector
                    .attribute(path: "lineStyle|some|color", value: child, type: Color?.self)
                else { return nil }
            return color
        }
    }
    
    func kerning() throws -> CGFloat {
        return try commonTrait(name: "kerning") { modifier -> CGFloat? in
            guard let kerning = try? Inspector
                .attribute(label: "kerning", value: modifier, type: CGFloat.self)
                else { return nil }
            return kerning
        }
    }
    
    func tracking() throws -> CGFloat {
        return try commonTrait(name: "tracking") { modifier -> CGFloat? in
            guard let kerning = try? Inspector
                .attribute(label: "tracking", value: modifier, type: CGFloat.self)
                else { return nil }
            return kerning
        }
    }
    
    func baselineOffset() throws -> CGFloat {
        return try commonTrait(name: "baselineOffset") { modifier -> CGFloat? in
            guard let kerning = try? Inspector
                .attribute(label: "baseline", value: modifier, type: CGFloat.self)
                else { return nil }
            return kerning
        }
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView {
    struct TextAttributes {
        
        private struct Chunk {
            let string: String
            let modifiers: [Any]

            var length: Int {
                string.count
            }
        }
        private let chunks: [Chunk]
        
        private init(chunks: [Chunk]) {
            self.chunks = chunks
        }
        
        fileprivate init(string: String, modifiers: [Any]) {
            self.init(chunks: [Chunk(string: string, modifiers: modifiers)])
        }
        
        fileprivate static func + (lhs: TextAttributes, rhs: TextAttributes) -> TextAttributes {
            return TextAttributes(chunks: lhs.chunks + rhs.chunks)
        }
        
        private var chunkRanges: [Range<Int>] {
            return chunks.reduce([]) { (array, chunk) in
                let start = array.last?.upperBound ?? 0
                return array + [start ..< start + chunk.length]
            }
        }

        private var chunkStringRanges: [Range<String.Index>] {
            var totalString = ""
            return chunks.reduce([]) { (array, chunk) in
                let start = totalString.endIndex
                totalString += chunk.string
                let end = totalString.endIndex
                return array + [start ..< end]
            }
        }

        private var string: String {
            chunks.map { $0.string }.joined()
        }
        
        private func commonTrait<V>(name: String, _ trait: (Any) throws -> V?) throws -> V where V: Equatable {
            guard chunks.count > 0 else {
                throw InspectionError.textAttribute("Invalid text range")
            }
            let traits = try chunks.compactMap { chunk -> V? in
                for modifier in chunk.modifiers {
                    if let value = try trait(modifier) {
                        return value
                    }
                }
                return nil
            }
            guard let trait = traits.first else {
                throw InspectionError.modifierNotFound(parent: "Text", modifier: name)
            }
            guard traits.count == chunks.count else {
                throw InspectionError.textAttribute("Modifier '\(name)' is applied only to a subrange")
            }
            guard traits.allSatisfy({ $0 == trait }) else {
                throw InspectionError.textAttribute("Modifier '\(name)' has different values in subranges")
            }
            return trait
        }
    }
}
