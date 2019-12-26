import SwiftUI

public extension ViewType {
    
    struct VStack: KnownViewType {
        public static let typePrefix: String = "VStack"
    }
}

public extension VStack {
    
    func inspect() throws -> InspectableView<ViewType.VStack> {
        return try .init(ViewInspector.Content(self))
    }
}

// MARK: - Content Extraction

extension ViewType.VStack: MultipleViewContent {
    
    public static func children(_ content: Content, injection: Any) throws -> LazyGroup<Content> {
        return try ViewType.HStack.children(content, injection: injection)
    }
}

// MARK: - Extraction from SingleViewContent parent

public extension InspectableView where View: SingleViewContent {
    
    func vStack() throws -> InspectableView<ViewType.VStack> {
        return try .init(try child())
    }
}

// MARK: - Extraction from MultipleViewContent parent

public extension InspectableView where View: MultipleViewContent {
    
    func vStack(_ index: Int) throws -> InspectableView<ViewType.VStack> {
        return try .init(try child(at: index))
    }
}
