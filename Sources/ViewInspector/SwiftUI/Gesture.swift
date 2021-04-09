import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public extension ViewType {
    
    struct Gesture<T>: KnownViewType, CustomViewType where T: SwiftUI.Gesture, T: Inspectable {
        public static var typePrefix: String {
            return Inspector.typeName(type: T.self, prefixOnly: true)
        }
        
        public static var namespacedPrefixes: [String] {
            var prefixes = [
                "SwiftUI.AddGestureModifier",
                "SwiftUI.HighPriorityGestureModifier",
                "SwiftUI.SimultaneousGestureModifier",
                "SwiftUI._ChangedGesture",
                "SwiftUI._EndedGesture",
                "SwiftUI._MapGesture",
                "SwiftUI._ModifiersGesture",
                "SwiftUI.GestureStateGesture"
            ]
            prefixes.append(Inspector.typeName(type: T.self, namespaced: true, prefixOnly: true))
            return prefixes
        }
        
        public static func inspectionCall(call: String, typeName: String, index: Int) -> String {
            return "\(call)(\(typeName.self).self, \(index))"
        }
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public extension Gesture where Self: Inspectable {

    func extractContent(environmentObjects: [AnyObject]) throws -> Any { () }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension AnyGesture: Inspectable {}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension DragGesture: Inspectable {}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension ExclusiveGesture: Inspectable {}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension LongPressGesture: Inspectable {}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension MagnificationGesture: Inspectable {}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension RotationGesture: Inspectable {}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension SequenceGesture: Inspectable {}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension SimultaneousGesture: Inspectable {}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension TapGesture: Inspectable {}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public extension InspectableView {
    
    func gesture<T>(_ type: T.Type, _ index: Int = 0) throws -> InspectableView<ViewType.Gesture<T>>
    where T: Gesture & Inspectable
    {
        return try gestureModifier(
            modifierName: "AddGestureModifier",
            path: "modifier",
            type: type,
            call: "gesture",
            index: index)
    }
    
    func highPriorityGesture<T>(_ type: T.Type, _ index: Int = 0) throws -> InspectableView<ViewType.Gesture<T>>
    where T: Gesture & Inspectable
    {
        return try gestureModifier(
            modifierName: "HighPriorityGestureModifier",
            path: "modifier",
            type: type,
            call: "highPriorityGesture",
            index: index)
    }
    
    func simultaneousGesture<T>(_ type: T.Type, _ index: Int = 0) throws -> InspectableView<ViewType.Gesture<T>>
    where T: Gesture & Inspectable
    {
        return try gestureModifier(
            modifierName: "SimultaneousGestureModifier",
            path: "modifier",
            type: type,
            call: "simultaneousGesture",
            index: index)
    }

    func first<T: Gesture>(_ type: T.Type) throws -> InspectableView<ViewType.Gesture<T>> {
        return try gestureFromComposedGesture(type, .first)
    }
    
    func second<T: Gesture>(_ type: T.Type) throws -> InspectableView<ViewType.Gesture<T>> {
        return try gestureFromComposedGesture(type, .second)
    }
    
    func gestureMask() throws -> GestureMask {
        let gestureMask = try Inspector.attribute(
            path: "gestureMask",
            value: content.view,
            type: GestureMask.self)
        return gestureMask
    }
    
    func gestureCallUpdating<Value, State>(
        value: Value,
        state: inout State,
        transaction: inout Transaction) throws
    {
        typealias Callback = (Value, inout State, inout Transaction) -> ()
        let callbacks = try gestureCallbacks(
            name: "GestureStateGesture",
            path: "body",
            type: Callback.self)
        for callback in callbacks {
            callback(value, &state, &transaction)
        }
    }
    
    func gestureCallChanged<Value>(value: Value) throws {
        typealias Callback = (Value) -> ()
        let callbacks = try gestureCallbacks(
            name: "_ChangedGesture",
            path: "_body|modifier|callbacks|changed",
            type: Callback.self)
        for callback in callbacks {
            callback(value)
        }
    }
    
    func gestureCallEnded<Value>(value: Value) throws {
        typealias Callback = (Value) -> ()
        let callbacks = try gestureCallbacks(
            name: "_EndedGesture",
            path: "_body|modifier|callbacks|ended",
            type: Callback.self)
        for callback in callbacks {
            callback(value)
        }
    }

    func gestureProperties<T>() throws -> T
    where T: Gesture & Inspectable, View == ViewType.Gesture<T>
    {
        let typeName = Inspector.typeName(type: T.self)
        let valueName = Inspector.typeName(value: content.view)
        guard let (_, modifiers) = gestureName(typeName, valueName) else {
            throw InspectionError.gestureNotFound(parent: Inspector.typeName(value: self))
        }
        if modifiers.count > 0 {
            let path = modifiers.reduce("") { return addSegment(knownGestureModifier($1)!, to: $0) }
            return try Inspector.attribute(path: path, value: content.view, type: T.self)
        } else {
            return try Inspector.cast(value: content.view, type: T.self)
        }
    }
}

@available(macOS 10.15, *)
public extension InspectableView {
    
    func gestureModifiers<T>() throws -> EventModifiers
    where T: Gesture & Inspectable, View == ViewType.Gesture<T> {
        let typeName = Inspector.typeName(type: T.self)
        let valueName = Inspector.typeName(value: content.view)
        guard let (_, modifiers) = gestureName(typeName, valueName) else {
            throw InspectionError.gestureNotFound(parent: Inspector.typeName(value: self))
        }
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

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
internal extension InspectableView {
    
    func gestureModifier<T>(
        modifierName: String,
        path: String,
        type: T.Type,
        call: String,
        index: Int = 0) throws -> InspectableView<ViewType.Gesture<T>>
    where T: Gesture, T: Inspectable
    {
        let typeName = Inspector.typeName(type: type)
        let modifierCall = ViewType.Gesture<T>.inspectionCall(call: call, typeName: typeName, index: index)

        let count = numberModifierAttributes(modifierName: modifierName, path: path, call: modifierCall)
        if index >= count {
            throw InspectionError.modifierNotFound(parent: Inspector.typeName(value: content.view), modifier: call)
        }
        
        let rootView = try modifierAttribute(modifierName: modifierName, path: path, type: Any.self, call: modifierCall, index: count - 1 - index)
        
        guard let (name, _) = gestureName(typeName, Inspector.typeName(value: rootView)) else {
            throw InspectionError.gestureNotFound(parent: Inspector.typeName(value: self))
        }
        guard name == typeName else {
            throw InspectionError.typeMismatch(factual: name, expected: typeName)
        }

        return try InspectableView<ViewType.Gesture<T>>.init(Content(rootView), parent: self, call: ViewType.Gesture<T>.inspectionCall(call: call, typeName: typeName, index: index))
    }

    enum GestureOrder {
        case first
        case second
    }
    
    func gestureFromComposedGesture<T: Gesture>(_ type: T.Type, _ order: GestureOrder) throws -> InspectableView<ViewType.Gesture<T>>
    {
        let valueName = Inspector.typeName(value: content.view)
        let typeName = Inspector.typeName(type: type)
        guard let (name1, modifiers1) = gestureName(typeName, valueName) else {
            throw InspectionError.gestureNotFound(parent: Inspector.typeName(value: self))
        }
        guard isComposedGesture(name1) else {
            throw InspectionError.typeMismatch(factual: name1, expected: "ExclusiveGesture, SequenceGesture, or SimultaneousGesture")
        }
        
        var path = modifiers1.reduce("") { addSegment(knownGestureModifier($1)!, to: $0) }
        let call: String
        switch order {
        case .first:
            path = addSegment("first", to: path)
            call = "first()"
        case .second:
            path = addSegment("second", to: path)
            call = "second()"
        }
        
        let rootView = try Inspector.attribute(path: path, value: content.view, type: Any.self)
        
        guard let (name2, _) = gestureName(typeName, Inspector.typeName(value: rootView)) else {
            throw InspectionError.gestureNotFound(parent: Inspector.typeName(value: self))
        }
        let gestureTypeName = Inspector.typeName(type: type)
        guard name2 == gestureTypeName else {
            throw InspectionError.typeMismatch(factual: name2, expected: gestureTypeName)
        }
        return try .init(Inspector.unwrap(content: Content(rootView)), parent: self, call: call)
    }
    
    func gestureCallbacks<T>(
        name: String,
        path callbackPath: String,
        type: T.Type) throws -> [T]
    {
        let valueName = Inspector.typeName(value: content.view)
        let typeName = Inspector.typeName(type: type)
        guard let (_, modifiers) = gestureName(typeName, valueName) else {
            throw InspectionError.gestureNotFound(parent: Inspector.typeName(value: self))
        }
        let result = try modifiers.reduce((path: "", callbacks: [T]())) { result, modifier in
            var callbacks = result.callbacks
            if modifier == name {
                let object = try Inspector.attribute(
                    path: addSegment(callbackPath, to: result.path),
                    value: content.view,
                    type: Any.self)
                if let callback = object as? T {
                    callbacks.append(callback)
                } else {
                    throw InspectionError.callbackNotFound(
                        parent: Inspector.typeName(value: content.view),
                        callback: name)
                }
            }
            return (path: addSegment(knownGestureModifier(modifier)!, to: result.path), callbacks: callbacks)
        }
        
        if result.callbacks.count == 0 {
            throw InspectionError.callbackNotFound(
                parent: Inspector.typeName(value: content.view),
                callback: name)
        }
        return result.callbacks.reversed()
    }
    
    func gestureName(_ name: String, _ valueName: String) -> (String, [String])? {
        var modifiers = parseModifiers(valueName)
        return gestureName(name, &modifiers)
    }
    
    func gestureName(_ name: String, _ modifiers: inout [String]) -> (String, [String])? {
        guard let modifier = modifiers.popLast() else {
            return nil
        }
        if let gestureClass = knownGesture(modifier) {
            switch gestureClass {
            case .simple:
                return (modifier, [])
                
            case .composed:
                if let (first, _) = gestureName(name, &modifiers) {
                    if let (second, _) = gestureName(name, &modifiers) {
                        return ("\(modifier)<\(first), \(second)>", [])
                    }
                }
                return nil
                
            case .state :
                if let result = gestureName(name, &modifiers) {
                    if let _ = modifiers.popLast() {
                        return (result.0, [modifier] + result.1)
                    }
                    return nil
                }
            }
        } else if modifier == name {
            
        } else if let _ = knownGestureModifier(modifier) {
            if let result = gestureName(name, &modifiers) {
                return (result.0, [modifier] + result.1)
            }
            return nil
        }
        return nil
    }
    
    func parseModifiers(_ name: String) -> [String] {
        let separators = CharacterSet(charactersIn: "<>, ")
        return name
            .components(separatedBy: separators)
            .compactMap { $0 == "" ? nil : $0 }
            .reversed()
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
        let knownGestures: [String : GestureClass] = [
            "DragGesture"          : .simple,
            "ExclusiveGesture"     : .composed,
            "GestureStateGesture"  : .state,
            "LongPressGesture"     : .simple,
            "MagnificationGesture" : .simple,
            "RotationGesture"      : .simple,
            "SequenceGesture"      : .composed,
            "SimultaneousGesture"  : .composed,
            "TapGesture"           : .simple,
        ]
        return knownGestures[name]
    }
    
    func knownGestureModifier(_ name: String) -> String? {
        let knownGestureModifiers: [String : String] = [
            "AddGestureModifier"          : "gesture",
            "HighPriorityGestureModifier" : "gesture",
            "SimultaneousGestureModifier" : "gesture",
            "_ChangedGesture"             : "_body|content",
            "_EndedGesture"               : "_body|content",
            "_MapGesture"                 : "_body|content",
            "_ModifiersGesture"           : "_body|content",
            "GestureStateGesture"         : "base"
        ]
        return knownGestureModifiers[name]
    }
    
    func isComposedGesture(_ name: String) -> Bool {
        let parts = parseModifiers(name)
        return knownGesture(parts.last!) == .composed
    }
}

// MARK: - Gesture Value initializers

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
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

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
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

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
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

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
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

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
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
