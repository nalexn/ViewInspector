import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension ViewType {
    
    struct Toolbar: KnownViewType {
        public static let typePrefix: String = {
            if #available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *) {
                return "ToolbarModifier"
            } else {
                return "_ToolbarItemGroupModifier"
            }
        }()
        public static func inspectionCall(typeName: String) -> String {
            return "toolbar(\(ViewType.indexPlaceholder))"
        }
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension ViewType.Toolbar {
    struct Item: KnownViewType {
        public static var typePrefix: String = "ToolbarItem"
    }
    struct ItemGroup: KnownViewType {
        public static var typePrefix: String = "ToolbarItemGroup"
    }
}

// MARK: - Extraction

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView {

    func toolbar(_ index: Int? = nil) throws -> InspectableView<ViewType.Toolbar> {
        return try contentForModifierLookup.toolbar(parent: self, index: index)
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
internal extension Content {
    
    func toolbar(parent: UnwrappedView, index: Int?) throws -> InspectableView<ViewType.Toolbar> {
        let modifierName = ViewType.Toolbar.typePrefix
        let modifier = try self.modifier({ modifier -> Bool in
            return modifier.modifierType.contains(modifierName)
        }, call: "toolbar", index: index ?? 0)
        let root = try Inspector.attribute(label: "modifier", value: modifier)
        let medium = self.medium.resettingViewModifiers()
        let content = try Inspector.unwrap(content: Content(root, medium: medium))
        let call = ViewType.inspectionCall(
            base: ViewType.Toolbar.inspectionCall(typeName: ""), index: index)
        return try .init(content, parent: parent, call: call, index: index)
    }
}

// MARK: - Content

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension ViewType.Toolbar.Item: SingleViewContent {
    
    public static func child(_ content: Content) throws -> Content {
        let view = try Inspector.attribute(label: "content", value: content.view)
        return try Inspector.unwrap(view: view, medium: content.medium)
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension ViewType.Toolbar.Item: MultipleViewContent {
    
    public static func children(_ content: Content) throws -> LazyGroup<Content> {
        let view = try Inspector.attribute(label: "content", value: content.view)
        return try Inspector.viewsInContainer(view: view, medium: content.medium)
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension ViewType.Toolbar.ItemGroup: SingleViewContent {
    
    public static func child(_ content: Content) throws -> Content {
        let view = try Inspector.attribute(label: "content", value: content.view)
        return try Inspector.unwrap(view: view, medium: content.medium)
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension ViewType.Toolbar.ItemGroup: MultipleViewContent {
    
    public static func children(_ content: Content) throws -> LazyGroup<Content> {
        let view = try Inspector.attribute(label: "content", value: content.view)
        return try Inspector.viewsInContainer(view: view, medium: content.medium)
    }
}

// MARK: - Custom Attributes

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView where View == ViewType.Toolbar {
    
    func identifier() throws -> String? {
        return try Inspector.attribute(
            label: "id", value: content.view, type: String?.self)
    }

    func item(_ index: Int = 0) throws -> InspectableView<ViewType.Toolbar.Item> {
        let element = try self.element(index)
        return try .init(Content(element, medium: content.medium), parent: self, index: index)
    }
    
    func itemGroup(_ index: Int = 0) throws -> InspectableView<ViewType.Toolbar.ItemGroup> {
        let element = try self.element(index)
        return try .init(Content(element, medium: content.medium), parent: self, index: index)
    }
    
    private func element(_ index: Int) throws -> Any {
        do {
            return try Inspector.attribute(path: "content|value|.\(index)", value: content.view)
        } catch {
            if index == 0, let value = try? Inspector
                .attribute(path: "content|value", value: content.view) {
                return value
            }
            throw InspectionError.viewNotFound(parent: "toolbar item at index \(index)")
        }
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
private extension Content {
    func toolbarElementsCount() -> Int {
        var index: Int = -1
        var couldLocateItem = false
        repeat {
            index += 1
            couldLocateItem = (try? Inspector.attribute(path: "content|value|.\(index)", value: view)) != nil
        } while couldLocateItem
        if index == 0, (try? Inspector.attribute(path: "content|value", value: view)) != nil {
            return 1
        }
        return index
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension ViewType.Toolbar: SupplementaryChildren {
    static func supplementaryChildren(_ parent: UnwrappedView) throws -> LazyGroup<SupplementaryView> {
        guard let toolbar = parent as? InspectableView<ViewType.Toolbar>
        else { return .empty }
        return .init(count: parent.content.toolbarElementsCount()) { index in
            if let itemGroup = try? toolbar.itemGroup(index) {
                return itemGroup
            }
            return try toolbar.item(index)
        }
    }
}

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
public extension InspectableView where View == ViewType.Toolbar.Item {
    
    func identifier() throws -> String {
        return try Inspector.attribute(
            label: "identifier", value: content.view, type: String.self)
    }
    
    func placement() throws -> ToolbarItemPlacement {
        return try Inspector.attribute(
            label: "placement", value: content.view, type: ToolbarItemPlacement.self)
    }
    
    func showsByDefault() throws -> Bool {
        return try Inspector.attribute(
            label: "showsByDefault", value: content.view, type: Bool.self)
    }
}

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
public extension InspectableView where View == ViewType.Toolbar.ItemGroup {
    func placement() throws -> ToolbarItemPlacement {
        return try Inspector.attribute(
            label: "placement", value: content.view, type: ToolbarItemPlacement.self)
    }
}

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
extension ToolbarItemPlacement: BinaryEquatable { }
