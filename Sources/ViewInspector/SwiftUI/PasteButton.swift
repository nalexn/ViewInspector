import SwiftUI
import UniformTypeIdentifiers.UTType

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension ViewType {
    
    struct PasteButton: KnownViewType {
        public static var typePrefix: String = "PasteButton"
    }
}

#if os(macOS)

// MARK: - Extraction from SingleViewContent parent

@available(macOS 10.15, *)
@available(iOS, unavailable)
@available(tvOS, unavailable)
public extension InspectableView where View: SingleViewContent {
    
    func pasteButton() throws -> InspectableView<ViewType.PasteButton> {
        return try .init(try child(), parent: self)
    }
}

// MARK: - Extraction from MultipleViewContent parent

@available(macOS 10.15, *)
@available(iOS, unavailable)
@available(tvOS, unavailable)
public extension InspectableView where View: MultipleViewContent {
    
    func pasteButton(_ index: Int) throws -> InspectableView<ViewType.PasteButton> {
        return try .init(try child(at: index), parent: self, index: index)
    }
}

// MARK: - Custom Attributes

@available(macOS 10.15, *)
@available(iOS, unavailable)
@available(tvOS, unavailable)
public extension InspectableView where View == ViewType.PasteButton {
    
    /* Not Supported. Related: callOnPasteCommand in "InteractionModifiers.swift"
    func callPayloadAction()
    */
    
    @available(macOS 11.0, *)
    func supportedContentTypes() throws -> [UTType] {
        let container = (try? Inspector.attribute(label: "pasteHelper", value: content.view)) ?? content.view
        return try Inspector
            .attribute(label: "supportedContentTypes", value: container, type: [UTType].self)
    }
}
#endif
