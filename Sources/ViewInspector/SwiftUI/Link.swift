import SwiftUI

public extension ViewType {
    
    struct Link: KnownViewType {
        public static let typePrefix: String = "Link"
    }
}

// MARK: - Extraction from SingleViewContent parent

@available(iOS 14.0, macOS 11.0, tvOS 14.0, *)
public extension InspectableView where View: SingleViewContent {
    
    func link() throws -> InspectableView<ViewType.Link> {
        return try .init(try child())
    }
}

// MARK: - Extraction from MultipleViewContent parent

@available(iOS 14.0, macOS 11.0, tvOS 14.0, *)
public extension InspectableView where View: MultipleViewContent {
    
    func link(_ index: Int) throws -> InspectableView<ViewType.Link> {
        return try .init(try child(at: index))
    }
}

// MARK: - Custom Attributes

@available(iOS 14.0, macOS 11.0, tvOS 14.0, *)
public extension InspectableView where View == ViewType.Link {
    
    func labelView() throws -> InspectableView<ViewType.ClassifiedView> {
        let view = try Inspector.attribute(label: "label", value: content.view)
        return try .init(try Inspector.unwrap(content: Content(view)))
    }
    
    func url() throws -> URL {
        return try Inspector.attribute(
            path: "destination|configuration|url", value: content.view, type: URL.self)
    }
}
