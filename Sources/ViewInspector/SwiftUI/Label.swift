import SwiftUI

public extension ViewType {
    
    struct Label: KnownViewType {
        public static let typePrefix: String = "Label"
    }
}

// MARK: - Extraction from SingleViewContent parent

@available(iOS 14.0, macOS 11.0, tvOS 14.0, *)
public extension InspectableView where View: SingleViewContent {
    
    func label() throws -> InspectableView<ViewType.Label> {
        return try .init(try child())
    }
}

// MARK: - Extraction from MultipleViewContent parent

@available(iOS 14.0, macOS 11.0, tvOS 14.0, *)
public extension InspectableView where View: MultipleViewContent {
    
    func label(_ index: Int) throws -> InspectableView<ViewType.Label> {
        return try .init(try child(at: index))
    }
}

// MARK: - Custom Attributes

@available(iOS 14.0, macOS 11.0, tvOS 14.0, *)
public extension InspectableView where View == ViewType.Label {
    
    func title() throws -> InspectableView<ViewType.ClassifiedView> {
        let view = try Inspector.attribute(label: "title", value: content.view)
        return try .init(try Inspector.unwrap(content: Content(view)))
    }
    
    func icon() throws -> InspectableView<ViewType.ClassifiedView> {
        let view = try Inspector.attribute(label: "icon", value: content.view)
        return try .init(try Inspector.unwrap(content: Content(view)))
    }
}
