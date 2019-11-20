import SwiftUI

#if os(iOS)

public extension ViewType {
    
    struct EditButton: KnownViewType {
        public static var typePrefix: String = "EditButton"
    }
}

public extension EditButton {
    
    func inspect() throws -> InspectableView<ViewType.EditButton> {
        return try InspectableView<ViewType.EditButton>(self)
    }
}

// MARK: - Extraction from SingleViewContent parent

public extension InspectableView where View: SingleViewContent {
    
    func editButton() throws -> InspectableView<ViewType.EditButton> {
        let content = try View.content(view: view, envObject: envObject)
        return try InspectableView<ViewType.EditButton>(content)
    }
}

// MARK: - Extraction from MultipleViewContent parent

public extension InspectableView where View: MultipleViewContent {
    
    func editButton(_ index: Int) throws -> InspectableView<ViewType.EditButton> {
        let content = try contentView(at: index)
        return try InspectableView<ViewType.EditButton>(content)
    }
}

// MARK: - Custom Attributes

public extension InspectableView where View == ViewType.EditButton {
    
    func editMode() throws -> Binding<EditMode>? {
        let editMode = try Inspector.attribute(label: "editMode", value: view)
        typealias Env = Environment<Binding<EditMode>?>
        return (editMode as? Env)?.wrappedValue
    }
}

#endif
