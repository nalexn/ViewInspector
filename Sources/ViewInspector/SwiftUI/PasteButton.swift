import SwiftUI
import UniformTypeIdentifiers.UTType

#if os(macOS)
public extension ViewType {
    
    struct PasteButton: KnownViewType {
        public static var typePrefix: String = "PasteButton"
    }
}

// MARK: - Extraction from SingleViewContent parent

public extension InspectableView where View: SingleViewContent {
    
    func pasteButton() throws -> InspectableView<ViewType.PasteButton> {
        return try .init(try child())
    }
}

// MARK: - Extraction from MultipleViewContent parent

public extension InspectableView where View: MultipleViewContent {
    
    func pasteButton(_ index: Int) throws -> InspectableView<ViewType.PasteButton> {
        return try .init(try child(at: index))
    }
}

// MARK: - Custom Attributes

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
