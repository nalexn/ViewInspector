import SwiftUI

public extension ViewType {
    
    struct NavigationLink: KnownViewType {
        public static var typePrefix: String = "NavigationLink"
    }
}

public extension NavigationLink {
    
    func inspect() throws -> InspectableView<ViewType.NavigationLink> {
        return try .init(ViewInspector.Content(self))
    }
}

public extension ViewType.NavigationLink {
    
    struct Label: KnownViewType {
        public static var typePrefix: String = "NavigationLink"
    }
}

// MARK: - Content Extraction

extension ViewType.NavigationLink: SingleViewContent {
    
    public static func child(_ content: Content) throws -> Content {
        let view = try Inspector.attribute(label: "destination", value: content.view)
        return try Inspector.unwrap(view: view, modifiers: [])
    }
}

extension ViewType.NavigationLink.Label: SingleViewContent {
    
    public static func child(_ content: Content) throws -> Content {
        let view = try Inspector.attribute(label: "label", value: content.view)
        return try Inspector.unwrap(view: view, modifiers: [])
    }
}

// MARK: - Extraction from SingleViewContent parent

public extension InspectableView where View: SingleViewContent {
    
    func navigationLink() throws -> InspectableView<ViewType.NavigationLink> {
        return try .init(try child())
    }
}

// MARK: - Extraction from MultipleViewContent parent

public extension InspectableView where View: MultipleViewContent {
    
    func navigationLink(_ index: Int) throws -> InspectableView<ViewType.NavigationLink> {
        return try .init(try child(at: index))
    }
}

// MARK: - Custom Attributes

public extension InspectableView where View == ViewType.NavigationLink {
    
    func label() throws -> InspectableView<ViewType.NavigationLink.Label> {
        return try .init(content)
    }
    
    func isActive() throws -> Bool {
        guard let external = try externalIsActive() else {
            return try internalIsActive().wrappedValue
        }
        return external.wrappedValue
    }
    
    func activate() throws { try set(isActive: true) }
    
    func deactivate() throws { try set(isActive: false) }
    
    private func set(isActive: Bool) throws {
        if let external = try externalIsActive() {
            external.wrappedValue = isActive
        } else {
            // @State mutation from outside is ignored by SwiftUI
            // try internalIsActive().wrappedValue = isActive
            throw InspectionError.notSupported("""
                Enable programmatic navigation by using
                `NavigationLink(destination:, tag:, selection:)`
            """)
        }
    }
}

// MARK: - Private

private extension InspectableView where View == ViewType.NavigationLink {
    func internalIsActive() throws -> State<Bool> {
        return try Inspector
            .attribute(label: "__internalIsActive", value: content.view, type: State<Bool>.self)
    }
    
    func externalIsActive() throws -> Binding<Bool>? {
        let isActive = try Inspector.attribute(label: "_externalIsActive", value: content.view)
        return isActive as? Binding<Bool>
    }
}
