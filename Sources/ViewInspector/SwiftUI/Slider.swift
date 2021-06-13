import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension ViewType {
    
    struct Slider: KnownViewType {
        public static var typePrefix: String = "Slider"
    }
}

// MARK: - Extraction from SingleViewContent parent

@available(iOS 13.0, macOS 10.15, *)
@available(tvOS, unavailable)
public extension InspectableView where View: SingleViewContent {
    
    func slider() throws -> InspectableView<ViewType.Slider> {
        return try .init(try child(), parent: self)
    }
}

// MARK: - Extraction from MultipleViewContent parent

@available(iOS 13.0, macOS 10.15, *)
@available(tvOS, unavailable)
public extension InspectableView where View: MultipleViewContent {
    
    func slider(_ index: Int) throws -> InspectableView<ViewType.Slider> {
        return try .init(try child(at: index), parent: self, index: index)
    }
}

// MARK: - Non Standard Children

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension ViewType.Slider: SupplementaryChildrenLabelView { }

// MARK: - Custom Attributes

@available(iOS 13.0, macOS 10.15, *)
@available(tvOS, unavailable)
public extension InspectableView where View == ViewType.Slider {
    
    func labelView() throws -> InspectableView<ViewType.ClassifiedView> {
        return try View.supplementaryChildren(self).element(at: 0)
            .asInspectableView(ofType: ViewType.ClassifiedView.self)
    }
    
    func value() throws -> Double {
        return try valueBinding().wrappedValue
    }
    
    func setValue(_ value: Double) throws {
        try guardIsResponsive()
        try valueBinding().wrappedValue = value
    }
    
    private func valueBinding() throws -> Binding<Double> {
        return try Inspector
            .attribute(label: "_value", value: content.view, type: Binding<Double>.self)
    }
    
    func callOnEditingChanged() throws {
        typealias Callback = (Bool) -> Void
        let callback = try Inspector
            .attribute(label: "onEditingChanged", value: content.view, type: Callback.self)
        callback(false)
    }
}
