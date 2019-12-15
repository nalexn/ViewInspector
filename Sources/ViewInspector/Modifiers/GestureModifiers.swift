import SwiftUI

// MARK: - ViewGestures

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

public struct ContentShape<S>: Equatable where S: Shape {
    public let shape: S
    public let eoFill: Bool
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        let testRect = CGRect(x: 0, y: 0, width: 100, height: 100)
        return lhs.shape.path(in: testRect) == rhs.shape.path(in: testRect) &&
            lhs.eoFill == rhs.eoFill
    }
}

public extension InspectableView {
    
    func allowsHitTesting() throws -> Bool {
        return try modifierAttribute(
            modifierName: "_AllowsHitTestingModifier", path: "modifier|allowsHitTesting",
            type: Bool.self, call: "allowsHitTesting")
    }
    
    func contentShape<S>(_ shape: S.Type) throws -> ContentShape<S> where S: Shape {
        let shapeValue = try modifierAttribute(
            modifierName: "_ContentShapeModifier", path: "modifier|shape",
            type: Any.self, call: "contentShape")
        guard let casted = shapeValue as? S else {
            let factual = Inspector.typeName(value: shapeValue)
            let expected = Inspector.typeName(type: S.self)
            throw InspectionError.typeMismatch(factual: factual, expected: expected)
        }
        let eoFill = try modifierAttribute(
            modifierName: "_ContentShapeModifier", path: "modifier|eoFill",
            type: Bool.self, call: "contentShape")
        return .init(shape: casted, eoFill: eoFill)
    }
}
