import SwiftUI

internal extension ViewType {
    struct DelayedPreferenceView { }
}

// MARK: - Content Extraction

extension ViewType.DelayedPreferenceView: SingleViewContent {
    
    static func child(_ content: Content) throws -> Content {
        return content
    }
}

// MARK: - Extraction from SingleViewContent parent

public extension InspectableView where View: SingleViewContent {
    
    func preferenceValue<Key>(_ key: Key.Type) throws ->
        InspectableView<ViewType.ClassifiedView> where Key: PreferenceKey {
            return try preferenceValue(key, base: AnyView.self, overlay: AnyView.self)
    }
    
    func preferenceValue<Key, Base, Overlay>(
        _ key: Key.Type, base: Base.Type, overlay: Overlay.Type)
        throws -> InspectableView<ViewType.ClassifiedView>
        where Key: PreferenceKey, Base: SwiftUI.View, Overlay: SwiftUI.View {
            return try unwrapPreferenceView(key: key, base: base, overlay: overlay,
                                            content: try child())
    }
}

// MARK: - Extraction from MultipleViewContent parent

public extension InspectableView where View: MultipleViewContent {
    
    func preferenceValue<Key>(_ key: Key.Type, _ index: Int = 0) throws ->
        InspectableView<ViewType.ClassifiedView> where Key: PreferenceKey {
            return try preferenceValue(key, base: AnyView.self, overlay: AnyView.self, index)
    }
    
    func preferenceValue<Key, Base, Overlay>(
        _ key: Key.Type, base: Base.Type, overlay: Overlay.Type, _ index: Int = 0)
        throws -> InspectableView<ViewType.ClassifiedView>
        where Key: PreferenceKey, Base: SwiftUI.View, Overlay: SwiftUI.View {
            return try unwrapPreferenceView(key: key, base: base, overlay: overlay,
                                            content: try child(at: index))
    }
}

// MARK: - Unwrapping the DelayedPreferenceView

private extension InspectableView {
    
    func unwrapPreferenceView<Key, Base, Overlay>(
        key: Key.Type, base: Base.Type, overlay: Overlay.Type, content: Content
    ) throws -> InspectableView<ViewType.ClassifiedView>
    where Key: PreferenceKey, Base: SwiftUI.View, Overlay: SwiftUI.View {
        
        typealias Closure = (_PreferenceValue<Key>) ->
            ModifiedContent<Overlay, _OverlayModifier<_PreferenceReadingView<Key, Base>>>
        guard let closure = try? Inspector.attribute(label: "transform", value: content.view),
            let closureDesc = Inspector.typeName(value: closure) as String?,
            closureDesc.contains(", _OverlayModifier<_PreferenceReadingView") else {
            throw InspectionError.modifierNotFound(parent:
                Inspector.typeName(value: content), modifier: "overlayPreferenceValue' or 'backgroundPreferenceValue")
        }
        
        let expectedBaseViewType = closureDesc.preferenceViewBaseViewType(key)
        let expectedOverlayViewType = closureDesc.preferenceViewOverlayViewType(key)
        guard Inspector.typeName(type: base) == expectedBaseViewType &&
            Inspector.typeName(type: overlay) == expectedOverlayViewType else {
            //swiftlint:disable line_length
            throw InspectionError.notSupported(
                "Please substitute 'base: \(expectedBaseViewType).self, overlay: \(expectedOverlayViewType).self' as the parameters for 'preferenceValue()' inspection call")
            //swiftlint:enable line_length
        }
        
        guard let typedClosure = withUnsafeBytes(of: closure, {
            $0.bindMemory(to: Closure.self).first
        }) else { throw InspectionError.typeMismatch(closure, Closure.self) }
        
        // This convertion does not go well: resulting _PreferenceValue is messed up
        let param = unsafeBitCast(Int64(0), to: _PreferenceValue<Key>.self)
        let view = typedClosure(param)
        /* 'view' structure:
          "content" ==> Overlay
          "modifier|overlay|transform" ==> (Key.Value) -> Base
         
         First of all, it looks like the Base and Overlay views are mixed up in SwiftUI
         Secondly, because `param` was corrupt, only the "content" extraction works stably
        */
        let overlay = try Inspector.attribute(label: "content", value: view)
        return try .init(try Inspector.unwrap(view: overlay, modifiers: content.modifiers))
    }
}

private extension String {
    func preferenceViewBaseViewType<K>(_ key: K.Type) -> String {
        let keyName = Inspector.typeName(type: key)
        let prefix = "(_PreferenceValue<\(keyName)>) -> ModifiedContent<"
        let suffix = ", _OverlayModifier<_PreferenceReadingView<\(keyName)"
        return components(separatedBy: prefix).last?
            .components(separatedBy: suffix).first ?? self
    }
    
    func preferenceViewOverlayViewType<K>(_ key: K.Type) -> String {
        let keyName = Inspector.typeName(type: key)
        var name = self
        name.removeLast(3)
        let prefix = "_OverlayModifier<_PreferenceReadingView<\(keyName), "
        return name.components(separatedBy: prefix).last ?? self
    }
}
