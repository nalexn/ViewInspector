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

// MARK: - Content Extraction

extension ViewType.HStack: MultipleViewContent {
    
    public static func content(view: Any, envObject: Any) throws -> LazyGroup<Any> {
        let content = try Inspector.attribute(path: "_tree|content", value: view)
        return try Inspector.viewsInContainer(view: content)
    }
}

// MARK: - Extraction from SingleViewContent parent

public extension InspectableView where View: SingleViewContent {
    
    func hStack() throws -> InspectableView<ViewType.HStack> {
        let content = try View.content(view: view, envObject: envObject)
        return try InspectableView<ViewType.HStack>(content)
    }
}

// MARK: - Extraction from MultipleViewContent parent

public extension InspectableView where View: MultipleViewContent {
    
    func hStack(_ index: Int) throws -> InspectableView<ViewType.HStack> {
        let content = try contentView(at: index)
        return try InspectableView<ViewType.HStack>(content)
    }
}
