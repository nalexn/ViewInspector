import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension ViewType {
    
    struct ScrollViewReader: KnownViewType {
        public static var typePrefix: String = "ScrollViewReader"
    }
}

// MARK: - Extraction from SingleViewContent parent

@available(iOS 14.0, macOS 11.0, tvOS 14.0, *)
public extension InspectableView where View: SingleViewContent {
    
    func scrollViewReader() throws -> InspectableView<ViewType.ScrollViewReader> {
        return try .init(try child(), parent: self)
    }
}

// MARK: - Extraction from MultipleViewContent parent

@available(iOS 14.0, macOS 11.0, tvOS 14.0, *)
public extension InspectableView where View: MultipleViewContent {
    
    func scrollViewReader(_ index: Int) throws -> InspectableView<ViewType.ScrollViewReader> {
        return try .init(try child(at: index), parent: self, index: index)
    }
}

// MARK: - Content Extraction

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension ViewType.ScrollViewReader: SingleViewContent {
    
    public static func child(_ content: Content) throws -> Content {
        let provider = try Inspector.cast(value: content.view, type: SingleViewProvider.self)
        let medium = content.medium.resettingViewModifiers()
        return try Inspector.unwrap(view: provider.view(), medium: medium)
    }
}

// MARK: - Private

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
extension ScrollViewReader: SingleViewProvider {
    func view() throws -> Any {
        typealias Builder = (ScrollViewProxy) -> Content
        let builder = try Inspector
            .attribute(label: "content", value: self, type: Builder.self)
        return builder(ScrollViewProxy())
    }
}

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
private extension ScrollViewProxy {
    struct Allocator8 {
        let data: Int64 = 0
    }
    
    init() {
        switch MemoryLayout<Self>.size {
        case 8:
            self = unsafeBitCast(Allocator8(), to: ScrollViewProxy.self)
        default:
            fatalError(MemoryLayout<Self>.actualSize())
        }
    }
}
