import SwiftUI

#if !os(tvOS)

public extension ViewType {
    
    struct Slider: KnownViewType {
        public static var typePrefix: String = "Slider"
    }
}

// MARK: - Content Extraction

extension ViewType.Slider: SingleViewContent {
    
    public static func child(_ content: Content) throws -> Content {
        let view = try Inspector.attribute(label: "label", value: content.view)
        return try Inspector.unwrap(view: view, modifiers: [])
    }
}

// MARK: - Extraction from SingleViewContent parent

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView where View: SingleViewContent {
    
    func slider() throws -> InspectableView<ViewType.Slider> {
        return try .init(try child())
    }
}

// MARK: - Extraction from MultipleViewContent parent

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView where View: MultipleViewContent {
    
    func slider(_ index: Int) throws -> InspectableView<ViewType.Slider> {
        return try .init(try child(at: index))
    }
}

// MARK: - Custom Attributes

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView where View == ViewType.Slider {
    
    func callOnEditingChanged() throws {
        let action = try Inspector.attribute(label: "onEditingChanged", value: content.view)
        typealias Callback = (Bool) -> Void
        if let callback = action as? Callback {
            callback(false)
        }
    }
}

#endif
