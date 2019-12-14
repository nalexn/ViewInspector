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
