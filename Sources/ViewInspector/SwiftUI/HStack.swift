import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension ViewType {
    
    struct HStack: KnownViewType {
        public static let typePrefix: String = "HStack"
    }
}

// MARK: - Content Extraction

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension ViewType.HStack: MultipleViewContent {
    
    public static func children(_ content: Content) throws -> LazyGroup<Content> {
        let container = try Inspector.attribute(path: "_tree|content", value: content.view)
        return try Inspector.viewsInContainer(view: container)
    }
}

// MARK: - Extraction from SingleViewContent parent

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView where View: SingleViewContent {
    
    func hStack() throws -> InspectableView<ViewType.HStack> {
        return try .init(try child(), parent: self)
    }
}

// MARK: - Extraction from MultipleViewContent parent

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView where View: MultipleViewContent {
    
    func hStack(_ index: Int) throws -> InspectableView<ViewType.HStack> {
        return try .init(try child(at: index), parent: self)
    }
}
