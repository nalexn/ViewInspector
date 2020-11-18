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

// MARK: - Global View Modifiers

@available(iOS 14.0, macOS 11.0, tvOS 14.0, *)
public extension InspectableView {

    func progressViewStyle() throws -> Any {
        let modifier = try self.modifier({ modifier -> Bool in
            return modifier.modifierType.hasPrefix("ProgressViewStyleModifier")
        }, call: "progressViewStyle")
        return try Inspector.attribute(path: "modifier|style", value: modifier)
    }
}

// MARK: - ProgressViewStyle inspection

@available(iOS 14.0, macOS 11.0, tvOS 14.0, *)
public extension ProgressViewStyle {
    func inspect(fractionCompleted: Double? = nil) throws -> InspectableView<ViewType.ClassifiedView> {
        let config = ProgressViewStyleConfiguration(fractionCompleted: fractionCompleted)
        let view = try makeBody(configuration: config).inspect()
        return try .init(view.content)
    }
}

// MARK: - Style Configuration initializer

@available(iOS 14.0, macOS 11.0, tvOS 14.0, *)
internal extension ProgressViewStyleConfiguration {
    private struct Allocator {
        let fractionCompleted: Double?
        let data: Int16 = 0
    }
    init(fractionCompleted: Double?) {
        self = unsafeBitCast(Allocator(fractionCompleted: fractionCompleted), to: Self.self)
    }
}
