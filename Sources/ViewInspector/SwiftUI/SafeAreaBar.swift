import SwiftUI

// MARK: - SafeAreaBar

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension ViewType {

    struct SafeAreaBar: KnownViewType {
        public static let typePrefix: String = "SafeAreaBarModifier"
        public static func inspectionCall(typeName: String) -> String {
            return "safeAreaBar(\(ViewType.indexPlaceholder))"
        }
    }
}

// MARK: - Extraction

@available(iOS 26.0, macOS 26.0, tvOS 26.0, visionOS 26.0, *)
public extension InspectableView {

    func safeAreaBar(_ index: Int? = nil) throws -> InspectableView<ViewType.SafeAreaBar> {
        return try contentForModifierLookup.safeAreaBar(parent: self, index: index)
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
internal extension Content {

    func safeAreaBar(parent: UnwrappedView, index: Int?) throws -> InspectableView<ViewType.SafeAreaBar> {
        let modifier = try self.modifierAttribute(
            modifierLookup: isSafeAreaBar(modifier:), path: "modifier",
            type: Any.self, call: "safeAreaBar", index: index ?? 0)
        let medium = self.medium.resettingViewModifiers()
        let content = Content(modifier, medium: medium)
        let call = ViewType.inspectionCall(
            base: ViewType.SafeAreaBar.inspectionCall(typeName: ""), index: index)
        return try .init(content, parent: parent, call: call, index: index)
    }

    private func isSafeAreaBar(modifier: Any) -> Bool {
        guard let modifier = modifier as? ModifierNameProvider
        else { return false }
        return modifier.modifierType.contains(ViewType.SafeAreaBar.typePrefix)
    }
}

// MARK: - Content Extraction

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension ViewType.SafeAreaBar: SingleViewContent {

    public static func child(_ content: Content) throws -> Content {
        let view = try SafeAreaBarContentExtractor.childView(from: content.view)
        let medium = content.medium.resettingViewModifiers()
        return try Inspector.unwrap(view: view, medium: medium)
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension ViewType.SafeAreaBar: MultipleViewContent {

    public static func children(_ content: Content) throws -> LazyGroup<Content> {
        let view = try SafeAreaBarContentExtractor.childView(from: content.view)
        return try Inspector.viewsInContainer(view: view, medium: content.medium)
    }
}

// MARK: - Custom Attributes

@available(iOS 26.0, macOS 26.0, tvOS 26.0, visionOS 26.0, *)
public enum SafeAreaBarEdge: Equatable {
    case horizontal(HorizontalEdge)
    case vertical(VerticalEdge)
}

@available(iOS 26.0, macOS 26.0, tvOS 26.0, visionOS 26.0, *)
public enum SafeAreaBarAlignment: Equatable {
    case horizontal(HorizontalAlignment)
    case vertical(VerticalAlignment)
}

@available(iOS 26.0, macOS 26.0, tvOS 26.0, visionOS 26.0, *)
public extension InspectableView where View == ViewType.SafeAreaBar {

    func edge() throws -> SafeAreaBarEdge {
        let edge = try SafeAreaBarContentExtractor.property(
            named: "edge", in: content.view, type: Edge.self)
        switch edge {
        case .top:
            return .vertical(.top)
        case .bottom:
            return .vertical(.bottom)
        case .leading:
            return .horizontal(.leading)
        case .trailing:
            return .horizontal(.trailing)
        }
    }

    func alignment() throws -> SafeAreaBarAlignment {
        let edge = try SafeAreaBarContentExtractor.property(
            named: "edge", in: content.view, type: Edge.self)
        let alignmentKey = try SafeAreaBarContentExtractor.property(
            named: "alignmentKey", in: content.view)
        let bits = try SafeAreaBarContentExtractor.alignmentBits(from: alignmentKey)
        switch edge {
        case .top, .bottom:
            return .horizontal(SafeAreaBarContentExtractor.horizontalAlignment(bits: bits))
        case .leading, .trailing:
            return .vertical(SafeAreaBarContentExtractor.verticalAlignment(bits: bits))
        }
    }

    func spacing() throws -> CGFloat? {
        return try SafeAreaBarContentExtractor.property(
            named: "spacing", in: content.view, type: CGFloat?.self)
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
private enum SafeAreaBarContentExtractor {

    private static let contentLabels = [
        "content",
        "_content",
        "bar",
        "_bar",
        "barContent",
        "_barContent",
        "secondary",
    ]

    static func childView(from value: Any) throws -> Any {
        if let view = try? Inspector.attribute(path: "properties|content", value: value) {
            return view
        }
        for label in contentLabels {
            if let view = try? Inspector.attribute(label: label, value: value) {
                return view
            }
        }
        let typeName = Inspector.typeName(value: value, generics: .remove)
        throw InspectionError.attributeNotFound(label: "content", type: typeName)
    }

    static func property(named name: String, in value: Any) throws -> Any {
        if let property = try? Inspector.attribute(path: "properties|\(name)", value: value) {
            return property
        }
        if let property = try? Inspector.attribute(label: name, value: value) {
            return property
        }
        if let property = try? Inspector.attribute(label: "_\(name)", value: value) {
            return property
        }
        let typeName = Inspector.typeName(value: value, generics: .remove)
        throw InspectionError.attributeNotFound(label: name, type: typeName)
    }

    static func property<T>(named name: String, in value: Any, type: T.Type) throws -> T {
        if let property = try? Inspector.attribute(path: "properties|\(name)", value: value, type: T.self) {
            return property
        }
        if let property = try? Inspector.attribute(label: name, value: value, type: T.self) {
            return property
        }
        if let property = try? Inspector.attribute(label: "_\(name)", value: value, type: T.self) {
            return property
        }
        let typeName = Inspector.typeName(value: value, generics: .remove)
        throw InspectionError.attributeNotFound(label: name, type: typeName)
    }

    static func alignmentBits(from value: Any) throws -> Int {
        let mirror = Mirror(reflecting: value)
        if let bits = mirror.children.first(where: { $0.label == "bits" })?.value as? Int {
            return bits
        }
        let description = String(describing: value)
        if let range = description.range(of: "bits:") {
            let tail = description[range.upperBound...]
            let digits = tail.prefix { $0 == " " || $0.isNumber }
                .trimmingCharacters(in: .whitespaces)
            if let bits = Int(digits) {
                return bits
            }
        }
        let name = Inspector.typeName(value: value, generics: .remove)
        throw InspectionError.typeMismatch(factual: name, expected: "AlignmentKey")
    }

    static func horizontalAlignment(bits: Int) -> HorizontalAlignment {
        let candidates: [HorizontalAlignment] = [.leading, .center, .trailing]
        if let match = candidates.first(where: { alignmentBits(for: $0) == bits }) {
            return match
        }
        return .leading
    }

    static func verticalAlignment(bits: Int) -> VerticalAlignment {
        let candidates: [VerticalAlignment] = [.top, .center, .bottom]
        if let match = candidates.first(where: { alignmentBits(for: $0) == bits }) {
            return match
        }
        return .top
    }

    private static func alignmentBits<T>(for alignment: T) -> Int? {
        let mirror = Mirror(reflecting: alignment)
        guard let key = mirror.children.first(where: { $0.label == "key" })?.value else {
            return nil
        }
        return try? alignmentBits(from: key)
    }
}
