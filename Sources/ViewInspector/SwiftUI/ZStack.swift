import SwiftUI

public extension ViewType {
    
    struct ZStack: KnownViewType {
        public static let typePrefix: String = "ZStack"
    }
}

public extension ZStack {
    
    func inspect() throws -> InspectableView<ViewType.ZStack> {
        return try .init(ViewInspector.Content(self))
    }
}

// MARK: - Content Extraction

extension ViewType.ZStack: MultipleViewContent {
    
    public static func children(_ content: Content, injection: Any) throws -> LazyGroup<Content> {
        return try ViewType.HStack.children(content, injection: injection)
    }
}

// MARK: - Extraction from SingleViewContent parent

public extension InspectableView where View: SingleViewContent {
    
    func zStack() throws -> InspectableView<ViewType.ZStack> {
        return try .init(try child())
    }
}

// MARK: - Extraction from MultipleViewContent parent

public extension InspectableView where View: MultipleViewContent {
    
    func zStack(_ index: Int) throws -> InspectableView<ViewType.ZStack> {
        return try .init(try child(at: index))
    }
}
