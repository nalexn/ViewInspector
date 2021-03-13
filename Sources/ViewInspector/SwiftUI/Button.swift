import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension ViewType {
    
    struct Button: KnownViewType {
        public static var typePrefix: String = "Button"
    }
}

// MARK: - Extraction from SingleViewContent parent

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView where View: SingleViewContent {
    
    func button() throws -> InspectableView<ViewType.Button> {
        return try .init(try child(), parent: self)
    }
}

// MARK: - Extraction from MultipleViewContent parent

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView where View: MultipleViewContent {
    
    func button(_ index: Int) throws -> InspectableView<ViewType.Button> {
        return try .init(try child(at: index), parent: self, index: index)
    }
}

// MARK: - Non Standard Children

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension ViewType.Button: SupplementaryChildrenLabelView {
    static var labelViewPath: String { "_label" }
}

// MARK: - Custom Attributes

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView where View == ViewType.Button {
    
    func labelView() throws -> InspectableView<ViewType.ClassifiedView> {
        return try View.supplementaryChildren(self).element(at: 0)
    }
    
    func tap() throws {
        typealias Callback = () -> Void
        let callback = try Inspector
            .attribute(label: "action", value: content.view, type: Callback.self)
        callback()
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
    func inspect(isPressed: Bool) throws -> InspectableView<ViewType.ClassifiedView> {
        let config = ButtonStyleConfiguration(isPressed: isPressed)
        let view = try makeBody(configuration: config).inspect()
        return try .init(view.content, parent: nil, index: nil)
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension PrimitiveButtonStyle {
    func inspect(onTrigger: @escaping () -> Void = { }) throws -> InspectableView<ViewType.ClassifiedView> {
        let config = PrimitiveButtonStyleConfiguration(onTrigger: onTrigger)
        return try makeBody(configuration: config).inspect()
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
