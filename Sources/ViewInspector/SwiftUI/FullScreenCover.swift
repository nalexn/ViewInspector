//
//  FullScreenCover.swift
//  ViewInspector
//
//  Created by Richard Gist on 9/2/21.
//

import SwiftUI

// MARK: - FullScreenCover

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension ViewType {

    struct FullScreenCover: KnownViewType {
        public static var typePrefix: String = "ViewType.FullScreenCover.Container"
        public static var namespacedPrefixes: [String] {
            return ["ViewInspector." + typePrefix]
        }
        public static func inspectionCall(typeName: String) -> String {
            return "fullScreenCover(\(ViewType.indexPlaceholder))"
        }
    }
}

// MARK: - Content Extraction

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension ViewType.FullScreenCover: SingleViewContent {

    public static func child(_ content: Content) throws -> Content {
        let view = try Inspector.attribute(label: "view", value: content.view)
        let medium = content.medium.resettingViewModifiers()
        return try Inspector.unwrap(view: view, medium: medium)
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension ViewType.FullScreenCover: MultipleViewContent {

    public static func children(_ content: Content) throws -> LazyGroup<Content> {
        let view = try Inspector.attribute(label: "view", value: content.view)
        let medium = content.medium.resettingViewModifiers()
        return try Inspector.viewsInContainer(view: view, medium: medium)
    }
}

// MARK: - Extraction

@available(iOS 13.0, tvOS 13.0, *)
@available(macOS, unavailable)
public extension InspectableView {

    func fullScreenCover(_ index: Int? = nil) throws -> InspectableView<ViewType.FullScreenCover> {
        return try contentForModifierLookup.fullScreenCover(parent: self, index: index)
    }
}

@available(iOS 13.0, tvOS 13.0, *)
@available(macOS, unavailable)
internal extension Content {

    func fullScreenCover(parent: UnwrappedView, index: Int?) throws -> InspectableView<ViewType.FullScreenCover> {
        guard let fullScreenCoverBuilder = try? self.modifierAttribute(
                modifierLookup: { isFullScreenCoverBuilder(modifier: $0) }, path: "modifier",
                type: FullScreenCoverBuilder.self, call: "", index: index ?? 0)
        else {
            _ = try self.modifier({
                $0.modifierType == "IdentifiedPreferenceTransformModifier<Key>"
                || $0.modifierType.contains("SheetPresentationModifier")
            }, call: "fullScreenCover")
            throw InspectionError.notSupported(
                """
                Please refer to the Guide for inspecting the FullScreenCover: \
                https://github.com/nalexn/ViewInspector/blob/master/guide.md#alert-sheet-actionsheet-and-fullscreencover
                """)
        }
        let view = try fullScreenCoverBuilder.buildFullScreenCover()
        let container = ViewType.FullScreenCover.Container(view: view, builder: fullScreenCoverBuilder)
        let medium = self.medium.resettingViewModifiers()
        let content = Content(container, medium: medium)
        let call = ViewType.inspectionCall(
            base: ViewType.FullScreenCover.inspectionCall(typeName: ""), index: index)
        return try .init(content, parent: parent, call: call, index: index)
    }

    func fullScreenCoversForSearch() -> [ViewSearch.ModifierIdentity] {
        let count = medium.viewModifiers
            .compactMap { isFullScreenCoverBuilder(modifier: $0) }
            .count
        return Array(0..<count).map { _ in
            .init(name: "", builder: { parent, index in
                try parent.content.fullScreenCover(parent: parent, index: index)
            })
        }
    }

    private func isFullScreenCoverBuilder(modifier: Any) -> Bool {
        return (try? Inspector.attribute(
            label: "modifier", value: modifier, type: FullScreenCoverBuilder.self)) != nil
    }
}

@available(iOS 13.0, tvOS 13.0, *)
@available(macOS, unavailable)
internal extension ViewType.FullScreenCover {
    struct Container: CustomViewIdentityMapping {
        let view: Any
        let builder: FullScreenCoverBuilder

        var viewTypeForSearch: KnownViewType.Type { ViewType.FullScreenCover.self }
    }
}

// MARK: - Custom Attributes

@available(iOS 13.0, tvOS 13.0, *)
@available(macOS, unavailable)
public extension InspectableView where View == ViewType.FullScreenCover {

    func callOnDismiss() throws {
        let fullScreenCover = try Inspector.cast(value: content.view, type: ViewType.FullScreenCover.Container.self)
        fullScreenCover.builder.dismissPopup()
    }
}

@available(iOS 13.0, tvOS 13.0, *)
@available(macOS, unavailable)
public protocol FullScreenCoverBuilder: SystemPopupPresenter {
    var onDismiss: (() -> Void)? { get }
    func buildFullScreenCover() throws -> Any
}

@available(iOS 13.0, tvOS 13.0, *)
@available(macOS, unavailable)
public protocol FullScreenCoverProvider: FullScreenCoverBuilder {
    var isPresented: Binding<Bool> { get }
    var fullScreenCoverBuilder: () -> Any { get }
}

@available(iOS 13.0, tvOS 13.0, *)
@available(macOS, unavailable)
public protocol FullScreenCoverItemProvider: FullScreenCoverBuilder {
    associatedtype Item: Identifiable
    var item: Binding<Item?> { get }
    var fullScreenCoverBuilder: (Item) -> Any { get }
}

@available(iOS 13.0, tvOS 13.0, *)
@available(macOS, unavailable)
public extension FullScreenCoverProvider {

    func buildFullScreenCover() throws -> Any {
        guard isPresented.wrappedValue else {
            throw InspectionError.viewNotFound(parent: "FullScreenCover")
        }
        return fullScreenCoverBuilder()
    }

    func dismissPopup() {
        isPresented.wrappedValue = false
        onDismiss?()
    }
}

@available(iOS 13.0, tvOS 13.0, *)
@available(macOS, unavailable)
public extension FullScreenCoverItemProvider {

    func buildFullScreenCover() throws -> Any {
        guard let value = item.wrappedValue else {
            throw InspectionError.viewNotFound(parent: "FullScreenCover")
        }
        return fullScreenCoverBuilder(value)
    }

    func dismissPopup() {
        item.wrappedValue = nil
        onDismiss?()
    }
}
