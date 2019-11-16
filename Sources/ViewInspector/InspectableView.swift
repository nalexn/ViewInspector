import SwiftUI

public struct InspectableView<View> where View: KnownViewType {
    
    internal let view: Any
    
    internal init(_ view: Any) throws {
        try Inspector.guardType(value: view, prefix: View.typePrefix)
        self.view = view
    }
}

internal extension InspectableView where View: MultipleViewContent {
    
    func contentView(at index: Int) throws -> Any {
        let viewes = try View.content(view: view)
        guard index >= 0 && index < viewes.count
            else { throw InspectionError.viewIndexOutOfBounds(
                index: index, count: viewes.count) }
        return viewes[index]
    }
}
