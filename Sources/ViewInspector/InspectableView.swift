import SwiftUI

public struct InspectableView<View> where View: KnownViewType {
    
    internal let content: Content
    internal let envObject: Any
    
    internal init(_ content: Content, envObject: Any = stub) throws {
        try Inspector.guardType(value: content.view, prefix: View.typePrefix)
        if let inspectable = content.view as? Inspectable {
            try Inspector.guardNoEnvObjects(inspectableView: inspectable)
        }
        self.content = content
        self.envObject = envObject
    }
    
    private static var stub: Any { Inspector.stubEnvObject }
}

internal extension InspectableView where View: SingleViewContent {
    func child() throws -> Content {
        return try View.child(content, envObject: envObject)
    }
}

internal extension InspectableView where View: MultipleViewContent {
    
    func child(at index: Int) throws -> Content {
        let viewes = try View.children(content, envObject: envObject)
        guard index >= 0 && index < viewes.count else {
            throw InspectionError.viewIndexOutOfBounds(
                index: index, count: viewes.count) }
        return try viewes.element(at: index)
    }
}

// MARK: - Start of inspection for Opaque View

extension View {
    func inspect() throws -> InspectableView<ViewType.AnyView> {
        let unwrapped = try Inspector.unwrap(view: self, modifiers: [])
        if String(describing: unwrapped.view) == String(describing: self),
            !(self is Inspectable) && !(self is EnvironmentObjectInjection) {
            throw InspectionError.notSupported("View should conform to `Inspectable` or `InspectableWithEnvObject`.")
        }
        return try AnyView(self).inspect()
    }
    
    func inspect<T>(_ view: T.Type) throws -> InspectableView<ViewType.View<T>>
        where T: Inspectable {
        let unwrapped = try Inspector.unwrap(view: self, modifiers: [])
        return try InspectableView<ViewType.View<T>>(unwrapped)
    }
    
    func inspect<T>(_ view: T.Type, _ object: T.Object) throws -> InspectableView<ViewType.ViewWithEnvObject<T>>
        where T: InspectableWithEnvObject {
        let unwrapped = try Inspector.unwrap(view: self, modifiers: [])
        return try InspectableView<ViewType.ViewWithEnvObject<T>>(unwrapped, envObject: object)
    }
}

// MARK: - Modifiers

internal extension InspectableView {
    
    func modifierAttribute<Type>(modifierName: String, path: String,
                                 type: Type.Type, call: String) throws -> Type {
        return try modifierAttribute(modifierLookup: { modifier -> Bool in
            guard modifier.modifierType.contains(modifierName) else { return false }
            return (try? Inspector.attribute(path: path, value: modifier) as? Type) != nil
        }, path: path, type: type, call: call)
    }
    
    func modifierAttribute<Type>(modifierLookup: (ModifierNameProvider) -> Bool, path: String,
                                 type: Type.Type, call: String) throws -> Type {
        let foundModifier = content.modifiers.lazy
            .compactMap { $0 as? ModifierNameProvider }
            .last(where: modifierLookup)
        guard let modifier = foundModifier,
            let attribute = try? Inspector.attribute(path: path, value: modifier) as? Type
        else {
            throw InspectionError.modifierNotFound(
                parent: Inspector.typeName(value: content.view), modifier: call)
        }
        return attribute
    }
}

internal protocol ModifierNameProvider {
    var modifierType: String { get }
}

extension ModifiedContent: ModifierNameProvider {
    var modifierType: String {
        return Inspector.typeName(type: Modifier.self)
    }
}
