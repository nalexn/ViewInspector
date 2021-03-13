import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
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
        return try .init(try child(), parent: self)
    }
}

// MARK: - Extraction from MultipleViewContent parent

@available(iOS 14.0, macOS 11.0, *)
@available(tvOS, unavailable)
public extension InspectableView where View: MultipleViewContent {
    
    func outlineGroup(_ index: Int) throws -> InspectableView<ViewType.OutlineGroup> {
        return try .init(try child(at: index), parent: self, index: index)
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
    
    func leaf(_ dataElement: Any) throws -> InspectableView<ViewType.ClassifiedView> {
        let provider = try Inspector.cast(value: content.view, type: LeafContentProvider.self)
        let medium = content.medium.resettingViewModifiers()
        return try .init(Content(try provider.view(dataElement), medium: medium), parent: self)
    }
}

// MARK: - Private

private protocol LeafContentProvider {
    func view(_ element: Any) throws -> Any
}

@available(iOS 14.0, macOS 11.0, *)
@available(tvOS, unavailable)
extension OutlineGroup: LeafContentProvider {
    func view(_ element: Any) throws -> Any {
        guard let data = element as? Data.Element else {
            throw InspectionError.typeMismatch(element, Data.Element.self)
        }
        typealias Builder = (Data.Element) -> Leaf
        let builder = try Inspector
            .attribute(label: "leafContent", value: self, type: Builder.self)
        return builder(data)
    }
}
