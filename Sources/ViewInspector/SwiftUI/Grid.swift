import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension ViewType {
    
    struct Grid: KnownViewType {
        public static var typePrefix: String = "Grid"
    }
    
    struct GridRow: KnownViewType {
        public static var typePrefix: String = "GridRow"
    }
}

// MARK: - Extraction from SingleViewContent parent

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public extension InspectableView where View: SingleViewContent {
    
    func grid() throws -> InspectableView<ViewType.Grid> {
        return try .init(try child(), parent: self)
    }
    
    func gridRow() throws -> InspectableView<ViewType.GridRow> {
        return try .init(try child(), parent: self)
    }
}

// MARK: - Extraction from MultipleViewContent parent

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public extension InspectableView where View: MultipleViewContent {
    
    func grid(_ index: Int) throws -> InspectableView<ViewType.Grid> {
        return try .init(try child(at: index), parent: self, index: index)
    }
    
    func gridRow(_ index: Int) throws -> InspectableView<ViewType.GridRow> {
        return try .init(try child(at: index), parent: self, index: index)
    }
}

// MARK: - Content Extraction

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
extension ViewType.Grid: MultipleViewContent {
    
    public static func children(_ content: Content) throws -> LazyGroup<Content> {
        let view = try Inspector.attribute(path: "_tree|content", value: content.view)
        return try Inspector.viewsInContainer(view: view, medium: content.medium)
    }
}

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
extension ViewType.GridRow: MultipleViewContent {
    
    public static func children(_ content: Content) throws -> LazyGroup<Content> {
        let view = try Inspector.attribute(path: "content", value: content.view)
        return try Inspector.viewsInContainer(view: view, medium: content.medium)
    }
}

// MARK: - Custom Attributes

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public extension InspectableView where View == ViewType.Grid {
    
    func alignment() throws -> Alignment {
        return try Inspector.attribute(
            path: "_tree|root|alignment", value: content.view, type: Alignment.self)
    }
    
    func horizontalSpacing() throws -> CGFloat? {
        return try Inspector.attribute(
            path: "_tree|root|horizontalSpacing", value: content.view, type: CGFloat?.self)
    }
    
    func verticalSpacing() throws -> CGFloat? {
        return try Inspector.attribute(
            path: "_tree|root|verticalSpacing", value: content.view, type: CGFloat?.self)
    }
}

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public extension InspectableView where View == ViewType.GridRow {
    
    func alignment() throws -> VerticalAlignment? {
        return try Inspector.attribute(
            path: "alignment", value: content.view, type: VerticalAlignment?.self)
    }
}
