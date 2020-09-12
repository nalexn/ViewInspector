import SwiftUI

public extension ViewType {
    
    struct Image: KnownViewType {
        public static let typePrefix: String = "Image"
    }
}

// MARK: - Extraction from SingleViewContent parent

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView where View: SingleViewContent {
    
    func image() throws -> InspectableView<ViewType.Image> {
        return try .init(try child())
    }
}

// MARK: - Extraction from MultipleViewContent parent

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView where View: MultipleViewContent {
    
    func image(_ index: Int) throws -> InspectableView<ViewType.Image> {
        return try .init(try child(at: index))
    }
}

// MARK: - Custom Attributes

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView where View == ViewType.Image {
    
    func imageName() throws -> String? {
        return try Inspector.attribute(label: "name", value: image()) as? String
    }
    
    #if os(iOS) || os(watchOS) || os(tvOS)
    func uiImage() throws -> UIImage? {
        return try image() as? UIImage
    }
    #else
    func nsImage() throws -> NSImage? {
        return try image() as? NSImage
    }
    #endif
    
    func cgImage() throws -> CGImage? {
        let image = try Inspector.attribute(path: "provider|base|image", value: unwrap(view: content.view)) as CFTypeRef
        guard CFGetTypeID(image) == CGImage.typeID else {
            return nil
        }
        return unsafeDowncast(image, to: CGImage.self)
    }
    
    func orientation() throws -> Image.Orientation {
        return try Inspector
            .attribute(path: "provider|base|orientation",
                       value: unwrap(view: content.view),
                       type: Image.Orientation.self)
    }
    
    func scale() throws -> CGFloat {
        return try Inspector
            .attribute(path: "provider|base|scale",
                       value: unwrap(view: content.view),
                       type: CGFloat.self)
    }
    
    func label() throws -> InspectableView<ViewType.Text> {
        let view = try Inspector.attribute(path: "provider|base|label", value: content.view)
        return try .init(try Inspector.unwrap(view: view, modifiers: []))
    }
    
    private func image() throws -> Any {
        return try Inspector.attribute(path: "provider|base", value: unwrap(view: content.view))
    }
    
    private func unwrap(view: Any) -> Any {
        if let enclosed = try? Inspector.attribute(path: "provider|base|base", value: view) {
            return unwrap(view: enclosed)
        }
        return view
    }
}
