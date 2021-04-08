import SwiftUI

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

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
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
                Inspector.typeName(value: content.view), modifier: "navigationBarItems")
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
