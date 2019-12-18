import SwiftUI

public extension ViewType {
    
    struct ForEach: KnownViewType {
        public static var typePrefix: String { "ForEach" }
    }
}

public extension ForEach {
    
    func inspect() throws -> InspectableView<ViewType.ForEach> {
        return try .init(ViewInspector.Content(self))
    }
}

// MARK: - Content Extraction

extension ViewType.ForEach: MultipleViewContent {
    
    public static func children(_ content: Content, envObject: Any) throws -> LazyGroup<Content> {
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
        typealias Elements = [Data.Element]
        typealias Builder = (Data.Element) -> Content
        let dataArray = try Inspector
            .attribute(label: "data", value: self, type: Elements.self)
        let builder = try Inspector
            .attribute(label: "content", value: self, type: Builder.self)
        return LazyGroup(count: dataArray.count) { index in
            builder(dataArray[index])
        }
    }
}
