import SwiftUI

// MARK: - Accessibility

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView {
    
    func accessibilityLabel() throws -> InspectableView<ViewType.Text> {
        let text: Text
        let call = "accessibilityLabel"
        if #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *) {
            text = try v3AccessibilityElement(
                path: "some|text", type: Text.self,
                call: call, { $0.accessibilityLabel("") })
        } else if #available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *) {
            text = try v3AccessibilityElement(
                type: Text.self, call: call, { $0.accessibilityLabel("") })
        } else {
            text = try v2AccessibilityElement("LabelKey", type: Text.self, call: call)
        }
        let medium = content.medium.resettingViewModifiers()
        return try .init(try Inspector.unwrap(content: Content(text, medium: medium)), parent: self)
    }
    
    func accessibilityValue() throws -> InspectableView<ViewType.Text> {
        let text: Text
        let call = "accessibilityValue"
        if #available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *) {
            text = try v3AccessibilityElement(
                path: "some|description|some", type: Text.self,
                call: call, { $0.accessibilityValue("") })
        } else {
            text = try v2AccessibilityElement(
            "TypedValueKey", path: "value|some|description|some", type: Text.self, call: call)
        }
        let medium = content.medium.resettingViewModifiers()
        return try .init(try Inspector.unwrap(content: Content(text, medium: medium)), parent: self)
    }
    
    func accessibilityHint() throws -> InspectableView<ViewType.Text> {
        let text: Text
        let call = "accessibilityHint"
        if #available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *) {
            text = try v3AccessibilityElement(
                type: Text.self, call: call, { $0.accessibilityHint("") })
        } else {
            text = try v2AccessibilityElement("HintKey", type: Text.self, call: call)
        }
        let medium = content.medium.resettingViewModifiers()
        return try .init(try Inspector.unwrap(content: Content(text, medium: medium)), parent: self)
    }
    
    func accessibilityHidden() throws -> Bool {
        let call = "accessibilityHidden"
        if #available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *) {
            let value = try v3AccessibilityElement(
                path: "value|rawValue", type: UInt32.self,
                call: call, { $0.accessibilityHidden(true) })
            return value != 0
        } else {
            let visibility = try v2AccessibilityElement(
                "VisibilityKey", path: "value", type: (Any?).self, call: call)
            switch visibility {
            case let .some(value):
                return String(describing: value) == "hidden"
            case .none:
                return false
            }
        }
    }
    
    func accessibilityIdentifier() throws -> String {
        let call = "accessibilityIdentifier"
        if #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *) {
            return try v3AccessibilityElement(
                path: "some|rawValue", type: String.self,
                call: call, { $0.accessibilityIdentifier("") })
        } else if #available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *) {
            return try v3AccessibilityElement(
                type: String.self, call: call, { $0.accessibilityIdentifier("") })
        } else {
            return try v2AccessibilityElement("IdentifierKey", type: String.self, call: call)
        }
    }
    
    func accessibilitySortPriority() throws -> Double {
        let call = "accessibilitySortPriority"
        if #available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *) {
            return try v3AccessibilityElement(
                type: Double.self, call: call, { $0.accessibilitySortPriority(0) })
        } else {
            return try v2AccessibilityElement("SortPriorityKey", type: Double.self, call: call)
        }
    }
    
    @available(iOS, deprecated, introduced: 13.0)
    @available(macOS, deprecated, introduced: 10.15)
    @available(tvOS, deprecated, introduced: 13.0)
    @available(watchOS, deprecated, introduced: 6)
    func accessibilitySelectionIdentifier() throws -> AnyHashable {
        return try v2AccessibilityElement(
            "SelectionIdentifierKey", type: AnyHashable.self,
            call: "accessibility(selectionIdentifier:)")
    }
    
    func accessibilityActivationPoint() throws -> UnitPoint {
        if #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *) {
            return try v3AccessibilityElement(
                path: "some|activate|some|unitPoint", type: UnitPoint.self,
                call: "accessibilityIdentifier", { $0.accessibilityActivationPoint(.center) })
        } else if #available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *) {
            return try v3AccessibilityElement(
                path: "some|unitPoint", type: UnitPoint.self,
                call: "accessibilityIdentifier", { $0.accessibilityActivationPoint(.center) })
        } else {
            return try v2AccessibilityElement(
            "ActivationPointKey", path: "value|some|unitPoint",
            type: UnitPoint.self, call: "accessibility(activationPoint:)")
        }
    }
    
    func callAccessibilityAction<S>(_ named: S) throws where S: StringProtocol {
        try callAccessibilityAction(AccessibilityActionKind(named: Text(named)))
    }
    
    func callAccessibilityAction(_ kind: AccessibilityActionKind) throws {
        let shortName: String = {
            if let name = try? kind.name().string() {
                return "named: \"\(name)\""
            }
            return "." + String(describing: kind)
                .components(separatedBy: CharacterSet(charactersIn: ".)"))
                .filter { $0.count > 0 }.last!
        }()
        let call = "accessibilityAction(\(shortName))"
        typealias Callback = (()) -> Void
        let callback: Callback
        if #available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *) {
            callback = try v3AccessibilityAction(kind: kind, type: Callback.self, call: call)
        } else {
            callback = try v2AccessibilityAction(kind: kind, type: Callback.self, call: call)
        }
        callback(())
    }
    
    func callAccessibilityAdjustableAction(_ direction: AccessibilityAdjustmentDirection = .increment) throws {
        typealias Callback = (AccessibilityAdjustmentDirection) -> Void
        let callback: Callback
        if #available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *) {
            callback = try v3AccessibilityAction(
                name: "AccessibilityAdjustableAction",
                type: Callback.self,
                call: "accessibilityAdjustableAction")
        } else {
            callback = try v2AccessibilityAction(
                name: "AccessibilityAdjustableAction()",
                type: Callback.self,
                call: "accessibilityAdjustableAction")
        }
        callback(direction)
    }
    
    func callAccessibilityScrollAction(_ edge: Edge) throws {
        typealias Callback = (Edge) -> Void
        let callback: Callback
        if #available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *) {
            callback = try v3AccessibilityAction(
                name: "AccessibilityScrollAction",
                type: Callback.self,
                call: "accessibilityScrollAction")
        } else {
            callback = try v2AccessibilityAction(
                name: "AccessibilityScrollAction()",
                type: Callback.self,
                call: "accessibilityScrollAction")
        }
        callback(edge)
    }
}

// MARK: - Private

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
private extension AccessibilityActionKind {
    func name() throws -> InspectableView<ViewType.Text> {
        let view: Any = try {
            if let view = try? Inspector.attribute(path: "kind|named", value: self) {
                return view
            }
            return try Inspector.attribute(path: "kind|custom", value: self)
        }()
        return try .init(Content(view), parent: nil, index: nil)
    }
    
    func isEqual(to other: AccessibilityActionKind) -> Bool {
        if let lhsName = try? self.name().string(),
           let rhsName = try? other.name().string() {
            return lhsName == rhsName
        }
        return self == other
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
private struct AccessibilityProperty {
    
    let keyPointerValue: UInt64
    let value: Any
    
    init(property: Any) throws {
        self.keyPointerValue = try Inspector.attribute(
            path: "super|key|rawValue|pointerValue", value: property, type: UInt64.self)
        self.value = try Inspector.attribute(path: "super|value", value: property)
    }
    
    init(key: UInt64, value: Any) throws {
        self.keyPointerValue = key
        self.value = try Inspector.attribute(path: "typedValue", value: value)
    }
    
    static var noisePointerValues: Set<UInt64> = {
        let view1 = EmptyView().accessibility(label: Text(""))
        let view2 = EmptyView().accessibility(hint: Text(""))
        do {
            let props1 = try view1.inspect()
                .v3v4AccessibilityProperties(call: "")
                .map { $0.keyPointerValue }
            let props2 = try view2.inspect()
                .v3v4AccessibilityProperties(call: "")
                .map { $0.keyPointerValue }
            return Set(props1).intersection(Set(props2))
        } catch { return .init() }
    }()
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
private extension InspectableView {
    func v3AccessibilityElement<V, T>(
        path: String? = nil, type: T.Type, call: String, _ reference: (EmptyView) -> V
    ) throws -> T where V: SwiftUI.View {
        let noiseValues = AccessibilityProperty.noisePointerValues
        guard let referenceValue = try reference(EmptyView()).inspect()
                .v3v4AccessibilityProperties(call: call)
                .map({ $0.keyPointerValue })
                .first(where: { !noiseValues.contains($0) }),
              let property = try v3v4AccessibilityProperties(call: call)
                .first(where: { $0.keyPointerValue == referenceValue })
        else {
            throw InspectionError
                .modifierNotFound(parent: Inspector.typeName(value: content.view),
                                  modifier: call, index: 0)
        }
        if let path = path {
            return try Inspector.attribute(path: path, value: property.value, type: T.self)
        }
        return try Inspector.cast(value: property.value, type: T.self)
    }
    
    func v3AccessibilityAction<T>(kind: AccessibilityActionKind, type: T.Type, call: String) throws -> T {
        return try v3AccessibilityAction(trait: { action in
            try Inspector.attribute(
                path: "action|kind", value: action, type: AccessibilityActionKind.self)
                .isEqual(to: kind)
        }, type: type, call: call)
    }
    
    func v3AccessibilityAction<T>(name: String, type: T.Type, call: String) throws -> T {
        return try v3AccessibilityAction(trait: { action in
            Inspector.typeName(value: action).contains(name)
        }, type: type, call: call)
    }
    
    func v3AccessibilityAction<T>(trait: (Any) throws -> Bool, type: T.Type, call: String) throws -> T {
        let actions = try v3AccessibilityActions(call: call)
        guard let action = actions.first(where: { (try? trait($0)) == true }) else {
            throw InspectionError
                .modifierNotFound(parent: Inspector.typeName(value: content.view),
                                  modifier: call, index: 0)
        }
        if #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *) {
            throw InspectionError.notSupported(
                """
                Accessibility actions are currently unavailable for \
                inspection on iOS 16. Situation may change with a minor \
                OS version update. In the meanwhile, please add XCTSkip \
                for iOS 16 and use an earlier OS version for testing.
                """)
        }
        return try Inspector.attribute(label: "handler", value: action, type: T.self)
    }
    
    func v3AccessibilityActions(call: String) throws -> [Any] {
        let noiseValues = AccessibilityProperty.noisePointerValues
        guard let referenceValue = try EmptyView().accessibilityAction(.default, { })
                .inspect()
                .v3v4AccessibilityProperties(call: call)
                .map({ $0.keyPointerValue })
                .first(where: { !noiseValues.contains($0) })
        else {
            throw InspectionError
                .modifierNotFound(parent: Inspector.typeName(value: content.view),
                                  modifier: call, index: 0)
        }
        return try v3v4AccessibilityProperties(call: call)
          .filter({ $0.keyPointerValue == referenceValue })
          .compactMap { $0.value as? [Any] }
          .flatMap { $0 }
          .map { try Inspector.attribute(path: "base|base", value: $0) }
    }
    
    func v3v4AccessibilityProperties(call: String) throws -> [AccessibilityProperty] {
        if #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *) {
            return try modifierAttribute(
                modifierName: "AccessibilityAttachmentModifier",
                path: "modifier|storage|value|properties|storage",
                type: AccessibilityKeyValues.self, call: call)
                .accessibilityKeyValues()
                .map { try AccessibilityProperty(key: $0.key, value: $0.value) }
        } else {
            return try modifierAttribute(
                modifierName: "AccessibilityAttachmentModifier",
                path: "modifier|storage|propertiesComponent",
                type: [Any].self, call: call)
                .map { try AccessibilityProperty(property: $0) }
        }
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
protocol AccessibilityKeyValues {
    func accessibilityKeyValues() throws -> [(key: UInt64, value: Any)]
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension Dictionary: AccessibilityKeyValues {
    func accessibilityKeyValues() throws -> [(key: UInt64, value: Any)] {
        return try self.keys.compactMap { key -> (key: UInt64, value: Any)? in
            guard let value = self[key] else { return nil }
            if let key = key as? ObjectIdentifier {
                return (key: UInt64(abs(key.hashValue)), value: value as Any)
            } else {
                let keyPointerValue = try Inspector.attribute(
                    path: "rawValue|pointerValue", value: key, type: UInt64.self)
                return (key: keyPointerValue, value: value as Any)
            }
        }
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

    func v2AccessibilityAction<T>(kind: AccessibilityActionKind, type: T.Type, call: String) throws -> T {
        return try v2AccessibilityAction(type: type, call: call, trait: { handler in
            try Inspector.attribute(path: "box|action|kind", value: handler, type: AccessibilityActionKind.self)
                .isEqual(to: kind)
        })
    }
    func v2AccessibilityAction<T>(name: String, type: T.Type, call: String) throws -> T {
        return try v2AccessibilityAction(type: type, call: call, trait: { handler in
            let actionName = try Inspector.attribute(path: "box|action", value: handler)
            return name == String(describing: actionName)
        })
    }
    
    func v2AccessibilityAction<T>(type: T.Type, call: String, trait: (Any) throws -> Bool) throws -> T {
        let actionHandlers = try v2AccessibilityElement(
            "ActionsKey", path: "value",
            type: [Any].self, call: call)
        guard let handler = actionHandlers.first(where: { (try? trait($0)) == true }),
            let callback = try? Inspector.attribute(path: "box|handler", value: handler) as? T
        else {
            throw InspectionError.modifierNotFound(parent:
                Inspector.typeName(value: content.view), modifier: call, index: 0)
        }
        return callback
    }
}
