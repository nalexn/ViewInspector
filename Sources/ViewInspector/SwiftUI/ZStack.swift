import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension ViewType {
    
    struct ZStack: KnownViewType {
        public static let typePrefix: String = "ZStack"
    }
}

// MARK: - Content Extraction

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension ViewType.ZStack: MultipleViewContent {
    
    public static func children(_ content: Content) throws -> LazyGroup<Content> {
        return try ViewType.HStack.children(content)
    }
}

// MARK: - Extraction from SingleViewContent parent

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView where View: SingleViewContent {
    
    func zStack() throws -> InspectableView<ViewType.ZStack> {
        return try .init(try child(), parent: self)
    }
}

// MARK: - Extraction from MultipleViewContent parent

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView where View: MultipleViewContent {
    
    func zStack(_ index: Int) throws -> InspectableView<ViewType.ZStack> {
        return try .init(try child(at: index), parent: self, index: index)
    }
}

// MARK: - Custom Attributes

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView where View == ViewType.ZStack {

    func alignment() throws -> Alignment {
        return try Inspector.attribute(
            path: "alignment", value: zStackLayout(), type: Alignment.self)
    }

    private func zStackLayout() throws -> Any {
        return try Inspector.attribute(path: "_tree|root", value: content.view)
    }
}
