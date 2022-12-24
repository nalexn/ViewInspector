import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension ViewType {
    
    struct TupleView: KnownViewType {
        public static let typePrefix: String = "TupleView"
    }
}

// MARK: - Content Extraction

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension ViewType.TupleView: MultipleViewContent {
    
    public static func children(_ content: Content) throws -> LazyGroup<Content> {
        let tupleViews = try Inspector.attribute(label: "value", value: content.view)
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
}
