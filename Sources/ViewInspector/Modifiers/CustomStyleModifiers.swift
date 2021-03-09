import SwiftUI

// MARK: - Custom Style Modifiers

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView {

    func customStyle(_ modifierName: String) throws -> Any {
        
        let name = modifierName.firstUppercased + "Modifier"

        let modifier = try self.modifier({ modifier -> Bool in
            return modifier.modifierType.hasPrefix(name)
        }, call: modifierName)
        if let style = try? Inspector.attribute(path: "modifier|style|style", value: modifier) {
            return style
        }
        return try Inspector.attribute(path: "modifier|style", value: modifier)
    }
}

private extension StringProtocol {
    var firstUppercased: String { prefix(1).uppercased() + dropFirst() }
}
