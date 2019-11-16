import SwiftUI

public extension ViewType {
    
    struct HStack: KnownViewType {
        public static let typePrefix: String = "HStack"
    }
}

public extension HStack {
    
    func inspect() throws -> InspectableView<ViewType.HStack> {
        return try InspectableView<ViewType.HStack>(self)
    }
}

// MARK: - MultipleViewContent

extension ViewType.HStack: MultipleViewContent {
    
    public static func content(view: Any) throws -> [Any] {
        let content = try Inspector.attribute(path: "_tree|content", value: view)
        if Inspector.isTupleView(content) {
            let tupleViews = try Inspector.attribute(label: "value", value: content)
            let childrenCount = Mirror(reflecting: tupleViews).children.count
            return try stride(from: 0, to: childrenCount, by: 1).map { index in
                return try Inspector.attribute(label: ".\(index)", value: tupleViews)
            }
        } else {
            return [content]
        }
    }
}

// MARK: - SingleViewContent

public extension InspectableView where View: SingleViewContent {
    
    func hStack() throws -> InspectableView<ViewType.HStack> {
        let content = try View.content(view: view)
        return try InspectableView<ViewType.HStack>(content)
    }
}

// MARK: - MultipleViewContent

public extension InspectableView where View: MultipleViewContent {
    
    func hStack(_ index: Int) throws -> InspectableView<ViewType.HStack> {
        let content = try contentView(at: index)
        return try InspectableView<ViewType.HStack>(content)
    }
}
