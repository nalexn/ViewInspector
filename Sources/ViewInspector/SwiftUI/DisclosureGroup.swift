import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension ViewType {
    
    struct DisclosureGroup: KnownViewType {
        public static var typePrefix: String = "DisclosureGroup"
    }
}

// MARK: - Extraction from SingleViewContent parent

@available(iOS 14.0, macOS 11.0, *)
@available(tvOS, unavailable)
public extension InspectableView where View: SingleViewContent {
    
    func disclosureGroup() throws -> InspectableView<ViewType.DisclosureGroup> {
        return try .init(try child(), parent: self)
    }
}

// MARK: - Extraction from MultipleViewContent parent

@available(iOS 14.0, macOS 11.0, *)
@available(tvOS, unavailable)
public extension InspectableView where View: MultipleViewContent {
    
    func disclosureGroup(_ index: Int) throws -> InspectableView<ViewType.DisclosureGroup> {
        return try .init(try child(at: index), parent: self, index: index)
    }
}

// MARK: - Content Extraction

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension ViewType.DisclosureGroup: MultipleViewContent {
    
    public static func children(_ content: Content) throws -> LazyGroup<Content> {
        let view = try Inspector.attribute(label: "content", value: content.view)
        return try Inspector.viewsInContainer(view: view, medium: content.medium)
    }
}

// MARK: - Non Standard Children

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension ViewType.DisclosureGroup: SupplementaryChildrenLabelView { }

// MARK: - Custom Attributes

@available(iOS 14.0, macOS 11.0, *)
@available(tvOS, unavailable)
public extension InspectableView where View == ViewType.DisclosureGroup {
    
    func labelView() throws -> InspectableView<ViewType.ClassifiedView> {
        return try View.supplementaryChildren(self).element(at: 0)
            .asInspectableView(ofType: ViewType.ClassifiedView.self)
    }
    
    func isExpanded() throws -> Bool {
        guard let external = try isExpandedBinding() else {
            return try isExpandedState().wrappedValue
        }
        return external.wrappedValue
    }
    
    func expand() throws { try set(isExpanded: true) }
    
    func collapse() throws { try set(isExpanded: false) }
    
    private func set(isExpanded: Bool) throws {
        if let external = try isExpandedBinding() {
            external.wrappedValue = isExpanded
        } else {
            // @State mutation from outside is ignored by SwiftUI
            // try isExpandedState().wrappedValue = isExpanded
            // swiftlint:disable line_length
            throw InspectionError.notSupported("You need to enable programmatic expansion by using `DisclosureGroup(isExpanded:, content:, label:`")
            // swiftlint:enable line_length
        }
    }
}

@available(iOS 14.0, macOS 11.0, *)
@available(tvOS, unavailable)
private extension InspectableView where View == ViewType.DisclosureGroup {
    func isExpandedState() throws -> State<Bool> {
        return try Inspector
            .attribute(path: "_isExpanded|state", value: content.view, type: State<Bool>.self)
    }
    
    func isExpandedBinding() throws -> Binding<Bool>? {
        return try? Inspector
            .attribute(path: "_isExpanded|binding", value: content.view, type: Binding<Bool>.self)
    }
}
