import SwiftUI

public extension ViewType {
    
    struct ColorPicker: KnownViewType {
        public static var typePrefix: String = "ColorPicker"
    }
}

// MARK: - Extraction from SingleViewContent parent

@available(iOS 14.0, macOS 11.0, *)
public extension InspectableView where View: SingleViewContent {
    
    func colorPicker() throws -> InspectableView<ViewType.ColorPicker> {
        return try .init(try child())
    }
}

// MARK: - Extraction from MultipleViewContent parent

@available(iOS 14.0, macOS 11.0, *)
public extension InspectableView where View: MultipleViewContent {
    
    func colorPicker(_ index: Int) throws -> InspectableView<ViewType.ColorPicker> {
        return try .init(try child(at: index))
    }
}

// MARK: - Custom Attributes

@available(iOS 14.0, macOS 11.0, *)
public extension InspectableView where View == ViewType.ColorPicker {
    
    func labelView() throws -> InspectableView<ViewType.ClassifiedView> {
        let view = try Inspector.attribute(label: "label", value: content.view)
        return try .init(try Inspector.unwrap(content: Content(view)))
    }
}
