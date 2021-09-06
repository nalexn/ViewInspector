import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension ViewType {
    
    struct Popover: KnownViewType {
        public static var typePrefix: String = "ViewType.Popover.Container"
        public static var namespacedPrefixes: [String] {
            return ["ViewInspector." + typePrefix]
        }
        public static func inspectionCall(typeName: String) -> String {
            return "popover(\(ViewType.indexPlaceholder))"
        }
    }
}

// MARK: - Content Extraction

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension ViewType.Popover: SingleViewContent {
    
    public static func child(_ content: Content) throws -> Content {
        let view = try Inspector.attribute(label: "view", value: content.view)
        let medium = content.medium.resettingViewModifiers()
        return try Inspector.unwrap(view: view, medium: medium)
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension ViewType.Popover: MultipleViewContent {
    
    public static func children(_ content: Content) throws -> LazyGroup<Content> {
        let view = try Inspector.attribute(label: "view", value: content.view)
        let medium = content.medium.resettingViewModifiers()
        return try Inspector.viewsInContainer(view: view, medium: medium)
    }
}

// MARK: - Extraction

@available(iOS 13.0, macOS 10.15, *)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
public extension InspectableView {
    
    func popover(_ index: Int? = nil) throws -> InspectableView<ViewType.Popover> {
        return try contentForModifierLookup.popover(parent: self, index: index)
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
internal extension Content {
    
    func popover(parent: UnwrappedView, index: Int?) throws -> InspectableView<ViewType.Popover> {
        guard let popoverBuilder = try? self.modifierAttribute(
            modifierLookup: { isPopoverBuilder(modifier: $0) }, path: "modifier",
            type: PopoverBuilder.self, call: "", index: index ?? 0)
        else {
            _ = try modifierAttribute(
                modifierName: "PopoverPresentationModifier", path: "modifier",
                type: Any.self, call: "popover")
            throw InspectionError.notSupported(
                """
                Please refer to the Guide for inspecting the Popover: \
                https://github.com/nalexn/ViewInspector/blob/master/guide.md#alert-sheet-actionsheet-and-fullscreencover
                """)
        }
        let view = try popoverBuilder.buildPopover()
        let container = ViewType.Popover.Container(view: view, builder: popoverBuilder)
        let medium = self.medium.resettingViewModifiers()
        let content = Content(container, medium: medium)
        let call = ViewType.inspectionCall(
            base: ViewType.Popover.inspectionCall(typeName: ""), index: index)
        return try .init(content, parent: parent, call: call, index: index)
    }
    
    func popoversForSearch() -> [ViewSearch.ModifierIdentity] {
        let count = medium.viewModifiers
            .filter { isPopoverBuilder(modifier: $0) }
            .count
        return Array(0..<count).map { _ in
            .init(name: "", builder: { parent, index in
                try parent.content.popover(parent: parent, index: index)
            })
        }
    }
    
    private func isPopoverBuilder(modifier: Any) -> Bool {
        return (try? Inspector.attribute(
            label: "modifier", value: modifier, type: PopoverBuilder.self)) != nil
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
internal extension ViewType.Popover {
    struct Container: CustomViewIdentityMapping {
        let view: Any
        let builder: PopoverBuilder
        
        var viewTypeForSearch: KnownViewType.Type { ViewType.Popover.self }
    }
}

@available(iOS 13.0, macOS 10.15, *)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
public protocol PopoverBuilder: SystemPopupPresenter {
    var attachmentAnchor: PopoverAttachmentAnchor { get }
    var arrowEdge: Edge { get }
    func buildPopover() throws -> Any
}

@available(iOS 13.0, macOS 10.15, *)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
public protocol PopoverProvider: PopoverBuilder {
    var isPresented: Binding<Bool> { get }
    var popoverBuilder: () -> Any { get }
}

@available(iOS 13.0, macOS 10.15, *)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
public protocol PopoverItemProvider: PopoverBuilder {
    associatedtype Item: Identifiable
    var item: Binding<Item?> { get }
    var popoverBuilder: (Item) -> Any { get }
}

@available(iOS 13.0, macOS 10.15, *)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
public extension PopoverProvider {
    
    func buildPopover() throws -> Any {
        guard isPresented.wrappedValue else {
            throw InspectionError.viewNotFound(parent: "Popover")
        }
        return popoverBuilder()
    }
    
    func dismissPopup() {
        isPresented.wrappedValue = false
    }
}

@available(iOS 13.0, macOS 10.15, *)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
public extension PopoverItemProvider {
    
    func buildPopover() throws -> Any {
        guard let value = item.wrappedValue else {
            throw InspectionError.viewNotFound(parent: "Popover")
        }
        return popoverBuilder(value)
    }
    
    func dismissPopup() {
        item.wrappedValue = nil
    }
}

// MARK: - Custom Attributes

@available(iOS 13.0, macOS 10.15, *)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
public extension InspectableView where View == ViewType.Popover {
    
    func callOnDismiss() throws {
        let popover = try Inspector.cast(value: content.view, type: ViewType.Popover.Container.self)
        popover.builder.dismissPopup()
    }
    
    func arrowEdge() throws -> Edge {
        let popover = try Inspector.cast(value: content.view, type: ViewType.Popover.Container.self)
        return popover.builder.arrowEdge
    }
    
    func attachmentAnchor() throws -> PopoverAttachmentAnchor {
        let popover = try Inspector.cast(value: content.view, type: ViewType.Popover.Container.self)
        return popover.builder.attachmentAnchor
    }
}

// MARK: - Deprecated:

@available(iOS 13.0, macOS 10.15, *)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
public extension InspectableView where View == ViewType.Popover {
    
    @available(*, deprecated, message: "Simply remove `contentView()` from the inspection chain")
    func contentView() throws -> InspectableView<ViewType.ClassifiedView> {
        return try contentView(EmptyView.self)
    }
    
    @available(*, deprecated, message: "Simply remove `contentView()` from the inspection chain")
    func contentView<T>(_ viewType: T.Type) throws -> InspectableView<ViewType.ClassifiedView> {
        let content = try ViewType.Popover.child(self.content)
        return try .init(content, parent: self, index: nil)
    }
    
    @available(*, deprecated, message: "Use `popover` inspection call - it throws if Popover is not presented")
    func isPresented() throws -> Bool {
        return true
    }
    
    @available(*, deprecated, renamed: "callOnDismiss")
    func dismiss() throws {
        try callOnDismiss()
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension PopoverAttachmentAnchor: Equatable {
    public static func == (lhs: PopoverAttachmentAnchor, rhs: PopoverAttachmentAnchor) -> Bool {
        switch (lhs, rhs) {
        case let (.rect(lhsAnchor), .rect(rhsAnchor)):
            return lhsAnchor == rhsAnchor
        case let (.point(lhsPoint), .point(rhsPoint)):
            return lhsPoint == rhsPoint
        default:
            return false
        }
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension Anchor.Source: Equatable where Value == CGRect {
    public static func == (lhs: Anchor<Value>.Source, rhs: Anchor<Value>.Source) -> Bool {
        return String(describing: lhs) == String(describing: rhs)
    }
}
