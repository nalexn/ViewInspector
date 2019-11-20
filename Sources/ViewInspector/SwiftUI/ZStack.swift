import SwiftUI

public extension ViewType {
    
    struct ZStack: KnownViewType {
        public static let typePrefix: String = "ZStack"
    }
}

public extension ZStack {
    
    func inspect() throws -> InspectableView<ViewType.ZStack> {
        return try InspectableView<ViewType.ZStack>(self)
    }
}

// MARK: - Content Extraction

extension ViewType.ZStack: MultipleViewContent {
    
    public static func content(view: Any, envObject: Any) throws -> [Any] {
        return try ViewType.HStack.content(view: view, envObject: envObject)
    }
}

// MARK: - Extraction from SingleViewContent parent

public extension InspectableView where View: SingleViewContent {
    
    func zStack() throws -> InspectableView<ViewType.ZStack> {
        let content = try View.content(view: view, envObject: envObject)
        return try InspectableView<ViewType.ZStack>(content)
    }
}

// MARK: - Extraction from MultipleViewContent parent

public extension InspectableView where View: MultipleViewContent {
    
    func zStack(_ index: Int) throws -> InspectableView<ViewType.ZStack> {
        let content = try contentView(at: index)
        return try InspectableView<ViewType.ZStack>(content)
    }
}
