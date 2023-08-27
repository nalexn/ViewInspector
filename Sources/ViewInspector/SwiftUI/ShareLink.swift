import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension ViewType {
    
    struct ShareLink: KnownViewType {
        public static var typePrefix: String = "ShareLink"
    }
}

// MARK: - Extraction from SingleViewContent parent

@available(iOS 16.0, macOS 13.0, watchOS 9.0, *)
@available(tvOS, unavailable)
public extension InspectableView where View: SingleViewContent {
    
    func shareLink() throws -> InspectableView<ViewType.ShareLink> {
        return try .init(try child(), parent: self)
    }
}

// MARK: - Extraction from MultipleViewContent parent

@available(iOS 16.0, macOS 13.0, watchOS 9.0, *)
@available(tvOS, unavailable)
public extension InspectableView where View: MultipleViewContent {
    
    func shareLink(_ index: Int) throws -> InspectableView<ViewType.ShareLink> {
        return try .init(try child(at: index), parent: self, index: index)
    }
}

// MARK: - Non Standard Children

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension ViewType.ShareLink: SupplementaryChildren {
    static func supplementaryChildren(_ parent: UnwrappedView) throws -> LazyGroup<SupplementaryView> {
        guard #available(iOS 16.0, macOS 13.0, watchOS 9.0, *)
        else { return .empty }
        return .init(count: 3) { index in
            let medium = parent.content.medium.resettingViewModifiers()
            switch index {
            case 0:
                var view = try Inspector.attribute(label: "label", value: parent.content.view)
                if Inspector.typeName(value: view) == "DefaultShareLinkLabel" {
                    view = try Inspector.attribute(label: "text", value: view)
                }
                let content = try Inspector.unwrap(content: Content(view, medium: medium))
                return try InspectableView<ViewType.ClassifiedView>(
                    content, parent: parent, call: "labelView()")
            case 1:
                let view = try Inspector.attribute(path: "message|some", value: parent.content.view)
                let content = try Inspector.unwrap(content: Content(view, medium: medium))
                return try InspectableView<ViewType.Text>(content, parent: parent, call: "messageView()")
            default:
                let view = try Inspector.attribute(path: "subject|some", value: parent.content.view)
                let content = try Inspector.unwrap(content: Content(view, medium: medium))
                return try InspectableView<ViewType.Text>(content, parent: parent, call: "subjectView()")
            }
        }
    }
}

// MARK: - Custom Attributes

@available(iOS 16.0, macOS 13.0, watchOS 9.0, *)
@available(tvOS, unavailable)
public extension InspectableView where View == ViewType.ShareLink {
    
    func item<T>(type: T.Type) throws -> T {
        do {
            return try Inspector.attribute(
                path: "items|element", value: content.view, type: type)
        } catch {
            switch error as? InspectionError {
            case .attributeNotFound:
                throw InspectionError.notSupported(
                    "ShareLink has multiple items. Please use items() instead of item(type:)")
            default:
                throw error
            }
        }
    }
    
    func items() throws -> Any {
        return try Inspector.attribute(label: "items", value: content.view)
    }
    
    func labelView() throws -> InspectableView<ViewType.ClassifiedView> {
        return try View.supplementaryChildren(self).element(at: 0)
            .asInspectableView(ofType: ViewType.ClassifiedView.self)
    }
    
    func messageView() throws -> InspectableView<ViewType.Text> {
        return try View.supplementaryChildren(self).element(at: 1)
            .asInspectableView(ofType: ViewType.Text.self)
    }
    
    func subjectView() throws -> InspectableView<ViewType.Text> {
        return try View.supplementaryChildren(self).element(at: 2)
            .asInspectableView(ofType: ViewType.Text.self)
    }
    
    func sharePreview<DataElement, PreviewImage, PreviewIcon>(
        for element: DataElement, imageType: PreviewImage.Type, iconType: PreviewIcon.Type
    ) throws -> SharePreview<PreviewImage, PreviewIcon> {
        typealias Preview = (DataElement) -> SharePreview<PreviewImage, PreviewIcon>
        let preview = try Inspector.attribute(path: "preview|some", value: content.view, type: Preview.self)
        return preview(element)
    }
}

@available(iOS 16.0, macOS 13.0, watchOS 9.0, *)
@available(tvOS, unavailable)
public extension SharePreview {
    
    func title() throws -> InspectableView<ViewType.Text> {
        let text = try Inspector.attribute(path: "title|some", value: self, type: Text.self)
        return try .init(Content(text), parent: nil)
    }
    
    func image() throws -> Image {
        return try Inspector.attribute(path: "image|some", value: self, type: Image.self)
    }
    
    func icon() throws -> Icon {
        return try Inspector.attribute(path: "icon|some", value: self, type: Icon.self)
    }
}
