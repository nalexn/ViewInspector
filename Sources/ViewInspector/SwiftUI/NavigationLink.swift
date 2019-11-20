import SwiftUI

public extension ViewType {
    
    struct NavigationLink: KnownViewType {
        public static var typePrefix: String = "NavigationLink"
    }
}

public extension NavigationLink {
    
    func inspect() throws -> InspectableView<ViewType.NavigationLink> {
        return try InspectableView<ViewType.NavigationLink>(self)
    }
}

public extension ViewType.NavigationLink {
    
    struct Label: KnownViewType {
        public static var typePrefix: String = "NavigationLink"
    }
}

// MARK: - SingleViewContent

extension ViewType.NavigationLink: SingleViewContent {
    
    public static func content(view: Any, envObject: Any) throws -> Any {
        let view = try Inspector.attribute(label: "destination", value: view)
        return try Inspector.unwrap(view: view)
    }
}

extension ViewType.NavigationLink.Label: SingleViewContent {
    
    public static func content(view: Any, envObject: Any) throws -> Any {
        let view = try Inspector.attribute(label: "label", value: view)
        return try Inspector.unwrap(view: view)
    }
}

// MARK: - SingleViewContent

public extension InspectableView where View: SingleViewContent {
    
    func navigationLink() throws -> InspectableView<ViewType.NavigationLink> {
        let content = try View.content(view: view, envObject: envObject)
        return try InspectableView<ViewType.NavigationLink>(content)
    }
}

// MARK: - MultipleViewContent

public extension InspectableView where View: MultipleViewContent {
    
    func navigationLink(_ index: Int) throws -> InspectableView<ViewType.NavigationLink> {
        let content = try contentView(at: index)
        return try InspectableView<ViewType.NavigationLink>(content)
    }
}

// MARK: - Custom Attributes

public extension InspectableView where View == ViewType.NavigationLink {
    
    func label() throws -> InspectableView<ViewType.NavigationLink.Label> {
        return try InspectableView<ViewType.NavigationLink.Label>(view)
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
        let isActive = try Inspector.attribute(label: "__internalIsActive", value: view)
        typealias ExpectedType = State<Bool>
        guard let casted = isActive as? ExpectedType else {
            throw InspectionError.typeMismatch(isActive, ExpectedType.self)
        }
        return casted
    }
    
    func externalIsActive() throws -> Binding<Bool>? {
        let isActive = try Inspector.attribute(label: "_externalIsActive", value: view)
        typealias ExpectedType = Binding<Bool>
        return isActive as? ExpectedType
    }
}
