import SwiftUI

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
        return try .init(try child())
    }
}

// MARK: - Extraction from MultipleViewContent parent

@available(iOS 14.0, macOS 11.0, *)
@available(tvOS, unavailable)
public extension InspectableView where View: MultipleViewContent {
    
    func disclosureGroup(_ index: Int) throws -> InspectableView<ViewType.DisclosureGroup> {
        return try .init(try child(at: index))
    }
}

// MARK: - Content Extraction

extension ViewType.DisclosureGroup: MultipleViewContent {
    
    public static func children(_ content: Content) throws -> LazyGroup<Content> {
        let content = try Inspector.attribute(label: "content", value: content.view)
        return try Inspector.viewsInContainer(view: content)
    }
}

// MARK: - Custom Attributes

@available(iOS 14.0, macOS 11.0, *)
@available(tvOS, unavailable)
public extension InspectableView where View == ViewType.DisclosureGroup {
    
    func labelView() throws -> InspectableView<ViewType.ClassifiedView> {
        let view = try Inspector.attribute(label: "label", value: content.view)
        return try .init(try Inspector.unwrap(content: Content(view)))
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
            //swiftlint:disable line_length
            throw InspectionError.notSupported("You need to enable programmatic expansion by using `DisclosureGroup(isExpanded:, content:, label:`")
            //swiftlint:enable line_length
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
