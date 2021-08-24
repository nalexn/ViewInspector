import SwiftUI

// MARK: - Accessibility

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView {
    
    func accessibilityLabel() throws -> InspectableView<ViewType.Text> {
        let text: Text
        if #available(iOS 15.0, tvOS 15.0, *) {
            text = try v3AccessibilityElement(
                type: Text.self, call: "accessibilityLabel", { $0.accessibilityLabel("") })
        } else {
            text = try v2AccessibilityElement(
                "LabelKey", type: Text.self, call: "accessibilityLabel")
        }
        let medium = content.medium.resettingViewModifiers()
        return try .init(try Inspector.unwrap(content: Content(text, medium: medium)), parent: self)
    }
    
    func accessibilityValue() throws -> InspectableView<ViewType.Text> {
        let text: Text
        if #available(iOS 15.0, tvOS 15.0, *) {
            text = try v3AccessibilityElement(
                path: "some|description|some", type: Text.self,
                call: "accessibilityValue", { $0.accessibilityValue("") })
        } else {
            text = try v2AccessibilityElement(
            "TypedValueKey", path: "value|some|description|some",
            type: Text.self, call: "accessibilityValue")
        }
        let medium = content.medium.resettingViewModifiers()
        return try .init(try Inspector.unwrap(content: Content(text, medium: medium)), parent: self)
    }
    
    func accessibilityHint() throws -> InspectableView<ViewType.Text> {
        let text: Text
        if #available(iOS 15.0, tvOS 15.0, *) {
            text = try v3AccessibilityElement(
                type: Text.self, call: "accessibilityHint", { $0.accessibilityHint("") })
        } else {
            text = try v2AccessibilityElement(
            "HintKey", type: Text.self, call: "accessibilityHint")
        }
        let medium = content.medium.resettingViewModifiers()
        return try .init(try Inspector.unwrap(content: Content(text, medium: medium)), parent: self)
    }
    
    func accessibilityHidden() throws -> Bool {
        let visibility = try v2AccessibilityElement(
            "VisibilityKey", path: "value", type: (Any?).self, call: "accessibility(hidden:)")
        switch visibility {
        case let .some(value):
            return String(describing: value) == "hidden"
        case .none:
            return false
        }
    }
    
    func accessibilityIdentifier() throws -> String {
        return try v2AccessibilityElement(
            "IdentifierKey", type: String.self, call: "accessibility(identifier:)")
    }
    
    func accessibilitySelectionIdentifier() throws -> AnyHashable {
        return try v2AccessibilityElement(
            "SelectionIdentifierKey", type: AnyHashable.self,
            call: "accessibility(selectionIdentifier:)")
    }
    
    func accessibilityActivationPoint() throws -> UnitPoint {
        return try v2AccessibilityElement(
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
        let callback = try v2AccessibilityAction(name: kindString, path: "box|action|kind",
                                               type: Callback.self, call: call)
        callback(())
    }
    
    func callAccessibilityAdjustableAction(_ direction: AccessibilityAdjustmentDirection = .increment) throws {
        typealias Callback = (AccessibilityAdjustmentDirection) -> Void
        let callback = try v2AccessibilityAction(
            name: "AccessibilityAdjustableAction()", path: "box|action",
            type: Callback.self, call: "accessibilityAdjustableAction")
        callback(direction)
    }
    
    func callAccessibilityScrollAction(_ edge: Edge) throws {
        typealias Callback = (Edge) -> Void
        let callback = try v2AccessibilityAction(
            name: "AccessibilityScrollAction()", path: "box|action",
            type: Callback.self, call: "accessibilityScrollAction")
        callback(edge)
    }
    
    func accessibilitySortPriority() throws -> Double {
        return try v2AccessibilityElement(
            "SortPriorityKey", type: Double.self, call: "accessibility(sortPriority:)")
    }
}

// MARK: - Private

@available(iOS 15.0, tvOS 15.0, macOS 10.15, *)
private struct AccessibilityProperty {
    
    let keyPointerValue: UInt64
    let value: Any
    
    init(property: Any) throws {
        self.keyPointerValue = try Inspector.attribute(
            path: "super|key|rawValue|pointerValue", value: property, type: UInt64.self)
        self.value = try Inspector.attribute(path: "super|value", value: property)
    }
    
    static var noisePointerValues: Set<UInt64> = {
        let view1 = EmptyView().accessibilityLabel(Text(""))
        let view2 = EmptyView().accessibilityHint(Text(""))
        do {
            let props1 = try view1.inspect()
                .v3AccessibilityProperties(call: "")
                .map { $0.keyPointerValue }
            let props2 = try view2.inspect()
                .v3AccessibilityProperties(call: "")
                .map { $0.keyPointerValue }
            return Set(props1).intersection(Set(props2))
        } catch { return .init() }
    }()
}

@available(iOS 15.0, tvOS 15.0, macOS 10.15, *)
private extension InspectableView {
    func v3AccessibilityElement<V, T>(
        path: String? = nil, type: T.Type, call: String, _ reference: (EmptyView) -> V
    ) throws -> T where V: SwiftUI.View {
        let noiseValues = AccessibilityProperty.noisePointerValues
        guard let referenceValue = try reference(EmptyView()).inspect()
                .v3AccessibilityProperties(call: call)
                .map({ $0.keyPointerValue })
                .first(where: { !noiseValues.contains($0) }),
              let property = try v3AccessibilityProperties(call: call)
                .first(where: { $0.keyPointerValue == referenceValue })
        else {
            throw InspectionError
                .modifierNotFound(parent: Inspector.typeName(value: content.view),
                                  modifier: call, index: 0)
        }
        if let path = path {
            return try Inspector.attribute(path: path, value: property.value, type: T.self)
        } else {
            return try Inspector.cast(value: property.value, type: T.self)
        }
    }
    
    func v3AccessibilityProperties(call: String) throws -> [AccessibilityProperty] {
        return try modifierAttribute(
            modifierName: "AccessibilityAttachmentModifier",
            path: "modifier|storage|propertiesComponent",
            type: [Any].self, call: call)
            .map { try AccessibilityProperty(property: $0) }
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
private extension InspectableView {
    
    func v2AccessibilityElement<T>(_ name: String, path: String = "value|some",
                                   type: T.Type, call: String) throws -> T {
        let item = try modifierAttribute(
            modifierName: "AccessibilityAttachmentModifier",
            path: "modifier|attachment|some|properties|plist|elements|some",
            type: Any.self, call: call)
        guard let attribute = v2LookupAttributeWithName(name, item: item),
            let value = try? Inspector.attribute(path: path, value: attribute) as? T else {
            throw InspectionError.modifierNotFound(parent:
                Inspector.typeName(value: content.view), modifier: call, index: 0)
        }
        return value
    }
    
    func v2LookupAttributeWithName(_ name: String, item: Any) -> Any? {
        if Inspector.typeName(value: item).contains(name) {
            return item
        }
        if let nextItem = try? Inspector.attribute(path: "super|after|some", value: item) {
            return v2LookupAttributeWithName(name, item: nextItem)
        }
        return nil
    }
    
    func v2AccessibilityAction<T>(name: String, path: String, type: T.Type, call: String) throws -> T {
        let actionHandlers = try v2AccessibilityElement(
            "ActionsKey", path: "value",
            type: [Any].self, call: call)
        guard let handler = actionHandlers.first(where: { handler -> Bool in
            guard let actionName = try? Inspector.attribute(path: path, value: handler)
                else { return false }
            return name == String(describing: actionName)
        }), let callback = try? Inspector.attribute(path: "box|handler", value: handler) as? T
        else {
            throw InspectionError.modifierNotFound(parent:
                Inspector.typeName(value: content.view), modifier: call, index: 0)
        }
        return callback
    }
}
