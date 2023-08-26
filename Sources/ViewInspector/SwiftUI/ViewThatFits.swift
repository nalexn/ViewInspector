import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension ViewType {
    
    struct ViewThatFits: KnownViewType {
        public static let typePrefix: String = "ViewThatFits"
    }
}

// MARK: - Content Extraction

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
extension ViewType.ViewThatFits: MultipleViewContent {

    public static func children(_ content: Content) throws -> LazyGroup<Content> {
        return try ViewType.HStack.children(content)
    }
}

// MARK: - Extraction from SingleViewContent parent

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public extension InspectableView where View: SingleViewContent {
    
    func viewThatFits() throws -> InspectableView<ViewType.ViewThatFits> {
        return try .init(try child(), parent: self)
    }
}

// MARK: - Extraction from MultipleViewContent parent

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public extension InspectableView where View: MultipleViewContent {
    
    func viewThatFits(_ index: Int) throws -> InspectableView<ViewType.ViewThatFits> {
        return try .init(try child(at: index), parent: self, index: index)
    }
}
