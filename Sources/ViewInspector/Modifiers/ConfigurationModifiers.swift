import SwiftUI

// MARK: - ViewControlAttributesTests

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView {
    
    func labelsHidden() throws -> Bool {
        _ = try modifierAttribute(
            modifierName: "_LabeledViewStyleModifier<HiddenLabeledViewStyle>",
            path: "modifier|style",
            type: Any.self, call: "labelsHidden")
        return true
    }
}
