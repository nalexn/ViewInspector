import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView {

    func overlayPreferenceValue(_ index: Int? = nil) throws -> InspectableView<ViewType.Overlay> {
        return try contentForModifierLookup
            .overlay(parent: self, api: .overlayPreferenceValue, index: index)
    }
    
    func backgroundPreferenceValue(_ index: Int? = nil) throws -> InspectableView<ViewType.Overlay> {
        return try contentForModifierLookup
            .overlay(parent: self, api: .backgroundPreferenceValue, index: index)
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
internal extension ViewType {
    struct DelayedPreferenceView { }
    struct PreferenceReadingView { }
}

// MARK: - DelayedPreferenceView

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension ViewType.DelayedPreferenceView: SingleViewContent {
    
    static func child(_ content: Content) throws -> Content {
        let provider = try Inspector.cast(value: content.view, type: SingleViewProvider.self)
        let view = try provider.view()
        return try Inspector.unwrap(content: Content(view, medium: content.medium))
    }
}

// MARK: - PreferenceReadingView

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension ViewType.PreferenceReadingView: SingleViewContent {
    
    static func child(_ content: Content) throws -> Content {
        let provider = try Inspector.cast(
            value: content.view, type: SingleViewProvider.self)
        let view = try provider.view()
        let medium = content.medium.resettingViewModifiers()
        return try Inspector.unwrap(content: Content(view, medium: medium))
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension _DelayedPreferenceView: SingleViewProvider {
    func view() throws -> Any {
        typealias Builder = (_PreferenceValue<Key>) -> Content
        let readingViewBuilder = try Inspector.attribute(label: "transform", value: self, type: Builder.self)
        let prefValue = _PreferenceValue<Key>()
        return readingViewBuilder(prefValue)
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
private extension _PreferenceValue {
    struct Allocator4 {
        let data: Int32 = 0
    }
    struct Allocator8 {
        let data: Int64 = 0
    }
    
    init() {
        switch MemoryLayout<Self>.size {
        case 4:
            self = unsafeBitCast(Allocator4(), to: _PreferenceValue<Key>.self)
        case 8:
            self = unsafeBitCast(Allocator8(), to: _PreferenceValue<Key>.self)
        default:
            fatalError(MemoryLayout<Self>.actualSize())
        }
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension _PreferenceReadingView: SingleViewProvider {
    func view() throws -> Any {
        typealias Builder = (Key.Value) -> Content
        let builder = try Inspector.attribute(label: "transform", value: self, type: Builder.self)
        let value = Key.defaultValue
        return builder(value)
    }
}
