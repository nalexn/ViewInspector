import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension ViewType {
    
    struct Toggle: KnownViewType {
        public static var typePrefix: String = "Toggle"
    }
}

// MARK: - Extraction from SingleViewContent parent

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView where View: SingleViewContent {
    
    func toggle() throws -> InspectableView<ViewType.Toggle> {
        return try .init(try child(), parent: self)
    }
}

// MARK: - Extraction from MultipleViewContent parent

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView where View: MultipleViewContent {
    
    func toggle(_ index: Int) throws -> InspectableView<ViewType.Toggle> {
        return try .init(try child(at: index), parent: self, index: index)
    }
}

// MARK: - Non Standard Children

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension ViewType.Toggle: SupplementaryChildrenLabelView {
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
public extension InspectableView where View == ViewType.Toggle {
    
    func labelView() throws -> InspectableView<ViewType.ClassifiedView> {
        return try View.supplementaryChildren(self).element(at: 0)
            .asInspectableView(ofType: ViewType.ClassifiedView.self)
    }
    
    func tap() throws {
        try guardIsResponsive()
        try isOnBinding().wrappedValue.toggle()
    }
    
    func isOn() throws -> Bool {
        return try isOnBinding().wrappedValue
    }
    
    private func isOnBinding() throws -> Binding<Bool> {
        if #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *) {
            throw InspectionError.notSupported(
                """
                Toggle's tap() and isOn() are currently unavailable for \
                inspection on iOS 16. Situation may change with a minor \
                OS version update. In the meanwhile, please add XCTSkip \
                for iOS 16 and use an earlier OS version for testing.
                """)
        }
        if let binding = try? Inspector
            .attribute(label: "__isOn", value: content.view, type: Binding<Bool>.self) {
            return binding
        }
        return try Inspector
            .attribute(label: "_isOn", value: content.view, type: Binding<Bool>.self)
    }
}

// MARK: - Global View Modifiers

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView {

    func toggleStyle() throws -> Any {
        let modifier = try self.modifier({ modifier -> Bool in
            return modifier.modifierType.hasPrefix("ToggleStyleModifier")
        }, call: "toggleStyle")
        return try Inspector.attribute(path: "modifier|style", value: modifier)
    }
}

// MARK: - ToggleStyle inspection

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension ToggleStyle {
    func inspect(isOn: Bool) throws -> InspectableView<ViewType.ClassifiedView> {
        let config = ToggleStyleConfiguration(isOn: isOn)
        let view = try makeBody(configuration: config).inspect()
        return try .init(view.content, parent: nil, index: nil)
    }
}

// MARK: - Style Configuration initializer

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
internal extension ToggleStyleConfiguration {
    private struct Allocator17 {
        let isOn: Binding<Bool>
        init(isOn: Bool) {
            self.isOn = .init(wrappedValue: isOn)
        }
    }
    private struct Allocator42 {
        let isOn: Binding<Bool>
        let isMixed = Binding<Bool>(wrappedValue: false)
        let flag: Bool = false
        
        init(isOn: Bool) {
            self.isOn = .init(wrappedValue: isOn)
        }
    }
    private struct Allocator96 {
        let isOn: Binding<Bool>
        let buffer1: (Int64, Int64) = (0, 0)
        let isMixed = Binding<Bool>(wrappedValue: false)
        let buffer2: (Int64, Int64, Int64, Int64) = (0, 0, 0, 0)
        
        init(isOn: Bool) {
            self.isOn = .init(wrappedValue: isOn)
        }
    }
    init(isOn: Bool) {
        switch MemoryLayout<Self>.size {
        case 17:
            self = unsafeBitCast(Allocator17(isOn: isOn), to: Self.self)
        case 42:
            self = unsafeBitCast(Allocator42(isOn: isOn), to: Self.self)
        case 96:
            self = unsafeBitCast(Allocator96(isOn: isOn), to: Self.self)
        default:
            fatalError(MemoryLayout<Self>.actualSize())
        }
    }
}
