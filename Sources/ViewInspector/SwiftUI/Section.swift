import SwiftUI

public extension ViewType {
    
    struct Section: KnownViewType {
        public static let typePrefix: String = "Section"
    }
}

public extension Section {
    
    func inspect() throws -> InspectableView<ViewType.Section> {
        return try InspectableView<ViewType.Section>(self)
    }
}

// MARK: - MultipleViewContent

extension ViewType.Section: MultipleViewContent {
    
    public static func content(view: Any, envObject: Any) throws -> [Any] {
        let content = try Inspector.attribute(label: "content", value: view)
        return try Inspector.viewsInContainer(view: content)
    }
}

// MARK: - SingleViewContent

public extension InspectableView where View: SingleViewContent {
    
    func section() throws -> InspectableView<ViewType.Section> {
        let content = try View.content(view: view, envObject: envObject)
        return try InspectableView<ViewType.Section>(content)
    }
}

// MARK: - MultipleViewContent

public extension InspectableView where View: MultipleViewContent {
    
    func section(_ index: Int) throws -> InspectableView<ViewType.Section> {
        let content = try contentView(at: index)
        return try InspectableView<ViewType.Section>(content)
    }
}
