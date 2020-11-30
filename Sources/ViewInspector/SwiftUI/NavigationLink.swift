import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension ViewType {
    
    struct NavigationLink: KnownViewType {
        public static var typePrefix: String = "NavigationLink"
    }
}

// MARK: - Content Extraction

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension ViewType.NavigationLink: SingleViewContent {
    
    public static func child(_ content: Content) throws -> Content {
        let view = try Inspector.attribute(label: "destination", value: content.view)
        return try Inspector.unwrap(view: view, modifiers: [])
    }
}

// MARK: - Extraction from SingleViewContent parent

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView where View: SingleViewContent {
    
    func navigationLink() throws -> InspectableView<ViewType.NavigationLink> {
        return try .init(try child(), parent: self, index: nil)
    }
}

// MARK: - Extraction from MultipleViewContent parent

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView where View: MultipleViewContent {
    
    func navigationLink(_ index: Int) throws -> InspectableView<ViewType.NavigationLink> {
        return try .init(try child(at: index), parent: self, index: index)
    }
}

// MARK: - Custom Attributes

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView where View == ViewType.NavigationLink {
    
    @available(*, deprecated, renamed: "labelView")
    func label() throws -> InspectableView<ViewType.ClassifiedView> {
        return try labelView()
    }
    
    func labelView() throws -> InspectableView<ViewType.ClassifiedView> {
        let view = try Inspector.attribute(label: "label", value: content.view)
        return try .init(try Inspector.unwrap(content: Content(view)), parent: self, index: nil)
    }
    
    func isActive() throws -> Bool {
        guard let external = try isActiveBinding() else {
            return try isActiveState().wrappedValue
        }
        return external.wrappedValue
    }
    
    func activate() throws { try set(isActive: true) }
    
    func deactivate() throws { try set(isActive: false) }
    
    private func set(isActive: Bool) throws {
        if let external = try isActiveBinding() {
            external.wrappedValue = isActive
        } else {
            // @State mutation from outside is ignored by SwiftUI
            // try isActiveState().wrappedValue = isActive
            //swiftlint:disable line_length
            throw InspectionError.notSupported("Enable programmatic navigation by using `NavigationLink(destination:, tag:, selection:)`")
            //swiftlint:enable line_length
        }
    }
}

// MARK: - Private

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
private extension InspectableView where View == ViewType.NavigationLink {
    func isActiveState() throws -> State<Bool> {
        if #available(iOS 14, tvOS 14, macOS 10.16, *) {
            return try Inspector
                .attribute(path: "_isActive|state", value: content.view, type: State<Bool>.self)
        }
        return try Inspector
            .attribute(label: "__internalIsActive", value: content.view, type: State<Bool>.self)
    }
    
    func isActiveBinding() throws -> Binding<Bool>? {
        if #available(iOS 14, tvOS 14, macOS 10.16, *) {
            return try? Inspector
                .attribute(path: "_isActive|binding", value: content.view, type: Binding<Bool>.self)
        }
        let isActive = try Inspector.attribute(label: "_externalIsActive", value: content.view)
        return isActive as? Binding<Bool>
    }
}
