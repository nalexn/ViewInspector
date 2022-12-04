import SwiftUI

#if (os(macOS) || targetEnvironment(macCatalyst)) && !MAC_OS_VERSION_13_0
struct ToolbarPlacement {
    static var navigationBar: ToolbarPlacement { .init() }
}
#endif

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView {
    
    @available(iOS 13.0, tvOS 13.0, *)
    @available(macOS, unavailable)
    func navigationBarHidden() throws -> Bool {
        if #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *) {
            let value = try modifierAttribute(modifierLookup: { modifier -> Bool in
                guard modifier.modifierType.contains("ToolbarAppearanceModifier"),
                      let bars = try? Inspector.attribute(
                        path: "modifier|bars", value: modifier, type: [ToolbarPlacement].self)
                else { return false }
                return bars.contains(.navigationBar)
            }, path: "modifier|visibility|some", type: Any.self, call: "navigationBarHidden")
            return String(describing: value) != "visible"
        }
        let value = try modifierAttribute(
            modifierName: "_PreferenceWritingModifier<NavigationBarHiddenKey>",
            path: "modifier|value", type: Any.self, call: "navigationBarHidden")
        if let bool = value as? Bool?, let value = bool {
            return value
        }
        return try Inspector.cast(value: value, type: Bool.self)
    }
    
    @available(iOS 13.0, tvOS 13.0, *)
    @available(macOS, unavailable)
    func navigationBarBackButtonHidden() throws -> Bool {
        return try modifierAttribute(
            modifierName: "_PreferenceWritingModifier<NavigationBarBackButtonHiddenKey>",
            path: "modifier|value", type: Bool.self, call: "navigationBarBackButtonHidden")
    }
    
    @available(iOS 13.0, *)
    @available(macOS, unavailable)
    @available(tvOS, unavailable)
    @available(watchOS, unavailable)
    func statusBarHidden() throws -> Bool {
        return try modifierAttribute(
            modifierName: "TransactionalPreferenceModifier<Bool, StatusBarKey>",
            path: "modifier|value", type: Bool.self, call: "statusBar(hidden:)")
    }
}

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
extension ToolbarPlacement: BinaryEquatable { }

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
internal extension ViewType {
    struct EnvironmentReaderView { }
}

// MARK: - Content Extraction

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension ViewType.EnvironmentReaderView: SingleViewContent {
    
    static func child(_ content: Content) throws -> Content {
        return content
    }
}

// MARK: - Extraction from SingleViewContent parent

@available(iOS 13.0, tvOS 13.0, *)
@available(macOS, unavailable)
@available(watchOS, unavailable)
public extension InspectableView where View: SingleViewContent {
    
    func navigationBarItems() throws -> InspectableView<ViewType.ClassifiedView> {
        return try navigationBarItems(AnyView.self)
    }
    
    func navigationBarItems<V>(_ viewType: V.Type) throws ->
        InspectableView<ViewType.ClassifiedView> where V: SwiftUI.View {
        return try navigationBarItems(viewType: viewType, content: try child())
    }
}

// MARK: - Extraction from MultipleViewContent parent

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView where View: MultipleViewContent {
    
    func navigationBarItems(_ index: Int = 0) throws -> InspectableView<ViewType.ClassifiedView> {
        return try navigationBarItems(AnyView.self, index)
    }
    
    func navigationBarItems<V>(_ viewType: V.Type, _ index: Int = 0) throws ->
        InspectableView<ViewType.ClassifiedView> where V: SwiftUI.View {
        return try navigationBarItems(viewType: viewType, content: try child(at: index))
    }
}

// MARK: - Unwrapping the EnvironmentReaderView

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
internal extension InspectableView {
    
    func navigationBarItems<V>(viewType: V.Type, content: Content) throws ->
        InspectableView<ViewType.ClassifiedView> where V: SwiftUI.View {
        
        typealias Closure = (EnvironmentValues) -> ModifiedContent<V,
            _PreferenceWritingModifier<FakeNavigationBarItemsKey>>
        guard let closure = try? Inspector.attribute(label: "content", value: content.view),
            let closureDesc = Inspector.typeName(value: closure) as String?,
            closureDesc.contains("_PreferenceWritingModifier<NavigationBarItemsKey>>") else {
            throw InspectionError.modifierNotFound(parent:
                Inspector.typeName(value: content.view), modifier: "navigationBarItems", index: 0)
        }
        
        let expectedViewType = closureDesc.navigationBarItemsWrappedViewType
        guard Inspector.typeName(type: viewType) == expectedViewType else {
            // swiftlint:disable line_length
            throw InspectionError.notSupported(
                "Please substitute '\(expectedViewType).self' as the parameter for 'navigationBarItems()' inspection call")
            // swiftlint:enable line_length
        }
        
        guard let typedClosure = withUnsafeBytes(of: closure, {
            $0.bindMemory(to: Closure.self).first
        }) else { throw InspectionError.typeMismatch(closure, Closure.self) }
        let view = typedClosure(EnvironmentValues())
        return try .init(try Inspector.unwrap(view: view, medium: content.medium), parent: self)
    }
}

private extension String {
    var navigationBarItemsWrappedViewType: String {
        let prefix = "(EnvironmentValues) -> ModifiedContent<"
        let suffix = ", _PreferenceWritingModifier<NavigationBarItemsKey>>"
        return components(separatedBy: prefix).last?
            .components(separatedBy: suffix).first ?? self
    }
}

private struct FakeNavigationBarItemsKey: PreferenceKey {
    static var defaultValue: String = ""
    static func reduce(value: inout String, nextValue: () -> String) { }
}
