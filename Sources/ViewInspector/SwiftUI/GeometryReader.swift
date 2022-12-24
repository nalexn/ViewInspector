import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension ViewType {
    
    struct GeometryReader: KnownViewType {
        public static var typePrefix: String = "GeometryReader"
    }
}

// MARK: - Content Extraction

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension ViewType.GeometryReader: SingleViewContent {
    
    public static func child(_ content: Content) throws -> Content {
        let provider = try Inspector.cast(value: content.view, type: SingleViewProvider.self)
        let medium = content.medium.resettingViewModifiers()
        return try Inspector.unwrap(view: provider.view(), medium: medium)
    }
}

// MARK: - Extraction from SingleViewContent parent

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView where View: SingleViewContent {
    
    func geometryReader() throws -> InspectableView<ViewType.GeometryReader> {
        return try .init(try child(), parent: self)
    }
}

// MARK: - Extraction from MultipleViewContent parent

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView where View: MultipleViewContent {
    
    func geometryReader(_ index: Int) throws -> InspectableView<ViewType.GeometryReader> {
        return try .init(try child(at: index), parent: self, index: index)
    }
}

// MARK: - Private

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension GeometryReader: SingleViewProvider {
    func view() throws -> Any {
        typealias Builder = (GeometryProxy) -> Content
        let builder = try Inspector
            .attribute(label: "content", value: self, type: Builder.self)
        return builder(GeometryProxy())
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
private extension GeometryProxy {
    struct Allocator48 {
        let data: (Int64, Int64, Int64, Int64, Int64, Int64) = (0, 0, 0, 0, 0, 0)
    }
    struct Allocator52 {
        let data: (Allocator48, Int32) = (.init(), 0)
    }
    
    init() {
        if MemoryLayout<GeometryProxy>.size == 52 {
            self = unsafeBitCast(Allocator52(), to: GeometryProxy.self)
            return
        }
        self = unsafeBitCast(Allocator48(), to: GeometryProxy.self)
    }
}
