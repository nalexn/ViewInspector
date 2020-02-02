import SwiftUI

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
    
    func supportedTypes() throws -> [String] {
        return try Inspector
            .attribute(label: "supportedTypes", value: content.view, type: [String].self)
    }
}
#endif
