import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension ViewType {

    struct NavigationDestination: KnownViewType {
        public static var typePrefix: String = "ViewDestinationNavigationDestinationModifier"
        public static func inspectionCall(typeName: String) -> String {
            return "navigationDestination(\(ViewType.indexPlaceholder))"
        }
    }
}

// MARK: - Extraction

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public extension InspectableView {

    func navigationDestination(_ index: Int? = nil) throws -> InspectableView<ViewType.NavigationDestination> {
        return try contentForModifierLookup.navigationDestination(parent: self, index: index)
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
internal extension Content {

    func navigationDestination(parent: UnwrappedView, index: Int?) throws
    -> InspectableView<ViewType.NavigationDestination> {
        let modifier = try self.modifierAttribute(
            modifierLookup: isNavigationDestination(modifier:), path: "modifier",
            type: Any.self, call: "navigationDestination", index: index ?? 0)
        let medium = self.medium.resettingViewModifiers()
        let content = Content(modifier, medium: medium)
        let call = ViewType.inspectionCall(
            base: ViewType.NavigationDestination.inspectionCall(typeName: ""), index: index)
        let view = try InspectableView<ViewType.NavigationDestination>(
            content, parent: parent, call: call, index: index)
        guard try view.content.isDestinationPresented() else {
            throw InspectionError.viewNotFound(parent: "NavigationDestination")
        }
        return view
    }

    private func isNavigationDestination(modifier: Any) -> Bool {
        guard let modifier = modifier as? ModifierNameProvider
        else { return false }
        return modifier.modifierType.contains(ViewType.NavigationDestination.typePrefix)
    }
}

// MARK: - Non Standard Children

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension ViewType.NavigationDestination: SingleViewContent {

    public static func child(_ content: Content) throws -> Content {
        return try children(content).element(at: 0)
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension ViewType.NavigationDestination: MultipleViewContent {

    public static func children(_ content: Content) throws -> LazyGroup<Content> {
        if let isPresented = try? content.isDestinationPresented(), !isPresented {
            throw InspectionError.viewNotFound(parent: "NavigationDestination's destination")
        }
        let view = try Inspector.attribute(label: "destination", value: content.view)
        return try Inspector.viewsInContainer(view: view, medium: content.medium)
    }
}

// MARK: - Custom Attributes

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView where View == ViewType.NavigationDestination {

    func isPresented() throws -> Bool {
        try content.isPresentedBinding().wrappedValue
    }

    func set(isPresented: Bool) throws {
        try content.isPresentedBinding().wrappedValue = isPresented
    }
}

// MARK: - Private

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
private extension Content {

    func isDestinationPresented() throws -> Bool {
        try isPresentedBinding().wrappedValue
    }

    func isPresentedBinding() throws -> Binding<Bool> {
        try Inspector
            .attribute(label: "_isPresented", value: view, type: Binding<Bool>.self)
    }
}
