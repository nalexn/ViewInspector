import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension ViewType {
    
    struct TupleView: KnownViewType {
        public static let typePrefix: String = "TupleView"
    }

    /// Starting with iOS 27, `ViewBuilder` assembles multiple children
    /// into `TupleContent` instead of `TupleView`
    struct TupleContentView: KnownViewType {
        public static let typePrefix: String = "TupleContent"
        public static func inspectionCall(typeName: String) -> String {
            return "tupleContentView(\(ViewType.indexPlaceholder))"
        }
    }
}

// MARK: - Content Extraction

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension ViewType.TupleView: MultipleViewContent {
    
    public static func children(_ content: Content) throws -> LazyGroup<Content> {
        return try ViewType.tupleChildren(content, label: "value")
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension ViewType.TupleContentView: MultipleViewContent {

    public static func children(_ content: Content) throws -> LazyGroup<Content> {
        return try ViewType.tupleChildren(content, label: "content")
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
internal extension ViewType {

    static func tupleChildren(_ content: Content, label: String) throws -> LazyGroup<Content> {
        let tupleViews = try Inspector.attribute(label: label, value: content.view)
        let childrenCount = Mirror(reflecting: tupleViews).children.count
        return LazyGroup(count: childrenCount) { index in
            let child = try Inspector.attribute(label: ".\(index)", value: tupleViews)
            let medium = content.medium.resettingViewModifiers()
            return try Inspector.unwrap(content: Content(child, medium: medium))
        }
    }
}

// MARK: - Extraction from MultipleViewContent parent

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView where View: MultipleViewContent {
    
    func tupleView(_ index: Int) throws -> InspectableView<ViewType.TupleView> {
        return try .init(try child(at: index, isTupleExtraction: true), parent: self, index: index)
    }

    func tupleContentView(_ index: Int) throws -> InspectableView<ViewType.TupleContentView> {
        return try .init(try child(at: index, isTupleExtraction: true), parent: self, index: index)
    }
}
