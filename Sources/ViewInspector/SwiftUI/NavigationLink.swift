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
        return try children(content).element(at: 0)
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension ViewType.NavigationLink: MultipleViewContent {
    
    public static func children(_ content: Content) throws -> LazyGroup<Content> {
        if let isActive = try? content.isActive(), !isActive {
            throw InspectionError.viewNotFound(parent: "NavigationLink's destination")
        }
        let view = try Inspector.attribute(label: "destination", value: content.view)
        return try Inspector.viewsInContainer(view: view, medium: content.medium)
    }
}

// MARK: - Extraction from SingleViewContent parent

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView where View: SingleViewContent {
    
    func navigationLink() throws -> InspectableView<ViewType.NavigationLink> {
        return try .init(try child(), parent: self)
    }
}

// MARK: - Extraction from MultipleViewContent parent

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView where View: MultipleViewContent {
    
    func navigationLink(_ index: Int) throws -> InspectableView<ViewType.NavigationLink> {
        return try .init(try child(at: index), parent: self, index: index)
    }
}

// MARK: - Non Standard Children

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension ViewType.NavigationLink: SupplementaryChildrenLabelView { }

// MARK: - Custom Attributes

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView where View == ViewType.NavigationLink {
    
    func labelView() throws -> InspectableView<ViewType.ClassifiedView> {
        return try View.supplementaryChildren(self).element(at: 0)
            .asInspectableView(ofType: ViewType.ClassifiedView.self)
    }
    
    func isActive() throws -> Bool {
        return try content.isActive()
    }
    
    func activate() throws {
        try content.set(isActive: true)
    }
    
    func deactivate() throws {
        try content.set(isActive: false)
    }
}

// MARK: - Private

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
private extension Content {
    
    func isActive() throws -> Bool {
        if let binding = try? isActiveBinding() {
            return binding.wrappedValue
        }
        return try isActiveState().wrappedValue
    }
    
    func set(isActive: Bool) throws {
        if let binding = try? isActiveBinding() {
            binding.wrappedValue = isActive
            return
        }
        try isActiveState().wrappedValue = isActive
    }
    
    private func isActiveState() throws -> State<Bool> {
        throw InspectionError.notSupported(
            """
            Please use `NavigationLink(destination:, tag:, selection:)` \
            if you need to access the state value for reading or writing.
            """)
    }
    
    private func isActiveBinding() throws -> Binding<Bool> {
        if #available(iOS 14, tvOS 14, macOS 10.16, *) {
            return try Inspector
                .attribute(path: "_isActive|binding", value: view, type: Binding<Bool>.self)
        }
        return try Inspector
            .attribute(label: "_externalIsActive", value: view, type: Binding<Bool>.self)
    }
}
