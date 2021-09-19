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
    private struct Allocator {
        let binding: Binding<Bool>
        init(isOn: Bool) {
            self.binding = .init(wrappedValue: isOn)
        }
    }
    init(isOn: Bool) {
        self = unsafeBitCast(Allocator(isOn: isOn), to: Self.self)
    }
}
