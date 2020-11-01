import SwiftUI

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

@available(iOS 14.0, macOS 10.15, *)
@available(tvOS, unavailable)
public extension InspectableView where View: SingleViewContent {
    
    func groupBox() throws -> InspectableView<ViewType.GroupBox> {
        return try .init(try child())
    }
}

// MARK: - Extraction from MultipleViewContent parent

@available(iOS 14.0, macOS 10.15, *)
@available(tvOS, unavailable)
public extension InspectableView where View: MultipleViewContent {
    
    func groupBox(_ index: Int) throws -> InspectableView<ViewType.GroupBox> {
        return try .init(try child(at: index))
    }
}

// MARK: - Custom Attributes

@available(iOS 14.0, macOS 10.15, *)
@available(tvOS, unavailable)
public extension InspectableView where View == ViewType.GroupBox {
    
    func labelView() throws -> InspectableView<ViewType.ClassifiedView> {
        let view = try Inspector.attribute(label: "label", value: content.view)
        return try .init(try Inspector.unwrap(content: Content(view)))
    }
}

// MARK: - Global View Modifiers

@available(iOS 14.0, macOS 11.0, *)
@available(tvOS, unavailable)
public extension InspectableView {

    func groupBoxStyle() throws -> Any {
        let modifier = try self.modifier({ modifier -> Bool in
            return modifier.modifierType.hasPrefix("GroupBoxStyleModifier")
        }, call: "groupBoxStyle")
        return try Inspector.attribute(path: "modifier|style", value: modifier)
    }
}

#if !os(macOS)
// MARK: - GroupBoxStyle inspection

@available(iOS 14.0, macOS 11.0, *)
@available(tvOS, unavailable)
public extension GroupBoxStyle {
    func inspect() throws -> InspectableView<ViewType.ClassifiedView> {
        let config = GroupBoxStyleConfiguration()
        let view = try makeBody(configuration: config).inspect()
        return try .init(view.content)
    }
}

// MARK: - Style Configuration initializer

@available(iOS 14.0, macOS 11.0, *)
@available(tvOS, unavailable)
private extension GroupBoxStyleConfiguration {
    private struct Allocator { }
    init() {
        self = unsafeBitCast(Allocator(), to: Self.self)
    }
}
#endif
