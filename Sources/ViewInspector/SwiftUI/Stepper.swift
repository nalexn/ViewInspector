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
extension ViewType.Stepper: SupplementaryChildren {
    static func supplementaryChildren(_ content: Content) throws -> LazyGroup<Content> {
        return .init(count: 1) { _ -> Content in
            let child = try Inspector.attribute(label: "label", value: content.view)
            return try Inspector.unwrap(content: Content(child))
        }
    }
}

// MARK: - Custom Attributes

@available(iOS 13.0, macOS 10.15, *)
@available(tvOS, unavailable)
public extension InspectableView where View == ViewType.Stepper {
    
    func labelView() throws -> InspectableView<ViewType.ClassifiedView> {
        let child = try View.supplementaryChildren(content).element(at: 0)
        return try .init(child, parent: self)
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
