import SwiftUI

// MARK: - Alert

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension ViewType {
    
    struct SafeAreaInset: KnownViewType {
        public static var typePrefix: String = "_InsetViewModifier"
        public static func inspectionCall(typeName: String) -> String {
            return "safeAreaInset(\(ViewType.indexPlaceholder))"
        }
    }
}

// MARK: - Extraction

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
public extension InspectableView {

    func safeAreaInset(_ index: Int? = nil) throws -> InspectableView<ViewType.SafeAreaInset> {
        return try contentForModifierLookup.safeAreaInset(parent: self, index: index)
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
internal extension Content {
    
    func safeAreaInset(parent: UnwrappedView, index: Int?) throws -> InspectableView<ViewType.SafeAreaInset> {
        let modifier = try self.modifierAttribute(
            modifierLookup: isSafeAreaInset(modifier:), path: "modifier",
            type: Any.self, call: "safeAreaInset", index: index ?? 0)
        let medium = self.medium.resettingViewModifiers()
        let content = Content(modifier, medium: medium)
        let call = ViewType.inspectionCall(
            base: ViewType.SafeAreaInset.inspectionCall(typeName: ""), index: index)
        return try .init(content, parent: parent, call: call, index: index)
    }
    
    private func isSafeAreaInset(modifier: Any) -> Bool {
        guard let modifier = modifier as? ModifierNameProvider
        else { return false }
        return modifier.modifierType.contains(ViewType.SafeAreaInset.typePrefix)
    }
}

// MARK: - Content Extraction

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension ViewType.SafeAreaInset: SingleViewContent {
    
    public static func child(_ content: Content) throws -> Content {
        let view = try Inspector.attribute(path: "content", value: content.view)
        let medium = content.medium.resettingViewModifiers()
        return try Inspector.unwrap(view: view, medium: medium)
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension ViewType.SafeAreaInset: MultipleViewContent {
    
    public static func children(_ content: Content) throws -> LazyGroup<Content> {
        let view = try Inspector.attribute(label: "content", value: content.view)
        return try Inspector.viewsInContainer(view: view, medium: content.medium)
    }
}

// MARK: - Custom Attributes

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
public extension InspectableView where View == ViewType.SafeAreaInset {
    
    func regions() throws -> SafeAreaRegions {
        return try Inspector.attribute(
            path: "properties|regions", value: content.view, type: SafeAreaRegions.self)
    }
    
    func spacing() throws -> CGFloat? {
        return try Inspector.attribute(
            path: "properties|spacing", value: content.view, type: CGFloat?.self)
    }
    
    func edge() throws -> Edge {
        return try Inspector.attribute(
            path: "properties|edge", value: content.view, type: Edge.self)
    }
}
