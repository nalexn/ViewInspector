import SwiftUI

public extension ViewType {
    struct AnyView: ViewTypeGuard, SingleViewContent {
        public static var typePrefix: String? = "AnyView"
    }
}

public extension ViewType.AnyView {
    static func content(view: Any) throws -> Any {
        return try Inspector.attribute(path: "storage|view", value: view)
    }
}

public extension AnyView {
    func inspect() throws -> InspectableView<ViewType.AnyView> {
        return try InspectableView<ViewType.AnyView>(self)
    }
}
