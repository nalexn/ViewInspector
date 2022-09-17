import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension ViewType {
    
    struct ProgressView: KnownViewType {
        public static var typePrefix: String = "ProgressView"
    }
}

// MARK: - Extraction from SingleViewContent parent

@available(iOS 14.0, macOS 11.0, tvOS 14.0, *)
public extension InspectableView where View: SingleViewContent {
    
    func progressView() throws -> InspectableView<ViewType.ProgressView> {
        return try .init(try child(), parent: self)
    }
}

// MARK: - Extraction from MultipleViewContent parent

@available(iOS 14.0, macOS 11.0, tvOS 14.0, *)
public extension InspectableView where View: MultipleViewContent {
    
    func progressView(_ index: Int) throws -> InspectableView<ViewType.ProgressView> {
        return try .init(try child(at: index), parent: self, index: index)
    }
}

// MARK: - Non Standard Children

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension ViewType.ProgressView: SupplementaryChildren {
    static func supplementaryChildren(_ parent: UnwrappedView) throws -> LazyGroup<SupplementaryView> {
        return .init(count: 2) { index in
            let medium = parent.content.medium.resettingViewModifiers()
            if index == 0 {
                let child = try Inspector.attribute(
                    path: "base|custom|label|some", value: parent.content.view)
                let content = try Inspector.unwrap(content: Content(child, medium: medium))
                return try InspectableView<ViewType.ClassifiedView>(
                    content, parent: parent, call: "labelView()")
            } else {
                let child = try Inspector.attribute(
                    path: "base|custom|currentValueLabel|some", value: parent.content.view)
                let content = try Inspector.unwrap(content: Content(child, medium: medium))
                return try InspectableView<ViewType.ClassifiedView>(
                    content, parent: parent, call: "currentValueLabelView()")
            }
        }
    }
}

// MARK: - Custom Attributes

@available(iOS 14.0, macOS 11.0, tvOS 14.0, *)
public extension InspectableView where View == ViewType.ProgressView {
    
    func fractionCompleted() throws -> Double? {
        do {
            return try Inspector
                .attribute(path: "base|custom|value|absolute|fractionCompleted",
                           value: content.view, type: Double?.self)
        } catch { }
        return try Inspector
            .attribute(path: "base|custom|fractionCompleted", value: content.view, type: Double?.self)
    }
    
    func progress() throws -> Progress {
        if let value = try? Inspector
            .attribute(path: "base|observing|_progress|wrappedValue|base",
                       value: content.view, type: Progress.self) {
            return value
        }
        return try Inspector
            .attribute(path: "base|observing|progress",
                       value: content.view, type: Progress.self)
    }
    
    func labelView() throws -> InspectableView<ViewType.ClassifiedView> {
        return try View.supplementaryChildren(self).element(at: 0)
            .asInspectableView(ofType: ViewType.ClassifiedView.self)
    }
    
    func currentValueLabelView() throws -> InspectableView<ViewType.ClassifiedView> {
        return try View.supplementaryChildren(self).element(at: 1)
            .asInspectableView(ofType: ViewType.ClassifiedView.self)
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

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
public extension ProgressViewStyle {
    func inspect(fractionCompleted: Double? = nil) throws -> InspectableView<ViewType.ClassifiedView> {
        let config = ProgressViewStyleConfiguration(fractionCompleted: fractionCompleted)
        let view = try makeBody(configuration: config).inspect()
        return try .init(view.content, parent: nil, index: nil)
    }
}

// MARK: - Style Configuration initializer

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
internal extension ProgressViewStyleConfiguration {
    private struct Allocator12 {
        let fractionCompleted: Double?
        let data: Int16 = 0
    }
    private struct Allocator36 {
        let head: (UInt64?, UInt32) = (nil, 0)
        let alwaysIndeterminate: Bool = false
        let fractionCompleted: Double?
        let tail: (Bool, Bool, Bool) = (false, false, false)
    }
    init(fractionCompleted: Double?) {
        switch MemoryLayout<Self>.size {
        case 12:
            self = unsafeBitCast(Allocator12(fractionCompleted: fractionCompleted), to: Self.self)
        case 36:
            self = unsafeBitCast(Allocator36(fractionCompleted: fractionCompleted), to: Self.self)
        default:
            fatalError(MemoryLayout<Self>.actualSize())
        }
    }
}
