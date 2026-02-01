import SwiftUI

// MARK: - ViewType

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension ViewType {

    struct Tab: KnownViewType {
        public static let typePrefix: String = "Tab"
        public static var namespacedPrefixes: [String] {
            ["SwiftUI.Tab"]
        }
    }
}

// MARK: - Content Extraction

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
extension ViewType.Tab: SingleViewContent {

    public static func child(_ content: Content) throws -> Content {
        let tabContent = try Inspector.attribute(label: "content", value: content.view)
        return try Inspector.unwrap(content: Content(tabContent, medium: content.medium.resettingViewModifiers()))
    }
}

// MARK: - Extraction from SingleViewContent parent

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
public extension InspectableView where View: SingleViewContent {

    func tab() throws -> InspectableView<ViewType.Tab> {
        return try .init(try child(), parent: self)
    }
}

// MARK: - Extraction from MultipleViewContent parent

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
public extension InspectableView where View: MultipleViewContent {

    func tab(_ index: Int) throws -> InspectableView<ViewType.Tab> {
        return try .init(try child(at: index), parent: self, index: index)
    }
}

// MARK: - Custom Attributes

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
public extension InspectableView where View == ViewType.Tab {

    /// Returns the label view for this tab (typically a `Label<Text, Image>`).
    func labelView() throws -> InspectableView<ViewType.ClassifiedView> {
        let tabItem = try Inspector.attribute(label: "tabItem", value: content.view)
        // DefaultTabLabel has base: Optional<Label<Text, Image>>
        let labelBase = try Inspector.attribute(path: "base|some", value: tabItem)
        return try .init(Content(labelBase, medium: content.medium.resettingViewModifiers()), parent: self, call: "labelView()")
    }

    /// Returns the tab's role, if any.
    func role() throws -> TabRole? {
        return try Inspector.attribute(label: "role", value: content.view, type: TabRole?.self)
    }
}

// MARK: - Internal helpers for TabView

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
internal extension ViewType.Tab {

    /// Extracts children from _TupleTabContent which wraps multiple Tab items.
    static func childrenFromTupleTabContent(_ content: Content) throws -> LazyGroup<Content> {
        // Path: Content<_TupleTabContent>._content.wrappedValue._identifiedView (TupleView)
        // content.view should be Content<_TupleTabContent<...>>
        let nestedDynamic = try Inspector.attribute(label: "_content", value: content.view)
        let tupleTabContent = try Inspector.attribute(label: "wrappedValue", value: nestedDynamic)
        let identifiedView = try Inspector.attribute(label: "_identifiedView", value: tupleTabContent)

        // identifiedView is a TupleView<(ModifiedContent<TabIdentifiedView, ...>, ...)>
        let tupleViews = try Inspector.attribute(label: "value", value: identifiedView)
        let childrenCount = Mirror(reflecting: tupleViews).children.count
        let medium = content.medium.resettingViewModifiers()

        return LazyGroup(count: childrenCount) { index in
            // Each element is ModifiedContent<TabIdentifiedView, _TraitWritingModifier<...>>
            let modifiedContent = try Inspector.attribute(label: ".\(index)", value: tupleViews)
            // Get TabIdentifiedView from ModifiedContent.content
            let tabIdentifiedView = try Inspector.attribute(label: "content", value: modifiedContent)
            // Get the actual Tab from TabIdentifiedView.tab
            let tab = try Inspector.attribute(label: "tab", value: tabIdentifiedView)
            return try Inspector.unwrap(content: Content(tab, medium: medium))
        }
    }

    /// Extracts single Tab from Content<Tab<...>> wrapper.
    static func childFromSingleTabContent(_ content: Content) throws -> LazyGroup<Content> {
        // Path: Content<Tab>._content.wrappedValue (Tab)
        // content.view should be Content<Tab<...>>
        let nestedDynamic = try Inspector.attribute(label: "_content", value: content.view)
        let tab = try Inspector.attribute(label: "wrappedValue", value: nestedDynamic)
        let medium = content.medium.resettingViewModifiers()
        let tabContent = try Inspector.unwrap(content: Content(tab, medium: medium))

        return LazyGroup(count: 1) { _ in tabContent }
    }
}
