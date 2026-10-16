import SwiftUI

// MARK: - Animation

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView {
    
    func animation() throws -> Animation? {
        return try modifierAttribute(
            modifierName: "_AnimationModifier", path: "modifier|animation",
            type: Animation?.self, call: "animation")
    }

    func animationValue<V>(_ type: V.Type) throws -> V where V: Equatable {
        return try modifierAttribute(
            modifierName: "_AnimationModifier", path: "modifier|value",
            type: type, call: "animation")
    }

    func callTransaction() throws {
        let callback = try modifierAttribute(
            modifierName: "_TransactionModifier",
            path: "modifier|transform",
            type: ((inout Transaction) -> Void).self, call: "transaction")
        var transaction = Transaction()
        callback(&transaction)
    }
}
