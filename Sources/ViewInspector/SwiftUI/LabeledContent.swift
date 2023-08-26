import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension ViewType {
    
    struct LabeledContent: KnownViewType {
        public static let typePrefix: String = "LabeledContent"
    }
}

// MARK: - Content Extraction

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension ViewType.LabeledContent: MultipleViewContent {
    
    public static func children(_ content: Content) throws -> LazyGroup<Content> {
        let view = try Inspector.attribute(label: "content", value: content.view)
        return try Inspector.viewsInContainer(view: view, medium: content.medium)
    }
}

// MARK: - Extraction from SingleViewContent parent

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public extension InspectableView where View: SingleViewContent {
    
    func labeledContent() throws -> InspectableView<ViewType.LabeledContent> {
        return try .init(try child(), parent: self)
    }
}

// MARK: - Extraction from MultipleViewContent parent

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public extension InspectableView where View: MultipleViewContent {
    
    func labeledContent(_ index: Int) throws -> InspectableView<ViewType.LabeledContent> {
        return try .init(try child(at: index), parent: self, index: index)
    }
}

// MARK: - Non Standard Children

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension ViewType.LabeledContent: SupplementaryChildrenLabelView { }

// MARK: - Custom Attributes

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public extension InspectableView where View == ViewType.LabeledContent {
    
    func labelView() throws -> InspectableView<ViewType.ClassifiedView> {
        return try View.supplementaryChildren(self).element(at: 0)
            .asInspectableView(ofType: ViewType.ClassifiedView.self)
    }
}
