import SwiftUI

@available(iOS 13.0, macOS 10.15, *)
@available(tvOS, unavailable)
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

// MARK: - Custom Attributes

@available(iOS 13.0, macOS 10.15, *)
@available(tvOS, unavailable)
public extension InspectableView where View == ViewType.Stepper {
    
    func labelView() throws -> InspectableView<ViewType.ClassifiedView> {
        let view = try Inspector.attribute(label: "label", value: content.view)
        return try .init(try Inspector.unwrap(content: Content(view)), parent: self)
    }
    
    @available(*, deprecated, message: "Please use .labelView().text() instead")
    func text() throws -> InspectableView<ViewType.Text> {
        return try labelView().text()
    }
    
    func increment() throws {
        let action = try Inspector.attribute(path: path(to: "onIncrement"), value: content.view)
        typealias Callback = () -> Void
        if let callback = action as? Callback {
            callback()
        }
    }
    
    func decrement() throws {
        let action = try Inspector.attribute(path: path(to: "onDecrement"), value: content.view)
        typealias Callback = () -> Void
        if let callback = action as? Callback {
            callback()
        }
    }
    
    func callOnEditingChanged() throws {
        let action = try Inspector.attribute(path: path(to: "onEditingChanged"), value: content.view)
        typealias Callback = (Bool) -> Void
        if let callback = action as? Callback {
            callback(false)
        }
    }
    
    private func path(to attribute: String) -> String {
        if #available(iOS 13.4, macOS 10.15.4, *) {
            return "configuration|\(attribute)"
        }
        return attribute
    }
}
