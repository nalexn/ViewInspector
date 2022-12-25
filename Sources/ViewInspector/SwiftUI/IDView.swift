import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
internal extension ViewType {
    struct IDView { }
}

// MARK: - Content Extraction

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension ViewType.IDView: SingleViewContent {
    
    static func child(_ content: Content) throws -> Content {
        let view = try Inspector.attribute(label: "content", value: content.view)
        let medium = content.medium.appending(viewModifier: IDViewModifier(view: content.view))
        return try Inspector.unwrap(view: view, medium: medium)
    }
}

// MARK: - Private

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
private struct IDViewModifier: ModifierNameProvider {
    static var modifierName: String { "IDView" }
    func modifierType(prefixOnly: Bool) -> String { IDViewModifier.modifierName }
    var customModifier: Any? { nil }
    let view: Any
}

// MARK: - Global View Modifiers

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView {
    
    func id() throws -> AnyHashable {
        return try modifierAttribute(
            modifierName: IDViewModifier.modifierName,
            path: "view|id", type: AnyHashable.self, call: "id")
    }
}
