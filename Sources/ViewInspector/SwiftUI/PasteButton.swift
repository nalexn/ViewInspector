import SwiftUI
import UniformTypeIdentifiers.UTType

#if os(macOS)
@available(macOS 10.15, *)
@available(iOS, unavailable)
@available(tvOS, unavailable)
public extension ViewType {
    
    struct PasteButton: KnownViewType {
        public static var typePrefix: String = "PasteButton"
    }
}

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
        return try .init(try child(at: index), parent: self)
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
        return try Inspector
            .attribute(label: "supportedContentTypes", value: content.view, type: [UTType].self)
    }
}
#endif
