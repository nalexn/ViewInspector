import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension ViewType {
    
    struct Label: KnownViewType {
        public static let typePrefix: String = "Label"
    }
}

// MARK: - Extraction from SingleViewContent parent

@available(iOS 14.0, macOS 11.0, tvOS 14.0, *)
public extension InspectableView where View: SingleViewContent {
    
    func label() throws -> InspectableView<ViewType.Label> {
        return try .init(try child(), parent: self)
    }
}

// MARK: - Extraction from MultipleViewContent parent

@available(iOS 14.0, macOS 11.0, tvOS 14.0, *)
public extension InspectableView where View: MultipleViewContent {
    
    func label(_ index: Int) throws -> InspectableView<ViewType.Label> {
        return try .init(try child(at: index), parent: self, index: index)
    }
}

// MARK: - Non Standard Children

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension ViewType.Label: SupplementaryChildren {
    static func supplementaryChildren(_ parent: UnwrappedView) throws -> LazyGroup<SupplementaryView> {
        return .init(count: 2) { index in
            let medium = parent.content.medium.resettingViewModifiers()
            if index == 0 {
                let child = try Inspector.attribute(label: "title", value: parent.content.view)
                let content = try Inspector.unwrap(content: Content(child, medium: medium))
                return try InspectableView<ViewType.ClassifiedView>(
                    content, parent: parent, call: "title()")
            } else {
                let child = try Inspector.attribute(label: "icon", value: parent.content.view)
                let content = try Inspector.unwrap(content: Content(child, medium: medium))
                return try InspectableView<ViewType.ClassifiedView>(
                    content, parent: parent, call: "icon()")
            }
        }
    }
}

// MARK: - Custom Attributes

@available(iOS 14.0, macOS 11.0, tvOS 14.0, *)
public extension InspectableView where View == ViewType.Label {
    
    func title() throws -> InspectableView<ViewType.ClassifiedView> {
        return try View.supplementaryChildren(self).element(at: 0)
            .asInspectableView(ofType: ViewType.ClassifiedView.self)
    }
    
    func icon() throws -> InspectableView<ViewType.ClassifiedView> {
        return try View.supplementaryChildren(self).element(at: 1)
            .asInspectableView(ofType: ViewType.ClassifiedView.self)
    }
}

// MARK: - Global View Modifiers

@available(iOS 14.0, macOS 11.0, tvOS 14.0, *)
public extension InspectableView {

    func labelStyle() throws -> Any {
        let modifier = try self.modifier({ modifier -> Bool in
            return ["LabelStyleModifier", "LabelStyleWritingModifier"]
                .contains(where: { modifier.modifierType.hasPrefix($0) })
        }, call: "labelStyle")
        return try Inspector.attribute(path: "modifier|style", value: modifier)
    }
}

// MARK: - LabelStyle inspection

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
public extension LabelStyle {
    func inspect() throws -> InspectableView<ViewType.ClassifiedView> {
        let config = LabelStyleConfiguration()
        let view = try makeBody(configuration: config).inspect()
        return try .init(view.content, parent: nil, index: nil)
    }
}

// MARK: - Style Configuration initializer

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
private extension LabelStyleConfiguration {
    struct Allocator { }
    init() {
        self = unsafeBitCast(Allocator(), to: Self.self)
    }
}
