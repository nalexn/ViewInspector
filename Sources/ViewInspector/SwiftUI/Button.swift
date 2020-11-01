import SwiftUI

public extension ViewType {
    
    struct Button: KnownViewType {
        public static var typePrefix: String = "Button"
    }
}

// MARK: - Extraction from SingleViewContent parent

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView where View: SingleViewContent {
    
    func button() throws -> InspectableView<ViewType.Button> {
        return try .init(try child())
    }
}

// MARK: - Extraction from MultipleViewContent parent

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView where View: MultipleViewContent {
    
    func button(_ index: Int) throws -> InspectableView<ViewType.Button> {
        return try .init(try child(at: index))
    }
}

// MARK: - Custom Attributes

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView where View == ViewType.Button {
    
    func labelView() throws -> InspectableView<ViewType.ClassifiedView> {
        let view = try Inspector.attribute(label: "_label", value: content.view)
        return try .init(try Inspector.unwrap(content: Content(view)))
    }
    
    @available(*, deprecated, message: "Please use .labelView().text() instead")
    func text() throws -> InspectableView<ViewType.Text> {
        return try labelView().text()
    }
    
    func tap() throws {
        let action = try Inspector.attribute(label: "action", value: content.view)
        typealias Callback = () -> Void
        if let callback = action as? Callback {
            callback()
        }
    }
}

// MARK: - Global View Modifiers

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView {

    func buttonStyle() throws -> Any {
        let modifier = try self.modifier({ modifier -> Bool in
            return modifier.modifierType.hasPrefix("ButtonStyleModifier")
        }, call: "buttonStyle")
        if let style = try? Inspector.attribute(path: "modifier|style|style", value: modifier) {
            return style
        }
        return try Inspector.attribute(path: "modifier|style", value: modifier)
    }
}

// MARK: - ButtonStyle and PrimitiveButtonStyle inspection

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension ButtonStyle {
    func inspect(isPressed: Bool) throws -> InspectableView<ViewType.ButtonStyleLabel> {
        let config = ButtonStyleConfiguration(isPressed: isPressed)
        let view = try makeBody(configuration: config).inspect()
        return try .init(view.content)
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension PrimitiveButtonStyle {
    func inspect(onTrigger: @escaping () -> Void = { }) throws -> InspectableView<ViewType.ClassifiedView> {
        let config = PrimitiveButtonStyleConfiguration(onTrigger: onTrigger)
        return try makeBody(configuration: config).inspect()
    }
}

// MARK: - ButtonStyle.Label

public extension ViewType {
    
    struct ButtonStyleLabel: KnownViewType {
        public static var typePrefix: String = "Label"
    }
    
    struct PrimitiveButtonStyleLabel: KnownViewType {
        public static var typePrefix: String = "Label"
    }
}

// MARK: - Extraction from SingleViewContent parent

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView where View: SingleViewContent {
    
    func primitiveButtonStyleLabel() throws -> InspectableView<ViewType.PrimitiveButtonStyleLabel> {
        return try .init(try child())
    }
}

// MARK: - Extraction from MultipleViewContent parent

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView where View: MultipleViewContent {
    
    func primitiveButtonStyleLabel(_ index: Int) throws -> InspectableView<ViewType.PrimitiveButtonStyleLabel> {
        return try .init(try child(at: index))
    }
}

// MARK: - Style Configuration initializers

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
internal extension ButtonStyleConfiguration {
    private struct Allocator {
        let data: (Int64, Int64, Int64)
        init(flag: Bool) {
            data = (flag ? -1 : 0, 0, 0)
        }
    }
    init(isPressed: Bool) {
        self = unsafeBitCast(Allocator(flag: isPressed), to: Self.self)
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension PrimitiveButtonStyleConfiguration {
    private struct Allocator {
        let onTrigger: () -> Void
    }
    init(onTrigger: @escaping () -> Void) {
        self = unsafeBitCast(Allocator(onTrigger: onTrigger), to: Self.self)
    }
}
