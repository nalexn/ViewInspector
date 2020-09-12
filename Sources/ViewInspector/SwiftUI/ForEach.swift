import SwiftUI

public extension ViewType {
    
    struct ForEach: KnownViewType {
        public static var typePrefix: String { "ForEach" }
    }
}

// MARK: - Content Extraction

extension ViewType.ForEach: MultipleViewContent {
    
    public static func children(_ content: Content) throws -> LazyGroup<Content> {
        let provider = try Inspector.cast(value: content.view, type: ForEachContentProvider.self)
        let children = try provider.views()
        return LazyGroup(count: children.count) { index in
            try Inspector.unwrap(view: try children.element(at: index), modifiers: [])
        }
    }
}

// MARK: - Extraction from SingleViewContent parent

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView where View: SingleViewContent {
    
    func forEach() throws -> InspectableView<ViewType.ForEach> {
        return try .init(try child())
    }
}

// MARK: - Extraction from MultipleViewContent parent

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView where View: MultipleViewContent {
    
    func forEach(_ index: Int) throws -> InspectableView<ViewType.ForEach> {
        return try .init(try child(at: index))
    }
}

// MARK: - Private

private protocol ForEachContentProvider {
    func views() throws -> LazyGroup<Any>
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension ForEach: ForEachContentProvider {
    
    func views() throws -> LazyGroup<Any> {
        
        typealias Builder = (Data.Element) -> Content
        let data = try Inspector
            .attribute(label: "data", value: self, type: Data.self)
        let builder = try Inspector
            .attribute(label: "content", value: self, type: Builder.self)
        
        return LazyGroup(count: data.count) { int in
            let index = data.index(data.startIndex, offsetBy: int)
            return builder(data[index])
        }
    }
}
