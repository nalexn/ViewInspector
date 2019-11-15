import SwiftUI

public struct InspectableView<View> where View: ViewTypeGuard {
    internal let view: Any
    
    init(_ view: Any) throws {
        if let prefix = View.typePrefix {
            try Inspector.guardType(value: view, prefix: prefix)
        }
        self.view = view
    }
}

// MARK: - SingleViewContent

public extension InspectableView where View: SingleViewContent {
    
    func anyView() throws -> InspectableView<ViewType.AnyView> {
        let content = try View.content(view: view)
        return try InspectableView<ViewType.AnyView>(content)
    }
    
    func hStack() throws -> InspectableView<ViewType.HStack> {
        let content = try View.content(view: view)
        return try InspectableView<ViewType.HStack>(content)
    }
    
    func text() throws -> InspectableView<ViewType.Text> {
        let content = try View.content(view: view)
        return try InspectableView<ViewType.Text>(content)
    }
}

// MARK: - MultipleViewContent

public extension InspectableView where View: MultipleViewContent {
    func anyView(index: Int) throws -> InspectableView<ViewType.AnyView> {
        let content = try contentView(at: index)
        return try InspectableView<ViewType.AnyView>(content)
    }
    
    func hStack(index: Int) throws -> InspectableView<ViewType.HStack> {
        let content = try contentView(at: index)
        return try InspectableView<ViewType.HStack>(content)
    }
    
    func text(index: Int) throws -> InspectableView<ViewType.Text> {
        let content = try contentView(at: index)
        return try InspectableView<ViewType.Text>(content)
    }
    
    private func contentView(at index: Int) throws -> Any {
        let viewes = try View.content(view: view)
        guard index >= 0 && index < viewes.count
            else { throw InspectionError.childViewNotFound }
        return viewes[index]
    }
}
