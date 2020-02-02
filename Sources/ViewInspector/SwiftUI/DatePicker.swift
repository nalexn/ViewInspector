import SwiftUI

#if os(iOS) || os(macOS)

public extension ViewType {
    
    struct DatePicker: KnownViewType {
        public static let typePrefix: String = "DatePicker"
    }
}

// MARK: - Content Extraction

extension ViewType.DatePicker: SingleViewContent {
    
    public static func child(_ content: Content) throws -> Content {
        let view = try Inspector.attribute(label: "label", value: content.view)
        return try Inspector.unwrap(view: view, modifiers: [])
    }
}

// MARK: - Extraction from SingleViewContent parent

public extension InspectableView where View: SingleViewContent {
    
    func datePicker() throws -> InspectableView<ViewType.DatePicker> {
        return try .init(try child())
    }
}

// MARK: - Extraction from MultipleViewContent parent

public extension InspectableView where View: MultipleViewContent {
    
    func datePicker(_ index: Int) throws -> InspectableView<ViewType.DatePicker> {
        return try .init(try child(at: index))
    }
}

#endif
