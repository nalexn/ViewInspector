import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension ViewType {

    struct VStack: KnownViewType {
        public static let typePrefix: String = "VStack"
    }
}

// MARK: - Content Extraction

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension ViewType.VStack: MultipleViewContent {

    public static func children(_ content: Content) throws -> LazyGroup<Content> {
        return try ViewType.HStack.children(content)
    }
}

// MARK: - Extraction from SingleViewContent parent

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView where View: SingleViewContent {

    func vStack() throws -> InspectableView<ViewType.VStack> {
        return try .init(try child(), parent: self)
    }
}

// MARK: - Extraction from MultipleViewContent parent

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView where View: MultipleViewContent {

    func vStack(_ index: Int) throws -> InspectableView<ViewType.VStack> {
        return try .init(try child(at: index), parent: self, index: index)
    }
}

// MARK: - Custom Attributes

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView where View == ViewType.VStack {

    func spacing() throws -> CGFloat? {
        return try Inspector.attribute(
            path: "spacing", value: vStackLayout(), type: CGFloat?.self)
    }

    func alignment() throws -> HorizontalAlignment? {
        return try Inspector.attribute(
            path: "alignment", value: vStackLayout(), type: HorizontalAlignment?.self)
    }

    private func vStackLayout() throws -> Any {
        return try Inspector.attribute(path: "_tree|root", value: content.view)
    }
}
