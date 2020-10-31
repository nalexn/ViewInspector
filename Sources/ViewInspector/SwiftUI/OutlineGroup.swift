import SwiftUI

public extension ViewType {
    
    struct OutlineGroup: KnownViewType {
        public static var typePrefix: String = "OutlineGroup"
    }
}

// MARK: - Extraction from SingleViewContent parent

@available(iOS 14.0, macOS 11.0, *)
@available(tvOS, unavailable)
public extension InspectableView where View: SingleViewContent {
    
    func outlineGroup() throws -> InspectableView<ViewType.OutlineGroup> {
        return try .init(try child())
    }
}

// MARK: - Extraction from MultipleViewContent parent

@available(iOS 14.0, macOS 11.0, *)
@available(tvOS, unavailable)
public extension InspectableView where View: MultipleViewContent {
    
    func outlineGroup(_ index: Int) throws -> InspectableView<ViewType.OutlineGroup> {
        return try .init(try child(at: index))
    }
}

// MARK: - Custom Attributes

@available(iOS 14.0, macOS 11.0, *)
@available(tvOS, unavailable)
public extension InspectableView where View == ViewType.OutlineGroup {
    
    func sourceData<T>(_ type: T.Type) throws -> T {
        let root = try (try? Inspector.attribute(path: "base|forest", value: content.view)) ??
            (try Inspector.attribute(path: "base|tree", value: content.view))
        guard let data = root as? T else {
            throw InspectionError.typeMismatch(root, T.self)
        }
        return data
    }
    
    func leaf<DataElement, Leaf>(_ dataElement: DataElement, _ leafType: Leaf.Type
    ) throws -> InspectableView<ViewType.ClassifiedView> {
        typealias LeafContent = (DataElement) -> Leaf
        let leafContent = try Inspector
            .attribute(label: "leafContent", value: content.view, type: LeafContent.self)
        let view = leafContent(dataElement)
        return try .init(try Inspector.unwrap(content: Content(view)))
    }
}
