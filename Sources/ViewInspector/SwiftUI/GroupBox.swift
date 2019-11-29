import SwiftUI

#if os(macOS)

public extension ViewType {
    
    struct GroupBox: KnownViewType {
        public static let typePrefix: String = "GroupBox"
    }
}

public extension GroupBox {
    
    func inspect() throws -> InspectableView<ViewType.GroupBox> {
        return try InspectableView<ViewType.GroupBox>(self)
    }
}

// MARK: - Content Extraction

extension ViewType.GroupBox: MultipleViewContent {
    
    public static func content(view: Any, envObject: Any) throws -> LazyGroup<Any> {
        let content = try Inspector.attribute(label: "content", value: view)
        return try Inspector.viewsInContainer(view: content)
    }
}

// MARK: - Extraction from SingleViewContent parent

public extension InspectableView where View: SingleViewContent {
    
    func groupBox() throws -> InspectableView<ViewType.GroupBox> {
        let content = try View.content(view: view, envObject: envObject)
        return try InspectableView<ViewType.GroupBox>(content)
    }
}

// MARK: - Extraction from MultipleViewContent parent

public extension InspectableView where View: MultipleViewContent {
    
    func groupBox(_ index: Int) throws -> InspectableView<ViewType.GroupBox> {
        let content = try contentView(at: index)
        return try InspectableView<ViewType.GroupBox>(content)
    }
}

#endif
