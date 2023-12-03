import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
internal extension ViewType {
    struct PopoverContent { }
    struct WrappedContent { }
}

// MARK: - Content Extraction

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension ViewType.PopoverContent: SingleViewContent {

    static func child(_ content: Content) throws -> Content {
        let view = try Inspector.attribute(label: "content", value: content.view)
        return try Inspector.unwrap(view: view, medium: content.medium)
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension ViewType.WrappedContent: SingleViewContent {

    static func child(_ content: Content) throws -> Content {
        let closure = try Inspector.attribute(label: "popoverContent", value: content.view)
        // Closure's type is () -> 'consumer view type', which we cannot
        // cast to without asking for the type from the caller side.
        // Discontinuing support for now
        throw InspectionError.notSupported("Popover inspection support is discontinued for macOS 14")
    }
}
