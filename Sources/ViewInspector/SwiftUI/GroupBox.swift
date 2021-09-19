import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension ViewType {
    
    struct GroupBox: KnownViewType {
        public static let typePrefix: String = "GroupBox"
    }
}

// MARK: - Content Extraction

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension ViewType.GroupBox: MultipleViewContent {
    
    public static func children(_ content: Content) throws -> LazyGroup<Content> {
        let view = try Inspector.attribute(label: "content", value: content.view)
        return try Inspector.viewsInContainer(view: view, medium: content.medium)
    }
}

// MARK: - Extraction from SingleViewContent parent

@available(iOS 14.0, macOS 10.15, *)
@available(tvOS, unavailable)
public extension InspectableView where View: SingleViewContent {
    
    func groupBox() throws -> InspectableView<ViewType.GroupBox> {
        return try .init(try child(), parent: self)
    }
}

// MARK: - Extraction from MultipleViewContent parent

@available(iOS 14.0, macOS 10.15, *)
@available(tvOS, unavailable)
public extension InspectableView where View: MultipleViewContent {
    
    func groupBox(_ index: Int) throws -> InspectableView<ViewType.GroupBox> {
        return try .init(try child(at: index), parent: self, index: index)
    }
}

// MARK: - Non Standard Children

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension ViewType.GroupBox: SupplementaryChildrenLabelView { }

// MARK: - Custom Attributes

@available(iOS 14.0, macOS 10.15, *)
@available(tvOS, unavailable)
public extension InspectableView where View == ViewType.GroupBox {
    
    func labelView() throws -> InspectableView<ViewType.ClassifiedView> {
        return try View.supplementaryChildren(self).element(at: 0)
            .asInspectableView(ofType: ViewType.ClassifiedView.self)
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

// MARK: - GroupBoxStyle inspection

#if os(iOS) || os(macOS)
@available(iOS 14.0, macOS 11.0, *)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
public extension GroupBoxStyle {
    func inspect() throws -> InspectableView<ViewType.ClassifiedView> {
        let config = GroupBoxStyleConfiguration()
        let view = try makeBody(configuration: config).inspect()
        return try .init(view.content, parent: nil, index: nil)
    }
}

// MARK: - Style Configuration initializer

@available(iOS 14.0, macOS 11.0, *)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
private extension GroupBoxStyleConfiguration {
    private struct Allocator { }
    init() {
        self = unsafeBitCast(Allocator(), to: Self.self)
    }
}
#endif
