import SwiftUI

public struct InspectableView<View> where View: KnownViewType {
    
    internal let view: Any
    internal let envObject: Any
    
    internal init(_ view: Any, envObject: Any = stub) throws {
        try Inspector.guardType(value: view, prefix: View.typePrefix)
        if let inspectable = view as? Inspectable {
            try Inspector.guardNoEnvObjects(inspectableView: inspectable)
        }
        self.view = view
        self.envObject = envObject
    }
    
    private static var stub: Any { Inspector.stubEnvObject }
}

internal extension InspectableView where View: MultipleViewContent {
    
    func contentView(at index: Int) throws -> Any {
        let viewes = try View.content(view: view, envObject: envObject)
        guard index >= 0 && index < viewes.count else {
            throw InspectionError.viewIndexOutOfBounds(
                index: index, count: viewes.count) }
        return try viewes.element(at: index)
    }
}
