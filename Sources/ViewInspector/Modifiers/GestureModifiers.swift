import SwiftUI

// MARK: - ViewGestures

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView {
    func callOnTapGesture() throws {
        typealias Callback = ((()) -> Void)
        let callback = try modifierAttribute(
            modifierName: "TapGesture",
            path: "modifier|gesture|_body|modifier|callbacks|ended",
            type: Callback.self, call: "onTapGesture")
        callback(())
    }
    
    func callOnLongPressGesture() throws {
        let callback = try modifierAttribute(
            modifierName: "LongPressGesture",
            path: "modifier|gesture|modifier|callbacks|pressed",
            type: (() -> Void).self, call: "onLongPressGesture")
        callback()
    }
}

// MARK: - ViewHitTesting

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public struct ContentShape<S>: Equatable where S: Shape {
    public let shape: S
    public let eoFill: Bool
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        let testRect = CGRect(x: 0, y: 0, width: 100, height: 100)
        return lhs.shape.path(in: testRect) == rhs.shape.path(in: testRect) &&
            lhs.eoFill == rhs.eoFill
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView {
    
    func allowsHitTesting() -> Bool {
        return !modifiersMatching({ $0.modifierType == "_AllowsHitTestingModifier" }, transitive: true)
            .lazy
            .compactMap {
                try? Inspector.attribute(path: "modifier|allowsHitTesting", value: $0, type: Bool.self)
            }
            .contains(false)
    }
    
    func contentShape<S>(_ shape: S.Type) throws -> ContentShape<S> where S: Shape {
        let shapeValue = try modifierAttribute(
            modifierName: "_ContentShapeModifier", path: "modifier|shape",
            type: Any.self, call: "contentShape")
        let casted = try Inspector.cast(value: shapeValue, type: S.self)
        let eoFill = try modifierAttribute(
            modifierName: "_ContentShapeModifier", path: "modifier|eoFill",
            type: Bool.self, call: "contentShape")
        return .init(shape: casted, eoFill: eoFill)
    }
}
