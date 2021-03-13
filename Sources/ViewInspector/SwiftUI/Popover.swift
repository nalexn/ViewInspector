import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension ViewType {
    
    struct Popover: KnownViewType {
        public static var typePrefix: String = ""
    }
}

// MARK: - Extraction

@available(iOS 14.2, macOS 11.0, *)
@available(tvOS, unavailable)
public extension InspectableView {
    
    func popover() throws -> InspectableView<ViewType.Popover> {
        return try contentForModifierLookup.popover(parent: self)
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
internal extension Content {
    
    func popover(parent: UnwrappedView) throws -> InspectableView<ViewType.Popover> {
        let modifier = try modifierAttribute(
            modifierName: "PopoverPresentationModifier", path: "modifier",
            type: Any.self, call: "popover")
        let medium = self.medium.resettingViewModifiers()
        return try .init(try Inspector.unwrap(content: Content(modifier, medium: medium)),
                         parent: parent, call: "popover()")
    }
}

// MARK: - Custom Attributes

@available(iOS 14.2, macOS 11.0, *)
@available(tvOS, unavailable)
public extension InspectableView where View == ViewType.Popover {
    
    func contentView() throws -> InspectableView<ViewType.ClassifiedView> {
        return try contentView(EmptyView.self)
    }
    
    func contentView<T>(_ viewType: T.Type) throws -> InspectableView<ViewType.ClassifiedView> {
        
        typealias Closure = () -> T
        let closure = try Inspector.attribute(label: "popoverContent", value: content.view)
        let closureDesc = Inspector.typeName(value: closure)
        
        let expectedViewType = closureDesc.components(separatedBy: "() -> ").last ?? ""
        guard Inspector.typeName(type: viewType) == expectedViewType else {
            throw InspectionError.notSupported(
                "Please substitute '\(expectedViewType).self' as the parameter for 'contentView()' inspection call")
        }
        guard let typedClosure = withUnsafeBytes(of: closure, {
            $0.bindMemory(to: Closure.self).first
        }) else { throw InspectionError.typeMismatch(closure, Closure.self) }
        let view = typedClosure()
        let medium = content.medium.resettingViewModifiers()
        return try .init(try Inspector.unwrap(content: Content(view, medium: medium)), parent: self)
    }
    
    func arrowEdge() throws -> Edge {
        return try Inspector.attribute(label: "arrowEdge", value: content.view, type: Edge.self)
    }
    
    func attachmentAnchor() throws -> PopoverAttachmentAnchor {
        return try Inspector.attribute(label: "attachmentAnchor", value: content.view,
                                       type: PopoverAttachmentAnchor.self)
    }
    
    func isPresented() throws -> Bool {
        return try isPresentedBinding().wrappedValue
    }
    
    func dismiss() throws {
        typealias OnDismiss = () -> Void
        let onDismiss = try Inspector.attribute(
            label: "onDismiss", value: content.view, type: OnDismiss.self)
        onDismiss()
        try isPresentedBinding().wrappedValue = false
    }
    
    private func isPresentedBinding() throws -> Binding<Bool> {
        return try Inspector.attribute(
            label: "_isPresented", value: content.view, type: Binding<Bool>.self)
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
