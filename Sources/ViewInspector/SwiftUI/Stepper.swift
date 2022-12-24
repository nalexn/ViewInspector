import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension ViewType {
    
    struct Stepper: KnownViewType {
        public static var typePrefix: String = "Stepper"
    }
}

// MARK: - Extraction from SingleViewContent parent

@available(iOS 13.0, macOS 10.15, *)
@available(tvOS, unavailable)
public extension InspectableView where View: SingleViewContent {
    
    func stepper() throws -> InspectableView<ViewType.Stepper> {
        return try .init(try child(), parent: self)
    }
}

// MARK: - Extraction from MultipleViewContent parent

@available(iOS 13.0, macOS 10.15, *)
@available(tvOS, unavailable)
public extension InspectableView where View: MultipleViewContent {
    
    func stepper(_ index: Int) throws -> InspectableView<ViewType.Stepper> {
        return try .init(try child(at: index), parent: self, index: index)
    }
}

// MARK: - Non Standard Children

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension ViewType.Stepper: SupplementaryChildrenLabelView { }

// MARK: - Custom Attributes

@available(iOS 13.0, macOS 10.15, *)
@available(tvOS, unavailable)
public extension InspectableView where View == ViewType.Stepper {
    
    func labelView() throws -> InspectableView<ViewType.ClassifiedView> {
        return try View.supplementaryChildren(self).element(at: 0)
            .asInspectableView(ofType: ViewType.ClassifiedView.self)
    }
    
    func increment() throws {
        try guardIsResponsive()
        typealias Callback = () -> Void
        let callback = try Inspector
            .attribute(path: path(to: "onIncrement"), value: content.view, type: Callback.self)
        callback()
    }
    
    func decrement() throws {
        try guardIsResponsive()
        typealias Callback = () -> Void
        let callback = try Inspector
            .attribute(path: path(to: "onDecrement"), value: content.view, type: Callback.self)
        callback()
    }
    
    func callOnEditingChanged() throws {
        typealias Callback = (Bool) -> Void
        let callback = try Inspector
            .attribute(path: path(to: "onEditingChanged"), value: content.view, type: Callback.self)
        callback(false)
    }
    
    private func path(to attribute: String) -> String {
        if #available(iOS 13.4, macOS 10.15.4, *) {
            return "configuration|\(attribute)"
        }
        return attribute
    }
}
