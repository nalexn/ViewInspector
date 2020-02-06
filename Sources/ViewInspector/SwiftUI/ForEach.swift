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
        typealias RangeBuilder = (Int) -> Content
        typealias CollectionBuilder = (Data.Element) -> Content

        let children: LazyGroup<Any>

        if Data.self is Range<Int>.Type {
            let range = try Inspector.attribute(label: "data", value: self, type: Range<Int>.self)
            let builder = try Inspector.attribute(label: "content", value: self, type: RangeBuilder.self)

            children = LazyGroup(count: range.upperBound - range.lowerBound) {
                builder($0)
            }
        } else {
            let dataArray = try Inspector.attribute(label: "data", value: self, type: [Data.Element].self)
            let builder = try Inspector.attribute(label: "content", value: self, type: CollectionBuilder.self)

            children = LazyGroup(count: dataArray.count) {
                builder(dataArray[$0])
            }
        }

        return children
    }
}
