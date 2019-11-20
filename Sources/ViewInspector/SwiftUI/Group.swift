import SwiftUI

public extension ViewType {
    
    struct Group: KnownViewType {
        public static let typePrefix: String = "Group"
    }
}

public extension Group {
    
    func inspect() throws -> InspectableView<ViewType.Group> {
        return try InspectableView<ViewType.Group>(self)
    }
}

// MARK: - MultipleViewContent

extension ViewType.Group: MultipleViewContent {
    
    public static func content(view: Any, envObject: Any) throws -> [Any] {
        let content = try Inspector.attribute(label: "content", value: view)
        return try Inspector.viewsInContainer(view: content)
    }
}

// MARK: - SingleViewContent

public extension InspectableView where View: SingleViewContent {
    
    func group() throws -> InspectableView<ViewType.Group> {
        let content = try View.content(view: view, envObject: envObject)
        return try InspectableView<ViewType.Group>(content)
    }
}

// MARK: - MultipleViewContent

public extension InspectableView where View: MultipleViewContent {
    
    func group(_ index: Int) throws -> InspectableView<ViewType.Group> {
        let content = try contentView(at: index)
        return try InspectableView<ViewType.Group>(content)
    }
}
