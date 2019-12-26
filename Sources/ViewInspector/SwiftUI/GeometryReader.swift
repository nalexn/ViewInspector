import SwiftUI

public extension ViewType {
    
    struct GeometryReader: KnownViewType {
        public static var typePrefix: String = "GeometryReader"
    }
}

public extension GeometryReader {
    
    func inspect() throws -> InspectableView<ViewType.GeometryReader> {
        return try .init(ViewInspector.Content(self))
    }
}

// MARK: - Content Extraction

extension ViewType.GeometryReader: SingleViewContent {
    
    public static func child(_ content: Content, injection: Any) throws -> Content {
        guard let child = try (content.view as? GeometryReaderContentProvider)?.view() else {
            throw InspectionError.typeMismatch(content.view, GeometryReaderContentProvider.self)
        }
        return try Inspector.unwrap(view: child, modifiers: [])
    }
}

// MARK: - Extraction from SingleViewContent parent

public extension InspectableView where View: SingleViewContent {
    
    func geometryReader() throws -> InspectableView<ViewType.GeometryReader> {
        return try .init(try child())
    }
}

// MARK: - Extraction from MultipleViewContent parent

public extension InspectableView where View: MultipleViewContent {
    
    func geometryReader(_ index: Int) throws -> InspectableView<ViewType.GeometryReader> {
        return try .init(try child(at: index))
    }
}

// MARK: - Private

private protocol GeometryReaderContentProvider {
    func view() throws -> Any
}

extension GeometryReader: GeometryReaderContentProvider {
    func view() throws -> Any {
        typealias Builder = (GeometryProxy) -> Content
        let builder = try Inspector
            .attribute(label: "content", value: self, type: Builder.self)
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
