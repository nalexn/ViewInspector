import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
internal protocol PossiblyTransitiveModifier {
    func isTransitive() -> Bool
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension ModifiedContent: PossiblyTransitiveModifier {
    func isTransitive() -> Bool {
        let name = Inspector.typeName(type: Modifier.self)
        return [
            "_HiddenModifier",
        ].contains(name)
    }
}
