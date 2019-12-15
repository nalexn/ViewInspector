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
