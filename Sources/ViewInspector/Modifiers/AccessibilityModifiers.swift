import SwiftUI

// MARK: - Accessibility

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView {
    
    func accessibilityLabel() throws -> InspectableView<ViewType.Text> {
        let text = try accessibilityElement(
            "LabelKey", type: Text.self, call: "accessibilityLabel")
        let medium = content.medium.resettingViewModifiers()
        return try .init(try Inspector.unwrap(content: Content(text, medium: medium)), parent: self)
    }
    
    func accessibilityValue() throws -> InspectableView<ViewType.Text> {
        let text = try accessibilityElement(
            "TypedValueKey", path: "value|some|description|some",
            type: Text.self, call: "accessibilityValue")
        let medium = content.medium.resettingViewModifiers()
        return try .init(try Inspector.unwrap(content: Content(text, medium: medium)), parent: self)
    }
    
    func accessibilityHint() throws -> InspectableView<ViewType.Text> {
        let text = try accessibilityElement(
            "HintKey", type: Text.self, call: "accessibilityHint")
        let medium = content.medium.resettingViewModifiers()
        return try .init(try Inspector.unwrap(content: Content(text, medium: medium)), parent: self)
    }
    
    func accessibilityHidden() throws -> Bool {
        let visibility = try accessibilityElement(
            "VisibilityKey", path: "value", type: (Any?).self, call: "accessibility(hidden:)")
        switch visibility {
        case let .some(value):
            return String(describing: value) == "hidden"
        case .none:
            return false
        }
    }
    
    func accessibilityIdentifier() throws -> String {
        return try accessibilityElement(
            "IdentifierKey", type: String.self, call: "accessibility(identifier:)")
    }
    
    func accessibilitySelectionIdentifier() throws -> AnyHashable {
        return try accessibilityElement(
            "SelectionIdentifierKey", type: AnyHashable.self,
            call: "accessibility(selectionIdentifier:)")
    }
    
    func accessibilityActivationPoint() throws -> UnitPoint {
        return try accessibilityElement(
            "ActivationPointKey", path: "value|some|unitPoint",
            type: UnitPoint.self, call: "accessibility(activationPoint:)")
    }
    
    func callAccessibilityAction(_ kind: AccessibilityActionKind) throws {
        let kindString = String(describing: kind)
        let shortName = kindString
            .components(separatedBy: CharacterSet(charactersIn: ".)"))
            .filter { $0.count > 0 }.last!
        let call = "accessibilityAction(.\(shortName))"
        typealias Callback = (()) -> Void
        let callback = try accessibilityAction(name: kindString, path: "box|action|kind",
                                               type: Callback.self, call: call)
        callback(())
    }
    
    func callAccessibilityAdjustableAction(_ direction: AccessibilityAdjustmentDirection = .increment) throws {
        typealias Callback = (AccessibilityAdjustmentDirection) -> Void
        let callback = try accessibilityAction(
            name: "AccessibilityAdjustableAction()", path: "box|action",
            type: Callback.self, call: "accessibilityAdjustableAction")
        callback(direction)
    }
    
    func callAccessibilityScrollAction(_ edge: Edge) throws {
        typealias Callback = (Edge) -> Void
        let callback = try accessibilityAction(
            name: "AccessibilityScrollAction()", path: "box|action",
            type: Callback.self, call: "accessibilityScrollAction")
        callback(edge)
    }
    
    func accessibilitySortPriority() throws -> Double {
        return try accessibilityElement(
            "SortPriorityKey", type: Double.self, call: "accessibility(sortPriority:)")
    }
}

// MARK: - Private

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
private extension InspectableView {
    
    func accessibilityElement<T>(_ name: String, path: String = "value|some",
                                 type: T.Type, call: String) throws -> T {
        let item = try modifierAttribute(
            modifierName: "AccessibilityAttachmentModifier",
            path: "modifier|attachment|some|properties|plist|elements|some",
            type: Any.self, call: call)
        guard let attribute = lookupAttributeWithName(name, item: item),
            let value = try? Inspector.attribute(path: path, value: attribute) as? T else {
            throw InspectionError.modifierNotFound(parent:
                Inspector.typeName(value: content.view), modifier: call)
        }
        return value
    }
    
    func lookupAttributeWithName(_ name: String, item: Any) -> Any? {
        if Inspector.typeName(value: item).contains(name) {
            return item
        }
        if let nextItem = try? Inspector.attribute(path: "super|after|some", value: item) {
            return lookupAttributeWithName(name, item: nextItem)
        }
        return nil
    }
    
    func accessibilityAction<T>(name: String, path: String, type: T.Type, call: String) throws -> T {
        let actionHandlers = try accessibilityElement(
            "ActionsKey", path: "value",
            type: [Any].self, call: call)
        guard let handler = actionHandlers.first(where: { handler -> Bool in
            guard let actionName = try? Inspector.attribute(path: path, value: handler)
                else { return false }
            return name == String(describing: actionName)
        }), let callback = try? Inspector.attribute(path: "box|handler", value: handler) as? T
        else {
            throw InspectionError.modifierNotFound(parent:
                Inspector.typeName(value: content.view), modifier: call)
        }
        return callback
    }
}
