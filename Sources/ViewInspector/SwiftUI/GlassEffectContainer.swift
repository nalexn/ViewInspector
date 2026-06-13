import SwiftUI

// MARK: - ViewType

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension ViewType {

    struct GlassEffectContainer: KnownViewType {
        public static let typePrefix: String = "GlassEffectContainer"
    }

    /// A wrapper for inspecting glass effect modifier parameters.
    @available(iOS 26.0, macOS 26.0, tvOS 26.0, watchOS 26.0, *)
    struct GlassEffect {
        private let config: Any

        internal init(config: Any) {
            self.config = config
        }

        /// Returns the tint color applied to the glass effect, if any.
        public func tintColor() throws -> SwiftUI.Color? {
            // iOS 27 moved the glass parameters into a `glass.storage` dictionary
            // keyed by an enum (`tint`, `options`); iOS 26 used named members.
            if #available(iOS 27.0, macOS 27.0, tvOS 27.0, watchOS 27.0, *) {
                guard let value = glassStorageValue(forKey: "tint") else { return nil }
                return try? Inspector.attribute(label: "tint", value: value, type: SwiftUI.Color.self)
            }
            return try? Inspector.attribute(
                path: "glass|tintColor|some", value: config, type: SwiftUI.Color.self)
        }

        /// Returns the shape used for the glass effect.
        public func shape<S>(_ type: S.Type) throws -> S where S: SwiftUI.Shape {
            let shapeValue = try Inspector.attribute(
                path: "shape|storage|shape", value: config, type: Any.self)
            return try Inspector.cast(value: shapeValue, type: S.self)
        }

        /// Returns whether the glass effect is interactive.
        public func isInteractive() throws -> Bool {
            let rawValue: Int
            if #available(iOS 27.0, macOS 27.0, tvOS 27.0, watchOS 27.0, *) {
                if let value = glassStorageValue(forKey: "options"),
                   let raw = try? Inspector.attribute(
                    path: "options|rawValue", value: value, type: Int.self) {
                    rawValue = raw
                } else {
                    rawValue = 0
                }
            } else {
                rawValue = try Inspector.attribute(
                    path: "glass|options|rawValue", value: config, type: Int.self)
            }
            return (rawValue & 1) != 0
        }

        /// iOS 27: looks up a value in the `glass.storage` dictionary by its enum key name.
        private func glassStorageValue(forKey key: String) -> Any? {
            guard let storage = try? Inspector.attribute(path: "glass|storage", value: config)
            else { return nil }
            for child in Mirror(reflecting: storage).children {
                let pair = Array(Mirror(reflecting: child.value).children)
                guard pair.count == 2, String(describing: pair[0].value) == key
                else { continue }
                return pair[1].value
            }
            return nil
        }
    }
}

// MARK: - Content Extraction

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension ViewType.GlassEffectContainer: MultipleViewContent {

    public static func children(_ content: Content) throws -> LazyGroup<Content> {
        let container = try Inspector.attribute(path: "base|content", value: content.view)
        return try Inspector.viewsInContainer(view: container, medium: content.medium)
    }
}

// MARK: - Extraction from SingleViewContent parent

@available(iOS 26.0, macOS 26.0, tvOS 26.0, watchOS 26.0, *)
@available(visionOS, unavailable)
public extension InspectableView where View: SingleViewContent {

    func glassEffectContainer() throws -> InspectableView<ViewType.GlassEffectContainer> {
        return try .init(try child(), parent: self)
    }
}

// MARK: - Extraction from MultipleViewContent parent

@available(iOS 26.0, macOS 26.0, tvOS 26.0, watchOS 26.0, *)
@available(visionOS, unavailable)
public extension InspectableView where View: MultipleViewContent {

    func glassEffectContainer(_ index: Int) throws -> InspectableView<ViewType.GlassEffectContainer> {
        return try .init(try child(at: index), parent: self, index: index)
    }
}

// MARK: - Custom Attributes

@available(iOS 26.0, macOS 26.0, tvOS 26.0, watchOS 26.0, *)
@available(visionOS, unavailable)
public extension InspectableView where View == ViewType.GlassEffectContainer {

    func spacing() throws -> CGFloat? {
        // iOS 27 wraps the spacing in a `Smoothness` struct; iOS 26 stored a CGFloat? directly.
        if #available(iOS 27.0, macOS 27.0, tvOS 27.0, watchOS 27.0, *) {
            return try Inspector.attribute(
                path: "base|config|smoothness|value", value: content.view, type: CGFloat.self)
        }
        return try Inspector.attribute(
            path: "base|config|smoothness", value: content.view, type: CGFloat?.self)
    }
}

// MARK: - Glass Effect Modifiers

@available(iOS 26.0, macOS 26.0, tvOS 26.0, watchOS 26.0, *)
@available(visionOS, unavailable)
public extension InspectableView {

    /// Returns the glass effect configuration for inspection.
    func glassEffect() throws -> ViewType.GlassEffect {
        // iOS 27 wraps GlassEffectModifier in a StaticIf, nesting the config under `trueBody`.
        if #available(iOS 27.0, macOS 27.0, tvOS 27.0, watchOS 27.0, *) {
            let config = try modifierAttribute(
                modifierName: "GlassEffectModifier", path: "modifier|trueBody|config",
                type: Any.self, call: "glassEffect")
            return ViewType.GlassEffect(config: config)
        }
        let config = try modifierAttribute(
            modifierName: "GlassEffectModifier", path: "modifier|config",
            type: Any.self, call: "glassEffect")
        return ViewType.GlassEffect(config: config)
    }

    /// Returns the glass effect transition.
    func glassEffectTransition() throws -> GlassEffectTransition {
        let kind = try modifierAttribute(
            modifierName: "GlassEffectTransitionModifier", path: "modifier|transition|kind",
            type: Any.self, call: "glassEffectTransition")
        let description = String(describing: kind)
        if description.hasPrefix("materialize") {
            return .materialize
        } else if description.hasPrefix("matchedGeometry") {
            return .matchedGeometry
        } else {
            return .identity
        }
    }

    func glassEffectID() throws -> (id: AnyHashable?, namespace: Namespace.ID) {
        let id = try modifierAttribute(
            modifierName: "GlassEffectIDModifier", path: "modifier|id",
            type: AnyHashable?.self, call: "glassEffectID")
        let namespace = try modifierAttribute(
            modifierName: "GlassEffectIDModifier", path: "modifier|namespace",
            type: Namespace.ID.self, call: "glassEffectID")
        return (id, namespace)
    }

    func glassEffectUnion() throws -> (id: AnyHashable?, namespace: Namespace.ID?) {
        let id = try modifierAttribute(
            modifierName: "GlassEffectGroupModifier", path: "modifier|config|id",
            type: AnyHashable?.self, call: "glassEffectUnion")
        let namespace = try modifierAttribute(
            modifierName: "GlassEffectGroupModifier", path: "modifier|config|namespace",
            type: Namespace.ID?.self, call: "glassEffectUnion")
        return (id, namespace)
    }
}

@available(iOS 26.0, macOS 26.0, tvOS 26.0, watchOS 26.0, *)
@available(visionOS, unavailable)
extension GlassEffectTransition: BinaryEquatable { }
