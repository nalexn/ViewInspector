import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension ViewType {
    
    struct Popover: KnownViewType {
        public static var typePrefix: String = ViewType.PopupContainer<Popover>.typePrefix
        public static var namespacedPrefixes: [String] { [typePrefix] }
        public static func inspectionCall(typeName: String) -> String {
            return "popover(\(ViewType.indexPlaceholder))"
        }
        internal static var standardModifierName: String {
            if #available(iOS 14.2, macOS 11.0, *) {
                return "PopoverPresentationModifier"
            } else {
                return "_AnchorWritingModifier<Optional<CGRect>, Key>"
            }
        }
    }
}

// MARK: - Content Extraction

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension ViewType.Popover: SingleViewContent {
    
    public static func child(_ content: Content) throws -> Content {
        let view = try Inspector.attribute(label: "popup", value: content.view)
        let medium = content.medium.resettingViewModifiers()
        return try Inspector.unwrap(view: view, medium: medium)
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension ViewType.Popover: MultipleViewContent {
    
    public static func children(_ content: Content) throws -> LazyGroup<Content> {
        let view = try Inspector.attribute(label: "popup", value: content.view)
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
        return try popup(parent: parent, index: index,
                         modifierPredicate: isPopoverBuilder(modifier:),
                         standardPredicate: standardPopoverModifier)
    }
    
    func standardPopoverModifier(_ name: String = "Popover") throws -> Any {
        return try modifierAttribute(
            modifierName: ViewType.Popover.standardModifierName, path: "modifier",
            type: Any.self, call: name.firstLetterLowercased)
    }
    
    func popoversForSearch() -> [ViewSearch.ModifierIdentity] {
        let count = medium.viewModifiers
            .filter(isPopoverBuilder(modifier:))
            .count
        return Array(0..<count).map { _ in
            .init(name: "", builder: { parent, index in
                try parent.content.popover(parent: parent, index: index)
            })
        }
    }
    
    private func isPopoverBuilder(modifier: Any) -> Bool {
        let modifier = try? Inspector.attribute(
            label: "modifier", value: modifier, type: BasePopupPresenter.self)
        return modifier?.isPopoverPresenter == true
    }
}

// MARK: - Custom Attributes

@available(iOS 14.2, macOS 11.0, *)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
public extension InspectableView where View == ViewType.Popover {
    
    func arrowEdge() throws -> Edge {
        let popover = try Inspector.cast(value: content.view, type: ViewType.PopupContainer<ViewType.Popover>.self)
        let modifier = try popover.presenter.content().standardPopoverModifier()
        return try Inspector.attribute(
            label: "arrowEdge", value: modifier, type: Edge.self)
    }
    
    func attachmentAnchor() throws -> PopoverAttachmentAnchor {
        let popover = try Inspector.cast(value: content.view, type: ViewType.PopupContainer<ViewType.Popover>.self)
        let modifier = try popover.presenter.content().standardPopoverModifier()
        return try Inspector.attribute(
            label: "attachmentAnchor", value: modifier, type: PopoverAttachmentAnchor.self)
    }
}

@available(iOS 13.0, macOS 10.15, *)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
public extension InspectableView where View == ViewType.Popover {
    
    func dismiss() throws {
        let container = try Inspector.cast(value: content.view, type: ViewType.PopupContainer<ViewType.Popover>.self)
        container.presenter.dismissPopup()
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
