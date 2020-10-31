import SwiftUI

public extension ViewType {
    
    struct ProgressView: KnownViewType {
        public static var typePrefix: String = "ProgressView"
    }
}

// MARK: - Extraction from SingleViewContent parent

@available(iOS 14.0, macOS 11.0, tvOS 14.0, *)
public extension InspectableView where View: SingleViewContent {
    
    func progressView() throws -> InspectableView<ViewType.ProgressView> {
        return try .init(try child())
    }
}

// MARK: - Extraction from MultipleViewContent parent

@available(iOS 14.0, macOS 11.0, tvOS 14.0, *)
public extension InspectableView where View: MultipleViewContent {
    
    func progressView(_ index: Int) throws -> InspectableView<ViewType.ProgressView> {
        return try .init(try child(at: index))
    }
}

// MARK: - Custom Attributes

@available(iOS 14.0, macOS 11.0, tvOS 14.0, *)
public extension InspectableView where View == ViewType.ProgressView {
    
    func fractionCompleted() throws -> Double? {
        return try Inspector
            .attribute(path: "base|custom|fractionCompleted", value: content.view, type: Double?.self)
    }
    
    func progress() throws -> Progress {
        return try Inspector
            .attribute(path: "base|observing|_progress|wrappedValue|base",
                       value: content.view, type: Progress.self)
    }
    
    func labelView() throws -> InspectableView<ViewType.ClassifiedView> {
        let view = try Inspector.attribute(path: "base|custom|label|some", value: content.view)
        return try .init(try Inspector.unwrap(content: Content(view)))
    }
    
    func currentValueLabelView() throws -> InspectableView<ViewType.ClassifiedView> {
        let view = try Inspector.attribute(path: "base|custom|currentValueLabel|some", value: content.view)
        return try .init(try Inspector.unwrap(content: Content(view)))
    }
}
