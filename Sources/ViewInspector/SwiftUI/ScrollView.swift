import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension ViewType {
    
    struct ScrollView: KnownViewType {
        public static var typePrefix: String = "ScrollView"
    }
}

// MARK: - Content Extraction

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension ViewType.ScrollView: SingleViewContent {
    
    public static func child(_ content: Content) throws -> Content {
        let view = try Inspector.attribute(label: "content", value: content.view)
        let medium = content.medium.resettingViewModifiers()
        return try Inspector.unwrap(view: view, medium: medium)
    }
}

// MARK: - Extraction from SingleViewContent parent

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView where View: SingleViewContent {
    
    func scrollView() throws -> InspectableView<ViewType.ScrollView> {
        return try .init(try child(), parent: self)
    }
}

// MARK: - Extraction from MultipleViewContent parent

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView where View: MultipleViewContent {
    
    func scrollView(_ index: Int) throws -> InspectableView<ViewType.ScrollView> {
        return try .init(try child(at: index), parent: self, index: index)
    }
}

// MARK: - Custom Attributes

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView where View == ViewType.ScrollView {
    
    func axes() throws -> Axis.Set {
        return try Inspector.attribute(
            path: "configuration|axes", value: content.view, type: Axis.Set.self)
    }
    
    func showsIndicators() throws -> Bool {
        if let value = try? Inspector.attribute(
            path: "configuration|indicators|initial", value: content.view, type: Bool.self) {
            return value
        }
        return try Inspector.attribute(
            path: "configuration|showsIndicators", value: content.view, type: Bool.self)
    }
    
    @available(*, deprecated, message: "ScrollView no longer provides this value")
    func contentInsets() throws -> EdgeInsets {
        return try Inspector.attribute(path: "configuration|contentInsets",
                                       value: content.view, type: EdgeInsets.self)
    }
}
