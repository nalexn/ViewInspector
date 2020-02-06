import SwiftUI

public extension ViewType {
    
    struct ForEach: KnownViewType {
        public static var typePrefix: String { "ForEach" }
    }
}

// MARK: - Content Extraction

extension ViewType.ForEach: MultipleViewContent {
    
    public static func children(_ content: Content) throws -> LazyGroup<Content> {
        guard let children = try (content.view as? ForEachContentProvider)?.views() else {
            throw InspectionError.typeMismatch(content.view, ForEachContentProvider.self)
        }
        return LazyGroup(count: children.count) { index in
            try Inspector.unwrap(view: try children.element(at: index), modifiers: [])
        }
    }
}

// MARK: - Extraction from SingleViewContent parent

public extension InspectableView where View: SingleViewContent {
    
    func forEach() throws -> InspectableView<ViewType.ForEach> {
        return try .init(try child())
    }
}

// MARK: - Extraction from MultipleViewContent parent

public extension InspectableView where View: MultipleViewContent {
    
    func forEach(_ index: Int) throws -> InspectableView<ViewType.ForEach> {
        return try .init(try child(at: index))
    }
}

// MARK: - Private

private protocol ForEachContentProvider {
    func views() throws -> LazyGroup<Any>
}

extension ForEach: ForEachContentProvider {
    
    func views() throws -> LazyGroup<Any> {
        
        typealias Builder = (Data.Element) -> Content
        let data = try Inspector
            .attribute(label: "data", value: self, type: Data.self)
        let builder = try Inspector
            .attribute(label: "content", value: self, type: Builder.self)
        
        return LazyGroup(count: data.count) { int in
            var index = data.startIndex
            for _ in 0 ..< int {
                index = data.index(after: index)
            }
            return builder(data[index])
        }
    }
}
