import SwiftUI

public extension ViewType {
    
    struct TextEditor: KnownViewType {
        public static var typePrefix: String = "TextEditor"
    }
}

// MARK: - Extraction from SingleViewContent parent

@available(iOS 14.0, macOS 11.0, *)
@available(tvOS, unavailable)
public extension InspectableView where View: SingleViewContent {
    
    func textEditor() throws -> InspectableView<ViewType.TextEditor> {
        return try .init(try child())
    }
}

// MARK: - Extraction from MultipleViewContent parent

@available(iOS 14.0, macOS 11.0, *)
@available(tvOS, unavailable)
public extension InspectableView where View: MultipleViewContent {
    
    func textEditor(_ index: Int) throws -> InspectableView<ViewType.TextEditor> {
        return try .init(try child(at: index))
    }
}
