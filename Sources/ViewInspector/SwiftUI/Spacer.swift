import SwiftUI

public extension ViewType {
    
    struct Spacer: KnownViewType {
        public static var typePrefix: String = "Spacer"
    }
}

// MARK: - Extraction from SingleViewContent parent

public extension InspectableView where View: SingleViewContent {
    
    func spacer() throws -> InspectableView<ViewType.Spacer> {
        return try .init(try child())
    }
}

// MARK: - Extraction from MultipleViewContent parent

public extension InspectableView where View: MultipleViewContent {
    
    func spacer(_ index: Int) throws -> InspectableView<ViewType.Spacer> {
        return try .init(try child(at: index))
    }
}

// MARK: - Custom Attributes

public extension InspectableView where View == ViewType.Spacer {
    
    func minLength() throws -> CGFloat? {
        return try Inspector
            .attribute(label: "minLength", value: content.view, type: CGFloat?.self)
    }
}
