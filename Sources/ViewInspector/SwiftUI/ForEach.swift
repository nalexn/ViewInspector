import SwiftUI

public extension ViewType {
    
    struct ForEach<Data, Content>: KnownViewType
    where Data: RandomAccessCollection {
        public static var typePrefix: String { "ForEach" }
    }
}

public extension ForEach {
    
    func inspect() throws -> InspectableView<ViewType.ForEach<Data, Content>> {
        return try InspectableView<ViewType.ForEach<Data, Content>>(self)
    }
}

// MARK: - MultipleViewContent

extension ViewType.ForEach: MultipleViewContent {
    
    public static func content(view: Any) throws -> [Any] {
        let data = try Inspector.attribute(label: "data", value: view)
        let content = try Inspector.attribute(label: "content", value: view)
        guard let dataArray = data as? [Data.Element]
            else { throw InspectionError.typeMismatch(
                factual: Inspector.typeName(value: data),
                expected: Inspector.typeName(type: [Data.Element].self)) }
        typealias Builder = (Data.Element) -> Content
        guard let builder = content as? Builder
        else { throw InspectionError.typeMismatch(
            factual: Inspector.typeName(value: content),
            expected: Inspector.typeName(type: Builder.self)) }
        return dataArray.map { builder($0) }
    }
}

// MARK: - SingleViewContent

public extension InspectableView where View: SingleViewContent {
    
    func forEach<Data, Content>(_ items: Data.Type, _ content: Content.Type)
        throws -> InspectableView<ViewType.ForEach<Data, Content>>
        where Data: RandomAccessCollection {
            
        let content = try View.content(view: view)
        return try InspectableView<ViewType.ForEach<Data, Content>>(content)
    }
}

// MARK: - MultipleViewContent

public extension InspectableView where View: MultipleViewContent {
    
    func forEach<Data, Content>(_ items: Data.Type, _ content: Content.Type, _ index: Int)
        throws -> InspectableView<ViewType.ForEach<Data, Content>>
        where Data: RandomAccessCollection {
            
        let content = try contentView(at: index)
        return try InspectableView<ViewType.ForEach<Data, Content>>(content)
    }
}
