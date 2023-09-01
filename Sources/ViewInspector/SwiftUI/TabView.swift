import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension ViewType {
    
    struct TabView: KnownViewType {
        public static var typePrefix: String = "TabView"
    }
}

// MARK: - Content Extraction

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension ViewType.TabView: MultipleViewContent {
    
    public static func children(_ content: Content) throws -> LazyGroup<Content> {
        let view = try Inspector.attribute(label: "content", value: content.view)
        let children = try Inspector.viewsInContainer(view: view, medium: content.medium)
        guard let selectedValue = content.tabViewSelectionValue() else {
            return children
        }
        return .init(count: children.count) { index in
            let child = try children.element(at: index)
            if let viewTag = try? InspectableView<ViewType.ClassifiedView>(child, parent: nil).tag(),
                viewTag != selectedValue {
                throw InspectionError.viewNotFound(parent: "tab with tag \(viewTag)")
            }
            return child
        }
    }
}

// MARK: - Extraction from SingleViewContent parent

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView where View: SingleViewContent {
    
    func tabView() throws -> InspectableView<ViewType.TabView> {
        return try .init(try child(), parent: self)
    }
}

// MARK: - Extraction from MultipleViewContent parent

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView where View: MultipleViewContent {
    
    func tabView(_ index: Int) throws -> InspectableView<ViewType.TabView> {
        return try .init(try child(at: index), parent: self, index: index)
    }
}

// MARK: - Global View Modifiers

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView {
    
    func tag() throws -> AnyHashable {
        return try modifierAttribute(
            modifierName: "TagValueTraitKey",
            path: "modifier|value|tagged", type: AnyHashable.self, call: "tag")
    }
    
    func tabItem() throws -> InspectableView<ViewType.ClassifiedView> {
        return try contentForModifierLookup.tabItem(parent: self, index: 0)
    }

    @available(iOS 14.0, macOS 11.0, tvOS 14.0, *)
    func tabViewStyle() throws -> Any {
        let modifier = try self.modifier({ modifier -> Bool in
            return modifier.modifierType.hasPrefix("_TabViewStyleWriter")
        }, call: "tabViewStyle")
        return try Inspector.attribute(path: "modifier|style", value: modifier)
    }
    
    @available(iOS 14.0, tvOS 14.0, *)
    @available(macOS, unavailable)
    func indexViewStyle() throws -> Any {
        let modifier = try self.modifier({ modifier -> Bool in
            return modifier.modifierType.hasPrefix("IndexViewStyleModifier")
        }, call: "indexViewStyle")
        return try Inspector.attribute(path: "modifier|style", value: modifier)
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
internal extension Content {
    
    func tabItem(parent: UnwrappedView, index: Int?) throws -> InspectableView<ViewType.ClassifiedView> {
        let rootView: Any = try {
            if let view = try? modifierAttribute(
                modifierName: "TabItemTraitKey", path: "modifier|value|some|storage|view|content",
                type: Any.self, call: "tabItem") {
                return view
            }
            return try modifierAttribute(
                modifierName: "PlatformItemTraitWriter", path: "modifier|source|content|content",
                type: Any.self, call: "tabItem")
        }()
        let medium = self.medium.resettingViewModifiers()
        let view = try InspectableView<ViewType.ClassifiedView>(
            try Inspector.unwrap(content: Content(rootView, medium: medium)), parent: parent, call: "tabItem()")
        if #available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *) {
            return view
        } else if #available(iOS 14.2, tvOS 14.2, *) {
            return try InspectableView<ViewType.ClassifiedView>(
            try Inspector.unwrap(content: try view.zStack().child(at: 0)), parent: parent, call: "tabItem()")
        } else {
            return view
        }
    }
    
    fileprivate func tabViewSelectionValue() -> AnyHashable? {
        let valueProvider = try? Inspector.cast(value: view, type: SelectionValueProvider.self)
        return valueProvider?.selectionValue()
    }
}

@available(iOS 14.0, tvOS 14.0, watchOS 7.0, *)
@available(macOS, unavailable)
extension PageTabViewStyle: Equatable {
    
    public var indexDisplayMode: PageTabViewStyle.IndexDisplayMode {
        return (try? Inspector.attribute(label: "indexDisplayMode", value: self,
                                         type: PageTabViewStyle.IndexDisplayMode.self)
        ) ?? .automatic
    }
    
    public static func == (lhs: PageTabViewStyle, rhs: PageTabViewStyle) -> Bool {
        return lhs.indexDisplayMode == rhs.indexDisplayMode
    }
}

@available(iOS 14.0, tvOS 14.0, watchOS 7.0, *)
@available(macOS, unavailable)
extension PageTabViewStyle.IndexDisplayMode: Equatable {
    public static func == (lhs: PageTabViewStyle.IndexDisplayMode, rhs: PageTabViewStyle.IndexDisplayMode) -> Bool {
        let lhsBacking = try? Inspector.attribute(label: "backing", value: lhs)
        let rhsBacking = try? Inspector.attribute(label: "backing", value: rhs)
        return String(describing: lhsBacking) == String(describing: rhsBacking)
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
internal protocol SelectionValueProvider {
    func selectionValue() -> AnyHashable?
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 7.0, *)
extension TabView: SelectionValueProvider {
    func selectionValue() -> AnyHashable? {
        let binding = try? Inspector.attribute(label: "selection", value: self, type: Binding<SelectionValue>?.self)
        return binding?.wrappedValue
    }
}
