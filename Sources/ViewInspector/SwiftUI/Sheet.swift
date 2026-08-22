import SwiftUI

// MARK: - Sheet

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension ViewType {
    
    struct Sheet: KnownViewType {
        public static let typePrefix: String = ViewType.PopupContainer<Sheet>.typePrefix
        public static var namespacedPrefixes: [String] { [typePrefix] }
        public static func inspectionCall(typeName: String) -> String {
            return "\(typeName.firstLetterLowercased)(\(ViewType.indexPlaceholder))"
        }
        public static var genericViewTypeForViewSearch: String? { "Sheet" }
    }
    typealias FullScreenCover = Sheet
}

// MARK: - Content Extraction

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension ViewType.Sheet: SingleViewContent {
    
    public static func child(_ content: Content) throws -> Content {
        let view = try Inspector.attribute(label: "popup", value: content.view)
        let medium = content.medium.resettingViewModifiers()
        return try Inspector.unwrap(view: view, medium: medium)
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension ViewType.Sheet: MultipleViewContent {
    
    public static func children(_ content: Content) throws -> LazyGroup<Content> {
        let view = try Inspector.attribute(label: "popup", value: content.view)
        let medium = content.medium.resettingViewModifiers()
        return try Inspector.viewsInContainer(view: view, medium: medium)
    }
}

// MARK: - Extraction

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView {

    func sheet(_ index: Int? = nil) throws -> InspectableView<ViewType.Sheet> {
        return try contentForModifierLookup.sheet(parent: self, index: index)
    }
}

@available(iOS 14.0, tvOS 14.0, watchOS 7.0, *)
@available(macOS, unavailable)
public extension InspectableView {

    func fullScreenCover(_ index: Int? = nil) throws -> InspectableView<ViewType.FullScreenCover> {
        return try contentForModifierLookup.sheet(parent: self, index: index, name: "FullScreenCover")
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
internal extension Content {
    
    func sheet(parent: UnwrappedView, index: Int?, name: String = "Sheet") throws -> InspectableView<ViewType.Sheet> {
        guard let modifier = try? self.modifier(
            isSheetBuilder(modifier:), call: name.firstLetterLowercased, index: index ?? 0)
        else {
            // The native modifier is either absent or opaque for the reflection
            _ = try standardSheetModifier(name)
            throw popupNotSupportedError(name)
        }
        let popupPresenter = try sheetPresenter(modifier: modifier, name: name)
        return try popup(parent: parent, index: index, name: name, popupPresenter: popupPresenter)
    }
    
    func standardSheetModifier(_ name: String = "Sheet") throws -> Any {
        return try self.modifier({
            $0.modifierType == "IdentifiedPreferenceTransformModifier<Key>"
            || $0.modifierType.contains("SheetPresentationModifier")
        }, call: name.firstLetterLowercased)
    }

    @MainActor
    func sheetsForSearch() -> [ViewSearch.ModifierIdentity] {
        let count = medium.viewModifiers
            .filter { isSheetBuilder(modifier: $0) }
            .count
        return Array(0..<count).map { _ in
            .init(name: "", builder: { parent, index in
                try parent.content.sheet(parent: parent, index: index)
            })
        }
    }

    private func sheetPresenter(modifier: Any, name: String) throws -> BasePopupPresenter {
        if let presenter = try? Inspector.attribute(
            label: "modifier", value: modifier, type: BasePopupPresenter.self) {
            return presenter
        }
        let nativeModifier = try Inspector.attribute(label: "modifier", value: modifier)
        return ViewType.Sheet.NativePresenter(modifier: nativeModifier, name: name)
    }

    @MainActor
    private func isSheetBuilder(modifier: Any) -> Bool {
        if let presenter = try? Inspector.attribute(
            label: "modifier", value: modifier, type: BasePopupPresenter.self) {
            return presenter.isSheetPresenter
        }
        guard let provider = modifier as? ModifierNameProvider,
              provider.modifierType.contains("SheetPresentationModifier"),
              let nativeModifier = try? Inspector.attribute(label: "modifier", value: modifier),
              ViewType.Sheet.NativePresenter.isInspectable(modifier: nativeModifier),
              let content = try? Inspector.attribute(label: "content", value: modifier)
        else { return false }
        // The modifiers extracted from a custom modifier's body are not reported here:
        // a `PopupPresenter` is reported through its own presenter, and any other
        // custom modifier hides the sheet behind its own `body`.
        return Inspector.typeName(value: content, generics: .remove) != "_ViewModifier_Content"
    }
}

// MARK: - Native modifier presenter

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
internal extension ViewType.Sheet {

    /// Adapts the native `.sheet` and `.fullScreenCover` modifiers to the `BasePopupPresenter` interface.
    ///
    /// The modifier's `body` assembles the sheet's content into an optional `AnyView`,
    /// which stays `nil` while the sheet is not presented.
    struct NativePresenter: BasePopupPresenter {

        let modifier: Any
        let name: String

        // The memberwise init is isolated to the MainActor via `BasePopupPresenter`
        nonisolated init(modifier: Any, name: String) {
            self.modifier = modifier
            self.name = name
        }

        /// The modifiers of the older SwiftUI versions don't expose the sheet's content.
        static func isInspectable(modifier: Any) -> Bool {
            return (try? ContentExtractor(source: modifier)) != nil
        }

        func buildPopup() throws -> Any {
            guard let view = try? Inspector.attribute(path: "modifier|content|some", value: body())
            else { throw InspectionError.viewNotFound(parent: name) }
            return try Self.unwrapPopupContent(view)
        }

        func dismissPopup() {
            if let isPresented = try? Inspector.attribute(
                label: "_isPresented", value: modifier, type: Binding<Bool>.self) {
                isPresented.wrappedValue = false
            } else if let item = try? Inspector.attribute(label: "_item", value: modifier) as? NilAssignable {
                item.assignNil()
            } else {
                assertionFailure(
                    "\(Inspector.typeName(value: modifier)) does not have a presentation binding")
                return
            }
            if let onDismiss = try? Inspector.attribute(
                path: "onDismiss|some", value: modifier) as? () -> Void {
                onDismiss()
            }
        }

        func content() throws -> Content {
            return try Inspector.unwrap(view: body(), medium: .empty)
        }

        var isSheetPresenter: Bool { true }

        private func body() throws -> Any {
            return try ContentExtractor(source: modifier).extractContent(environmentObjects: [])
        }

        /// Unwraps the `AnyView` and `SheetContent` wrappers SwiftUI puts around the user's view.
        @MainActor
        private static func unwrapPopupContent(_ view: Any) throws -> Any {
            let content = try ViewType.AnyView.child(Content(view))
            guard Inspector.typeName(value: content.view, generics: .remove) == "SheetContent"
            else { return content.view }
            return try Inspector.attribute(label: "content", value: content.view)
        }
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
private protocol NilAssignable {
    func assignNil()
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension Binding: NilAssignable where Value: ExpressibleByNilLiteral {
    func assignNil() {
        wrappedValue = nil
    }
}

// MARK: - Custom Attributes

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView where View == ViewType.Sheet {
    @MainActor
    func dismiss() throws {
        let container = try Inspector.cast(value: content.view, type: ViewType.PopupContainer<ViewType.Sheet>.self)
        container.presenter.dismissPopup()
    }

    @MainActor
    @available(*, deprecated, renamed: "dismiss")
    func callOnDismiss() throws {
        try dismiss()
    }
}
