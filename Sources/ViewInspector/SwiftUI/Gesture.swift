import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public protocol GestureViewType {
    associatedtype T: SwiftUI.Gesture
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension ViewType {
    
    struct Gesture<T>: KnownViewType, GestureViewType
    where T: SwiftUI.Gesture {
        public static var typePrefix: String {
            return Inspector.typeName(type: T.self, generics: .remove)
        }
        
        public static var namespacedPrefixes: [String] {
            var prefixes = [
                "AddGestureModifier",
                "HighPriorityGestureModifier",
                "SimultaneousGestureModifier",
                "_ChangedGesture",
                "_EndedGesture",
                "_MapGesture",
                "_ModifiersGesture",
                "GestureStateGesture"
            ].map { String.swiftUINamespaceRegex + $0 }
            prefixes.append(Inspector.typeName(type: T.self, namespaced: true, generics: .remove))
            return prefixes
        }
        
        public static func inspectionCall(call: String, typeName: String, index: Int? = nil) -> String {
            if let index = index {
                return "\(call)(\(typeName.self).self, \(index))"
            } else {
                return "\(call)(\(typeName.self).self)"
            }
        }
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView {
    
    func gesture<T>(_ type: T.Type, _ index: Int? = nil) throws -> InspectableView<ViewType.Gesture<T>>
        where T: Gesture {
        return try gestureModifier(
            modifierName: "AddGestureModifier", path: "modifier",
            type: type, call: "gesture", index: index)
    }
    
    func highPriorityGesture<T>(_ type: T.Type, _ index: Int? = nil) throws -> InspectableView<ViewType.Gesture<T>>
        where T: Gesture {
        return try gestureModifier(
            modifierName: "HighPriorityGestureModifier", path: "modifier",
            type: type, call: "highPriorityGesture", index: index)
    }
    
    func simultaneousGesture<T>(_ type: T.Type, _ index: Int? = nil) throws -> InspectableView<ViewType.Gesture<T>>
        where T: Gesture {
        return try gestureModifier(
            modifierName: "SimultaneousGestureModifier", path: "modifier",
            type: type, call: "simultaneousGesture", index: index)
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView where View: GestureViewType {

    func first<G: Gesture>(_ type: G.Type) throws -> InspectableView<ViewType.Gesture<G>> {
        return try gestureFromComposedGesture(type, .first)
    }
    
    func second<G: Gesture>(_ type: G.Type) throws -> InspectableView<ViewType.Gesture<G>> {
        return try gestureFromComposedGesture(type, .second)
    }
    
    func gestureMask() throws -> GestureMask {
        return try Inspector.attribute(
            path: "gestureMask", value: content.view, type: GestureMask.self)
    }
    
    func callUpdating<Value, State>(
        value: Value,
        state: inout State,
        transaction: inout Transaction) throws {
        typealias Callback = (Value, inout State, inout Transaction) -> Void
        let callbacks = try gestureCallbacks(
            name: "GestureStateGesture", path: "body",
            type: Callback.self, call: "updating")
        for callback in callbacks {
            callback(value, &state, &transaction)
        }
    }
    
    func callOnChanged<Value>(value: Value) throws {
        typealias Callback = (Value) -> Void
        let callbacks = try gestureCallbacks(
            name: "_ChangedGesture", path: "_body|modifier|callbacks|changed",
            type: Callback.self, call: "onChanged")
        for callback in callbacks {
            callback(value)
        }
    }
    
    func callOnEnded<Value>(value: Value) throws {
        typealias Callback = (Value) -> Void
        let callbacks = try gestureCallbacks(
            name: "_EndedGesture", path: "_body|modifier|callbacks|ended",
            type: Callback.self, call: "onEnded")
        for callback in callbacks {
            callback(value)
        }
    }

    func actualGesture() throws -> View.T {
        let typeName = Inspector.typeName(type: View.T.self)
        let valueName = Inspector.typeName(value: content.view)
        let (_, modifiers) = gestureInfo(typeName, valueName)
        if modifiers.count > 0 {
            let path = modifiers.reduce("") { return addSegment(knownGestureModifier($1)!, to: $0) }
            return try Inspector.attribute(path: path, value: content.view, type: View.T.self)
        }
        return try Inspector.cast(value: content.view, type: View.T.self)
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView {
    
    @available(macOS 10.15, *)
    @available(iOS, unavailable)
    @available(tvOS, unavailable)
    func gestureModifiers<T>() throws -> EventModifiers
    where T: Gesture, View == ViewType.Gesture<T> {
        let typeName = Inspector.typeName(type: T.self)
        let valueName = Inspector.typeName(value: content.view)
        let (_, modifiers) = gestureInfo(typeName, valueName)
        let result = try modifiers.reduce((path: "", eventModifiers: EventModifiers())) { result, modifier in
            var eventModifiers = result.eventModifiers
            if modifier == "_ModifiersGesture" {
                let value = try Inspector.attribute(
                    path: addSegment("_body|modifier|modifiers|rawValue", to: result.path),
                    value: content.view,
                    type: Int.self)
                eventModifiers.formUnion(EventModifiers.init(rawValue: value))
            }
            return (path: addSegment(knownGestureModifier(modifier)!, to: result.path), eventModifiers: eventModifiers)
        }
        return result.eventModifiers
    }
}

// MARK: - Private

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
internal extension InspectableView {
    
    func gestureModifier<T>(
        modifierName: String,
        path: String,
        type: T.Type,
        call: String,
        index: Int? = nil) throws -> InspectableView<ViewType.Gesture<T>>
        where T: Gesture {
        let typeName = Inspector.typeName(type: type)
        let modifierCall = ViewType.Gesture<T>.inspectionCall(call: call, typeName: typeName, index: nil)
        
        let rootView = try modifierAttribute(modifierName: modifierName, path: path, type: Any.self,
                                             call: modifierCall, index: index ?? 0)
        
        let (name, _) = gestureInfo(typeName, Inspector.typeName(value: rootView))
        guard name == typeName else {
            throw InspectionError.typeMismatch(factual: name, expected: typeName)
        }

        return try InspectableView<ViewType.Gesture<T>>.init(
            Content(rootView), parent: self,
            call: ViewType.Gesture<T>.inspectionCall(call: call, typeName: typeName, index: index))
    }

    enum GestureOrder {
        case first
        case second
    }
    
    func gestureFromComposedGesture<T: Gesture>(
        _ type: T.Type,
        _ order: GestureOrder) throws -> InspectableView<ViewType.Gesture<T>> {
        let valueName = Inspector.typeName(value: content.view)
        let typeName = Inspector.typeName(type: type)
        let (name1, modifiers1) = gestureInfo(typeName, valueName)
        guard isComposedGesture(name1) else {
            throw InspectionError.typeMismatch(
                factual: name1,
                expected: "ExclusiveGesture, SequenceGesture, or SimultaneousGesture")
        }
        
        var path = modifiers1.reduce("") { addSegment(knownGestureModifier($1)!, to: $0) }
        let call: String
        switch order {
        case .first:
            path = addSegment("first", to: path)
            call = ViewType.Gesture<T>.inspectionCall(call: "first", typeName: typeName)
        case .second:
            path = addSegment("second", to: path)
            call = ViewType.Gesture<T>.inspectionCall(call: "second", typeName: typeName)
        }
        
        let rootView = try Inspector.attribute(path: path, value: content.view)
        
        let (name2, _) = gestureInfo(typeName, Inspector.typeName(value: rootView))
        let gestureTypeName = Inspector.typeName(type: type)
        guard name2 == gestureTypeName else {
            throw InspectionError.typeMismatch(factual: name2, expected: gestureTypeName)
        }
        return try .init(Inspector.unwrap(content: Content(rootView)), parent: self, call: call)
    }
    
    func gestureCallbacks<T>(
        name: String,
        path callbackPath: String,
        type: T.Type,
        call: String) throws -> [T] {
        let valueName = Inspector.typeName(value: content.view)
        let typeName = Inspector.typeName(type: type)
        let (_, modifiers) = gestureInfo(typeName, valueName)
        let result = try modifiers.reduce((path: "", callbacks: [T]())) { result, modifier in
            var callbacks = result.callbacks
            if modifier == name {
                let object = try Inspector.attribute(
                    path: addSegment(callbackPath, to: result.path),
                    value: content.view,
                    type: T.self)
                callbacks.append(object)
            }
            return (path: addSegment(knownGestureModifier(modifier)!, to: result.path), callbacks: callbacks)
        }
        
        if result.callbacks.count == 0 {
            throw InspectionError.callbackNotFound(
                parent: Inspector.typeName(value: content.view),
                callback: call)
        }
        return result.callbacks.reversed()
    }
    
    typealias GestureInfo = (name: String, modifiers: [String])
    
    func gestureInfo(_ name: String, _ valueName: String) -> GestureInfo {
        var modifiers = parseModifiers(valueName)
        return gestureInfo(name, &modifiers)
    }
    
    func gestureInfo(_ name: String, _ modifiers: inout [String]) -> GestureInfo {
        let modifier = modifiers.removeLast()
        if let gestureClass = knownGesture(modifier) {
            switch gestureClass {
            case .simple:
                return (modifier, [])
            case .composed:
                return traverseComposedGesture(modifier, name, &modifiers)
            case .state :
                return traverseStateGesture(modifier, name, &modifiers)
            }
        } else if modifier == name {
            return (modifier, [])
        } else if knownGestureModifier(modifier) != nil {
            let result = gestureInfo(name, &modifiers)
            return (result.0, [modifier] + result.1)
        }
        return (name, modifiers)
    }
    
    func parseModifiers(_ name: String) -> [String] {
        let separators = CharacterSet(charactersIn: "<>, ")
        return name
            .components(separatedBy: separators)
            .compactMap { $0 == "" ? nil : $0 }
            .reversed()
    }
    
    func traverseComposedGesture(_ modifier: String, _ name: String,
                                 _ modifiers: inout [String]) -> GestureInfo {
        let (first, _) = gestureInfo(name, &modifiers)
        let (second, _) = gestureInfo(name, &modifiers)
        return ("\(modifier)<\(first), \(second)>", [])
    }
    
    func traverseStateGesture(_ modifier: String, _ name: String,
                              _ modifiers: inout [String]) -> GestureInfo {
        let result = gestureInfo(name, &modifiers)
        _ = modifiers.popLast()
        return (result.0, [modifier] + result.1)
    }
    
    func addSegment(_ segment: String, to path: String) -> String {
        return (path == "") ? segment : path + "|" + segment
    }
    
    enum GestureClass {
        case simple
        case composed
        case state
    }
    
    func knownGesture(_ name: String) -> GestureClass? {
        let knownGestures: [String: GestureClass] = [
            "DragGesture": .simple,
            "ExclusiveGesture": .composed,
            "GestureStateGesture": .state,
            "LongPressGesture": .simple,
            "MagnificationGesture": .simple,
            "RotationGesture": .simple,
            "SequenceGesture": .composed,
            "SimultaneousGesture": .composed,
            "TapGesture": .simple,
        ]
        return knownGestures[name]
    }
    
    func knownGestureModifier(_ name: String) -> String? {
        let knownGestureModifiers: [String: String] = [
            "AddGestureModifier": "gesture",
            "HighPriorityGestureModifier": "gesture",
            "SimultaneousGestureModifier": "gesture",
            "_ChangedGesture": "_body|content",
            "_EndedGesture": "_body|content",
            "_MapGesture": "_body|content",
            "_ModifiersGesture": "_body|content",
            "GestureStateGesture": "base",
            "Optional": "some",
        ]
        return knownGestureModifiers[name]
    }
    
    func isComposedGesture(_ name: String) -> Bool {
        let parts = parseModifiers(name)
        return knownGesture(parts.last!) == .composed
    }
}

// MARK: - Gesture Value initializers

@available(iOS 13.0, macOS 10.15, *)
@available(tvOS, unavailable)
public extension DragGesture.Value {
    
    private struct Allocator {
        var time: Date
        var location: CGPoint
        var startLocation: CGPoint
        var velocity: CGVector
    }

    init(time: Date, location: CGPoint, startLocation: CGPoint, velocity: CGVector) {
        self = unsafeBitCast(
            Allocator(
                time: time,
                location: location,
                startLocation: startLocation,
                velocity: velocity),
            to: DragGesture.Value.self
        )
   }
}

@available(iOS 13.0, macOS 10.15, tvOS 14.0, *)
public extension LongPressGesture.Value {
    
    private struct Allocator {
        var finished: Bool
    }

    init(finished: Bool) {
        self = unsafeBitCast(
            Allocator(finished: finished),
            to: LongPressGesture.Value.self
        )
   }
}

@available(iOS 13.0, macOS 10.15, *)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
public extension MagnificationGesture.Value {
    
    private struct Allocator {
        var magnifyBy: CGFloat
    }

    init(magnifyBy: CGFloat) {
        self = unsafeBitCast(
            Allocator(magnifyBy: magnifyBy),
            to: MagnificationGesture.Value.self
        )
   }
}

@available(iOS 13.0, macOS 10.15, *)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
public extension RotationGesture.Value {
    
    private struct Allocator {
        var angle: Angle
    }

    init(angle: Angle) {
        self = unsafeBitCast(
            Allocator(angle: angle),
            to: RotationGesture.Value.self
        )
   }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension SimultaneousGesture.Value {
    
    private struct Allocator {
        var first: First.Value?
        var second: Second.Value?
    }
    
    init(first: First.Value?, second: Second.Value?) {
        self = unsafeBitCast(
            Allocator(first: first, second: second),
            to: SimultaneousGesture.Value.self)
    }
}
