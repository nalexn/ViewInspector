import SwiftUI

public extension ViewType {
    
    struct Image: KnownViewType {
        public static let typePrefix: String = "Image"
    }
}

public extension Image {
    
    func inspect() throws -> InspectableView<ViewType.Image> {
        return try InspectableView<ViewType.Image>(self)
    }
}

// MARK: - SingleViewContent

public extension InspectableView where View: SingleViewContent {
    
    func image() throws -> InspectableView<ViewType.Image> {
        let content = try View.content(view: view)
        return try InspectableView<ViewType.Image>(content)
    }
}

// MARK: - MultipleViewContent

public extension InspectableView where View: MultipleViewContent {
    
    func image(_ index: Int) throws -> InspectableView<ViewType.Image> {
        let content = try contentView(at: index)
        return try InspectableView<ViewType.Image>(content)
    }
}

// MARK: - Custom Attributes

public extension InspectableView where View == ViewType.Image {
    
    func imageName() throws -> String? {
        return try Inspector
            .attribute(path: "provider|base|name", value: view) as? String
    }
    #if os(iOS) || os(watchOS) || os(tvOS)
    func uiImage() throws -> UIImage? {
        return try Inspector
            .attribute(path: "provider|base", value: view) as? UIImage
    }
    #else
    func nsImage() throws -> NSImage? {
        return try Inspector
            .attribute(path: "provider|base", value: view) as? NSImage
    }
    #endif
}
