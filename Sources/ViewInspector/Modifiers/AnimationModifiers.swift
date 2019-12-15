import SwiftUI

// MARK: - Animation

public extension InspectableView {
    
    func callTransaction() throws {
        let callback = try modifierAttribute(
            modifierName: "_TransactionModifier",
            path: "modifier|transform",
            type: ((inout Transaction) -> Void).self, call: "transaction")
        var transaction = Transaction()
        callback(&transaction)
    }
}
