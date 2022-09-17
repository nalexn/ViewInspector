import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension ViewType {
    
    struct Image: KnownViewType {
        public static let typePrefix: String = "Image"
    }
}

// MARK: - Extraction from SingleViewContent parent

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView where View: SingleViewContent {
    
    func image() throws -> InspectableView<ViewType.Image> {
        return try .init(try child(), parent: self)
    }
}

// MARK: - Extraction from MultipleViewContent parent

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView where View: MultipleViewContent {
    
    func image(_ index: Int) throws -> InspectableView<ViewType.Image> {
        return try .init(try child(at: index), parent: self, index: index)
    }
}

// MARK: - Non Standard Children

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension ViewType.Image: SupplementaryChildren {
    static func supplementaryChildren(_ parent: UnwrappedView) throws -> LazyGroup<SupplementaryView> {
        return .init(count: 1) { index in
            let image = try Inspector.cast(value: parent.content.view, type: Image.self)
                .rootImage()
            let labelView: Any = try {
                if let view = try? Inspector.attribute(path: "provider|base|label|some|text", value: image) {
                    return view
                }
                return try Inspector.attribute(path: "provider|base|label", value: image)
            }()
            let medium = parent.content.medium.resettingViewModifiers()
            let content = try Inspector.unwrap(content: Content(labelView, medium: medium))
            return try InspectableView<ViewType.ClassifiedView>(
                content, parent: parent, call: "labelView()")
        }
    }
}

// MARK: - Custom Attributes

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView where View == ViewType.Image {
    
    func actualImage() throws -> Image {
        return try Inspector.cast(value: content.view, type: Image.self)
    }
    
    func labelView() throws -> InspectableView<ViewType.Text> {
        let label = try View.supplementaryChildren(self).element(at: 0)
        if Inspector.typeName(value: label.content.view) == "AccessibilityImageLabel" {
            let name = try Inspector.attribute(label: "systemSymbol", value: label.content.view, type: String.self)
            let content = Content(Text(name), medium: label.content.medium)
            return try .init(content, parent: label.parentView)
        }
        if Inspector.typeName(value: label.content.view) == "ImageLabel" {
            let content = Content(Text(try actualImage().name()), medium: label.content.medium)
            return try .init(content, parent: label.parentView)
        }
        return try label.asInspectableView(ofType: ViewType.Text.self)
    }
}

// MARK: - Image

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension SwiftUI.Image {
    
    func rootImage() throws -> Image {
        return try Inspector.cast(value: imageContent().view, type: Image.self)
    }
    
    func name() throws -> String {
        return try Inspector
            .attribute(label: "name", value: rawImage(), type: String.self)
    }
    
    #if !os(macOS)
    func uiImage() throws -> UIImage {
        return try Inspector.cast(value: try rawImage(), type: UIImage.self)
    }
    #else
    func nsImage() throws -> NSImage {
        return try Inspector.cast(value: try rawImage(), type: NSImage.self)
    }
    #endif
    
    func cgImage() throws -> CGImage {
        return try Inspector
            .attribute(label: "image", value: rawImage(), type: CGImage.self)
    }
    
    func orientation() throws -> Image.Orientation {
        return try Inspector
            .attribute(label: "orientation", value: rawImage(), type: Image.Orientation.self)
    }
    
    func scale() throws -> CGFloat {
        return try Inspector
            .attribute(label: "scale", value: rawImage(), type: CGFloat.self)
    }
    
    private func rawImage() throws -> Any {
        return try Inspector.attribute(path: "provider|base", value: try imageContent().view)
    }
    
    private func imageContent() throws -> Content {
        return try Inspector.unwrap(image: self)
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
private extension Inspector {
    static func unwrap(image: Image) throws -> Content {
        let provider = try Inspector.attribute(path: "provider|base", value: image)
        if let child = try? Inspector.attribute(label: "base", value: provider, type: Image.self) {
            let content = try unwrap(image: child)
            let medium = content.medium.appending(viewModifier: provider)
            return Content(content.view, medium: medium)
        }
        return Content(image)
    }
}
