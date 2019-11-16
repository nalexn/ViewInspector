import SwiftUI

public struct InspectableView<View> where View: KnownViewType {
    internal let view: Any
    
    internal init(_ view: Any) throws {
        try Inspector.guardType(value: view, prefix: View.typePrefix)
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
    
    func button() throws -> InspectableView<ViewType.Button> {
        let content = try View.content(view: view)
        return try InspectableView<ViewType.Button>(content)
    }
    
    func view<T>(_ type: T.Type) throws -> InspectableView<ViewType.Custom<T>>
        where T: Inspectable {
        let content = try View.content(view: view)
        let prefix = Inspector.typeName(type: type)
        try Inspector.guardType(value: content, prefix: prefix)
        return try InspectableView<ViewType.Custom<T>>(content)
    }
}

// MARK: - MultipleViewContent

public extension InspectableView where View: MultipleViewContent {
    
    func anyView(_ index: Int) throws -> InspectableView<ViewType.AnyView> {
        let content = try contentView(at: index)
        return try InspectableView<ViewType.AnyView>(content)
    }
    
    func hStack(_ index: Int) throws -> InspectableView<ViewType.HStack> {
        let content = try contentView(at: index)
        return try InspectableView<ViewType.HStack>(content)
    }
    
    func text(_ index: Int) throws -> InspectableView<ViewType.Text> {
        let content = try contentView(at: index)
        return try InspectableView<ViewType.Text>(content)
    }
    
    func button(_ index: Int) throws -> InspectableView<ViewType.Button> {
        let content = try contentView(at: index)
        return try InspectableView<ViewType.Button>(content)
    }
    
    func view<T>(_ type: T.Type, _ index: Int) throws -> InspectableView<ViewType.Custom<T>>
        where T: Inspectable {
        let content = try contentView(at: index)
        let prefix = Inspector.typeName(type: type)
        try Inspector.guardType(value: content, prefix: prefix)
        return try InspectableView<ViewType.Custom<T>>(content)
    }
    
    private func contentView(at index: Int) throws -> Any {
        let viewes = try View.content(view: view)
        guard index >= 0 && index < viewes.count
            else { throw InspectionError.viewIndexOutOfBounds(
                index: index, count: viewes.count) }
        return viewes[index]
    }
}
