import SwiftUI

public extension ViewType {
    
    struct Form: KnownViewType {
        public static let typePrefix: String = "Form"
    }
}

public extension Form {
    
    func inspect() throws -> InspectableView<ViewType.Form> {
        return try InspectableView<ViewType.Form>(self)
    }
}

// MARK: - MultipleViewContent

extension ViewType.Form: MultipleViewContent {
    
    public static func content(view: Any) throws -> [Any] {
        let content = try Inspector.attribute(label: "content", value: view)
        return try Inspector.viewsInContainer(view: content)
    }
}

// MARK: - SingleViewContent

public extension InspectableView where View: SingleViewContent {
    
    func form() throws -> InspectableView<ViewType.Form> {
        let content = try View.content(view: view)
        return try InspectableView<ViewType.Form>(content)
    }
}

// MARK: - MultipleViewContent

public extension InspectableView where View: MultipleViewContent {
    
    func form(_ index: Int) throws -> InspectableView<ViewType.Form> {
        let content = try contentView(at: index)
        return try InspectableView<ViewType.Form>(content)
    }
}
