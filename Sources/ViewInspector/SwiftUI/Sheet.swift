import SwiftUI

// MARK: - Sheet

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension ViewType {
    
    struct Sheet: KnownViewType {
        public static var typePrefix: String = "ViewType.Sheet.Container"
        public static var namespacedPrefixes: [String] {
            return ["ViewInspector." + typePrefix]
        }
        public static func inspectionCall(typeName: String) -> String {
            return "sheet(\(ViewType.indexPlaceholder))"
        }
    }
}

// MARK: - Content Extraction

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension ViewType.Sheet: SingleViewContent {
    
    public static func child(_ content: Content) throws -> Content {
        let view = try Inspector.attribute(label: "view", value: content.view)
        let medium = content.medium.resettingViewModifiers()
        return try Inspector.unwrap(view: view, medium: medium)
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension ViewType.Sheet: MultipleViewContent {
    
    public static func children(_ content: Content) throws -> LazyGroup<Content> {
        let view = try Inspector.attribute(label: "view", value: content.view)
        let medium = content.medium.resettingViewModifiers()
        return try Inspector.viewsInContainer(view: view, medium: medium)
    }
}

// MARK: - Extraction

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView {

    func sheet(_ index: Int? = nil) throws -> InspectableView<ViewType.Sheet> {
        return try contentForModifierLookup.sheet(parent: self, index: index)
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
internal extension Content {
    
    func sheet(parent: UnwrappedView, index: Int?) throws -> InspectableView<ViewType.Sheet> {
        guard let sheetBuilder = try? self.modifierAttribute(
                modifierLookup: { isSheetBuilder(modifier: $0) }, path: "modifier",
                type: SheetBuilder.self, call: "", index: index ?? 0)
        else {
            _ = try self.modifier({
                $0.modifierType == "IdentifiedPreferenceTransformModifier<Key>"
                || $0.modifierType.contains("SheetPresentationModifier")
            }, call: "sheet")
            throw InspectionError.notSupported(
                """
                Please refer to the Guide for inspecting the Sheet: \
                https://github.com/nalexn/ViewInspector/blob/master/guide.md#sheet
                """)
        }
        let view = try sheetBuilder.buildSheet()
        let container = ViewType.Sheet.Container(view: view, builder: sheetBuilder)
        let medium = self.medium.resettingViewModifiers()
        let content = Content(container, medium: medium)
        let call = ViewType.inspectionCall(
            base: ViewType.Sheet.inspectionCall(typeName: ""), index: index)
        return try .init(content, parent: parent, call: call, index: index)
    }
    
    func sheetsForSearch() -> [ViewSearch.ModifierIdentity] {
        let count = medium.viewModifiers
            .compactMap { isSheetBuilder(modifier: $0) }
            .count
        return Array(0..<count).map { _ in
            .init(name: "", builder: { parent, index in
                try parent.content.sheet(parent: parent, index: index)
            })
        }
    }
    
    private func isSheetBuilder(modifier: Any) -> Bool {
        return (try? Inspector.attribute(
            label: "modifier", value: modifier, type: SheetBuilder.self)) != nil
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
internal extension ViewType.Sheet {
    struct Container: CustomViewIdentityMapping {
        let view: Any
        let builder: SheetBuilder
        
        var viewTypeForSearch: KnownViewType.Type { ViewType.Sheet.self }
    }
}

// MARK: - Custom Attributes

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView where View == ViewType.Sheet {

    func callOnDismiss() throws {
        let sheet = try Inspector.cast(value: content.view, type: ViewType.Sheet.Container.self)
        sheet.builder.dismissPopup()
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public protocol SheetBuilder: SystemPopupPresenter {
    var onDismiss: (() -> Void)? { get }
    func buildSheet() throws -> Any
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public protocol SheetProvider: SheetBuilder {
    var isPresented: Binding<Bool> { get }
    var sheetBuilder: () -> Any { get }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public protocol SheetItemProvider: SheetBuilder {
    associatedtype Item: Identifiable
    var item: Binding<Item?> { get }
    var sheetBuilder: (Item) -> Any { get }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension SheetProvider {
    
    func buildSheet() throws -> Any {
        guard isPresented.wrappedValue else {
            throw InspectionError.viewNotFound(parent: "Sheet")
        }
        return sheetBuilder()
    }
    
    func dismissPopup() {
        isPresented.wrappedValue = false
        onDismiss?()
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension SheetItemProvider {
    
    func buildSheet() throws -> Any {
        guard let value = item.wrappedValue else {
            throw InspectionError.viewNotFound(parent: "Sheet")
        }
        return sheetBuilder(value)
    }
    
    func dismissPopup() {
        item.wrappedValue = nil
        onDismiss?()
    }
}
