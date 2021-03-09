import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension ViewType {

    struct HStack: KnownViewType {
        public static let typePrefix: String = "HStack"
    }
}

// MARK: - Content Extraction

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension ViewType.HStack: MultipleViewContent {

    public static func children(_ content: Content) throws -> LazyGroup<Content> {
        let container = try Inspector.attribute(path: "_tree|content", value: content.view)
        return try Inspector.viewsInContainer(view: container, medium: content.medium)
    }
}

// MARK: - Extraction from SingleViewContent parent

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView where View: SingleViewContent {

    func hStack() throws -> InspectableView<ViewType.HStack> {
        return try .init(try child(), parent: self)
    }
}

// MARK: - Extraction from MultipleViewContent parent

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView where View: MultipleViewContent {

    func hStack(_ index: Int) throws -> InspectableView<ViewType.HStack> {
        return try .init(try child(at: index), parent: self, index: index)
    }
}

// MARK: - Custom Attributes

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView where View == ViewType.HStack {

    func spacing() throws -> CGFloat? {
        return try Inspector.attribute(
            path: "spacing", value: hStackLayout(), type: CGFloat?.self)
    }

    func alignment() throws -> VerticalAlignment? {
        return try Inspector.attribute(
            path: "alignment", value: hStackLayout(), type: VerticalAlignment?.self)
    }

    private func hStackLayout() throws -> Any {
        return try Inspector.attribute(path: "_tree|root", value: content.view)
    }
}
