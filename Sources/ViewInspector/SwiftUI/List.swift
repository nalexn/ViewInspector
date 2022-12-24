import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension ViewType {
    
    struct List: KnownViewType {
        public static let typePrefix: String = "List"
    }
}

// MARK: - Content Extraction

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension ViewType.List: MultipleViewContent {
    
    public static func children(_ content: Content) throws -> LazyGroup<Content> {
        let view = try Inspector.attribute(label: "content", value: content.view)
        return try Inspector.viewsInContainer(view: view, medium: content.medium)
    }
}

// MARK: - Extraction from SingleViewContent parent

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView where View: SingleViewContent {
    
    func list() throws -> InspectableView<ViewType.List> {
        return try .init(try child(), parent: self)
    }
}

// MARK: - Extraction from MultipleViewContent parent

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView where View: MultipleViewContent {
    
    func list(_ index: Int) throws -> InspectableView<ViewType.List> {
        return try .init(try child(at: index), parent: self, index: index)
    }
}

// MARK: - Global View Modifiers

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView {
    
    func listRowInsets() throws -> EdgeInsets {
        return try modifierAttribute(
            modifierName: "_TraitWritingModifier<ListRowInsetsTraitKey>",
            path: "modifier|value|some", type: EdgeInsets.self, call: "listRowInsets")
    }
    
    func listRowBackground(_ index: Int? = nil) throws -> InspectableView<ViewType.ClassifiedView> {
        return try contentForModifierLookup.listRowBackground(parent: self, index: index)
    }

    func listItemTint() throws -> (color: Color, isFixed: Bool) {
        let color = try modifierAttribute(
            modifierName: "_TraitWritingModifier<ListItemTintTraitKey>",
            path: "modifier|value|some|effect|color", type: Color.self, call: "listItemTint")
        let isFixed = try modifierAttribute(
            modifierName: "_TraitWritingModifier<ListItemTintTraitKey>",
            path: "modifier|value|some|isFixed", type: Bool.self, call: "listItemTint")

        return (color, isFixed)
    }

    func listStyle() throws -> Any {
        let modifier = try self.modifier({ modifier -> Bool in
            return modifier.modifierType.hasPrefix("ListStyleWriter")
        }, call: "listStyle")
        return try Inspector.attribute(path: "modifier|style", value: modifier)
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
internal extension Content {
    
    func listRowBackground(parent: UnwrappedView, index: Int?) throws -> InspectableView<ViewType.ClassifiedView> {
        let view = try modifierAttribute(
            modifierName: "_TraitWritingModifier<ListRowBackgroundTraitKey>",
            path: "modifier|value|some|storage|view", type: Any.self,
            call: "listRowBackground", index: index ?? 0)
        let medium = self.medium.resettingViewModifiers()
        let content = try Inspector.unwrap(content: Content(view, medium: medium))
        let call = ViewType.inspectionCall(
            base: "listRowBackground(\(ViewType.indexPlaceholder))", index: index)
        return try .init(content, parent: parent, call: call, index: index)
    }
}
