import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension ViewType {
    
    struct Spacer: KnownViewType {
        public static var typePrefix: String = "Spacer"
    }
}

// MARK: - Extraction from SingleViewContent parent

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView where View: SingleViewContent {
    
    func spacer() throws -> InspectableView<ViewType.Spacer> {
        return try .init(try child(), parent: self)
    }
}

// MARK: - Extraction from MultipleViewContent parent

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView where View: MultipleViewContent {
    
    func spacer(_ index: Int) throws -> InspectableView<ViewType.Spacer> {
        return try .init(try child(at: index), parent: self, index: index)
    }
}

// MARK: - Custom Attributes

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView where View == ViewType.Spacer {
    
    func minLength() throws -> CGFloat? {
        return try Inspector
            .attribute(label: "minLength", value: content.view, type: CGFloat?.self)
    }
}
