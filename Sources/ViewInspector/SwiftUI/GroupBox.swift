import SwiftUI

#if os(macOS)

public extension ViewType {
    
    struct GroupBox: KnownViewType {
        public static let typePrefix: String = "GroupBox"
    }
}

// MARK: - Content Extraction

extension ViewType.GroupBox: MultipleViewContent {
    
    public static func children(_ content: Content) throws -> LazyGroup<Content> {
        let content = try Inspector.attribute(label: "content", value: content.view)
        return try Inspector.viewsInContainer(view: content)
    }
}

// MARK: - Extraction from SingleViewContent parent

@available(macOS 10.15, *)
@available(iOS, unavailable)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
public extension InspectableView where View: SingleViewContent {
    
    func groupBox() throws -> InspectableView<ViewType.GroupBox> {
        return try .init(try child())
    }
}

// MARK: - Extraction from MultipleViewContent parent

@available(macOS 10.15, *)
@available(iOS, unavailable)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
public extension InspectableView where View: MultipleViewContent {
    
    func groupBox(_ index: Int) throws -> InspectableView<ViewType.GroupBox> {
        return try .init(try child(at: index))
    }
}

// MARK: - Custom Attributes

@available(macOS 10.15, *)
@available(iOS, unavailable)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
public extension InspectableView where View == ViewType.GroupBox {
    
    func label() throws -> InspectableView<ViewType.ClassifiedView> {
        let view = try Inspector.attribute(label: "label", value: content.view)
        return try .init(try Inspector.unwrap(content: Content(view)))
    }
}

#endif
