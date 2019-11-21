import SwiftUI

extension View {
    func inspect() throws -> InspectableView<ViewType.AnyView> {
        try AnyView(self).inspect()
    }
    
    func inspect<T>(_ view: T.Type) throws -> InspectableView<ViewType.View<T>>
        where T: Inspectable {
        let unwrapped = try Inspector.unwrap(view: self)
        return try InspectableView<ViewType.View<T>>(unwrapped)
    }
    
    func inspect<T>(_ view: T.Type, _ object: T.Object) throws -> InspectableView<ViewType.ViewWithEnvObject<T>>
        where T: InspectableWithEnvObject {
        let unwrapped = try Inspector.unwrap(view: self)
        return try InspectableView<ViewType.ViewWithEnvObject<T>>(unwrapped, envObject: object)
    }
}
