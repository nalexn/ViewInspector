import SwiftUI

public extension ViewType {
    
    struct GeometryReader: KnownViewType {
        public static var typePrefix: String = "GeometryReader"
    }
}

public extension GeometryReader {
    
    func inspect() throws -> InspectableView<ViewType.GeometryReader> {
        return try InspectableView<ViewType.GeometryReader>(self)
    }
}

// MARK: - Content Extraction

extension ViewType.GeometryReader: SingleViewContent {
    
    public static func content(view: Any, envObject: Any) throws -> Any {
        guard let children = try (view as? GeometryReaderContentProvider)?.content() else {
            throw InspectionError.typeMismatch(view, GeometryReaderContentProvider.self)
        }
        return try Inspector.unwrap(view: children)
    }
}

// MARK: - Extraction from SingleViewContent parent

public extension InspectableView where View: SingleViewContent {
    
    func geometryReader() throws -> InspectableView<ViewType.GeometryReader> {
        let content = try View.content(view: view, envObject: envObject)
        return try InspectableView<ViewType.GeometryReader>(content)
    }
}

// MARK: - Extraction from MultipleViewContent parent

public extension InspectableView where View: MultipleViewContent {
    
    func geometryReader(_ index: Int) throws -> InspectableView<ViewType.GeometryReader> {
        let content = try contentView(at: index)
        return try InspectableView<ViewType.GeometryReader>(content)
    }
}

// MARK: - Private

private protocol GeometryReaderContentProvider {
    func content() throws -> Any
}

extension GeometryReader: GeometryReaderContentProvider {
    func content() throws -> Any {
        let content = try Inspector.attribute(label: "content", value: self)
        typealias Builder = (GeometryProxy) -> Content
        guard let builder = content as? Builder
            else { throw InspectionError.typeMismatch(content, Builder.self) }
        return builder(GeometryProxy.stub())
    }
}

private extension GeometryProxy {
    struct Allocator {
        let data: (Double, Double, Double, Double, Double, Double) = (0, 0, 0, 0, 0, 0)
    }
    
    static func stub() -> GeometryProxy {
        precondition(MemoryLayout<GeometryProxy>.size == MemoryLayout<Allocator>.size)
        return unsafeBitCast(Allocator(), to: GeometryProxy.self)
    }
}
