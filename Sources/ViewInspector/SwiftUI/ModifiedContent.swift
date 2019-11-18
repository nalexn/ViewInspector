import SwiftUI

#if !os(watchOS)

public extension ViewType {
    
    struct ModifiedContent: KnownViewType {
        public static var typePrefix: String = "ModifiedContent"
    }
}

public extension ModifiedContent {
    
    func inspect() throws -> InspectableView<ViewType.ModifiedContent> {
        return try InspectableView<ViewType.ModifiedContent>(self)
    }
}

// MARK: - SingleViewContent

extension ViewType.ModifiedContent: SingleViewContent {
    
    public static func content(view: Any) throws -> Any {
        let view = try Inspector.attribute(path: "content", value: view)
        return try Inspector.unwrap(view: view)
    }
}

// MARK: - SingleViewContent

public extension InspectableView where View: SingleViewContent {
    
    func modifiedContent() throws -> InspectableView<ViewType.ModifiedContent> {
        let content = try View.content(view: view)
        return try InspectableView<ViewType.ModifiedContent>(content)
    }
}

// MARK: - MultipleViewContent

public extension InspectableView where View: MultipleViewContent {
    
    func modifiedContent(_ index: Int) throws -> InspectableView<ViewType.ModifiedContent> {
        let content = try contentView(at: index)
        return try InspectableView<ViewType.ModifiedContent>(content)
    }
}

#endif
