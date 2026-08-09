import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension ViewType {
    
    struct GeometryReader: KnownViewType {
        public static let typePrefix: String = "GeometryReader"
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
    // GeometryProxy has no public initializer, so we fabricate one by zero-filling
    // a block of memory matching its runtime layout. The exact size has changed
    // across SwiftUI versions (e.g. 48 / 52 bytes), so allocate dynamically rather
    // than unsafeBitCast-ing a fixed-size struct, which traps when sizes differ.
    init() {
        let size = MemoryLayout<GeometryProxy>.size
        let alignment = MemoryLayout<GeometryProxy>.alignment
        let pointer = UnsafeMutableRawPointer.allocate(byteCount: size, alignment: alignment)
        defer { pointer.deallocate() }
        pointer.initializeMemory(as: UInt8.self, repeating: 0, count: size)
        self = pointer.load(as: GeometryProxy.self)
    }
}
