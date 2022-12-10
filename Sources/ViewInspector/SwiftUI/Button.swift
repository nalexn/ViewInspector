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
    static var labelViewPath: String {
        if #available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *) {
            return "label"
        } else {
            return "_label"
        }
    }
}

// MARK: - Custom Attributes

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView where View == ViewType.Button {
    
    func labelView() throws -> InspectableView<ViewType.ClassifiedView> {
        return try View.supplementaryChildren(self).element(at: 0)
            .asInspectableView(ofType: ViewType.ClassifiedView.self)
    }
    
    func tap() throws {
        try guardIsResponsive()
        typealias Callback = () -> Void
        let callback = try Inspector
            .attribute(label: "action", value: content.view, type: Callback.self)
        callback()
    }
    
    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
    func role() throws -> ButtonRole? {
        return try Inspector.attribute(
            label: "role", value: content.view, type: ButtonRole?.self)
    }
}

// MARK: - Global View Modifiers

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView {

    func buttonStyle() throws -> Any {
        let modifier = try self.modifier({ modifier -> Bool in
            return [
                "ButtonStyleContainerModifier",
                "ButtonStyleModifier",
            ].contains(where: { modifier.modifierType.hasPrefix($0) })
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
    private struct Allocator3 {
        let data: (Bool, Bool, Bool)
        init(flag: Bool) {
            data = (false, false, flag)
        }
    }
    private struct Allocator24 {
        let data: (Int64, Int64, Int64)
        init(flag: Bool) {
            data = (flag ? -1 : 0, 0, 0)
        }
    }
    init(isPressed: Bool) {
        switch MemoryLayout<Self>.size {
        case 3:
            self = unsafeBitCast(Allocator3(flag: isPressed), to: Self.self)
        case 24:
            self = unsafeBitCast(Allocator24(flag: isPressed), to: Self.self)
        default:
            fatalError(MemoryLayout<Self>.actualSize())
        }
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension PrimitiveButtonStyleConfiguration {
    private struct Allocator16 {
        let onTrigger: () -> Void
    }
    private struct Allocator24 {
        let buffer: Int8 = 0
        let onTrigger: () -> Void
    }
    init(onTrigger: @escaping () -> Void) {
        switch MemoryLayout<Self>.size {
        case 16:
            self = unsafeBitCast(Allocator16(onTrigger: onTrigger), to: Self.self)
        case 24:
            self = unsafeBitCast(Allocator24(onTrigger: onTrigger), to: Self.self)
        default:
            fatalError(MemoryLayout<Self>.actualSize())
        }
    }
}

internal extension MemoryLayout {
    static func actualSize() -> String {
        fatalError("New size of \(String(describing: type(of: T.self))) is \(Self.size)")
    }
}
