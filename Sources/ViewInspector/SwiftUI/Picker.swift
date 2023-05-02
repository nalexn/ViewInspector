import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension ViewType {
    
    struct Picker: KnownViewType {
        public static let typePrefix: String = "Picker"
    }
}

// MARK: - Content Extraction

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension ViewType.Picker: MultipleViewContent {
    
    public static func children(_ content: Content) throws -> LazyGroup<Content> {
        let view = try Inspector.attribute(label: "content", value: content.view)
        return try Inspector.viewsInContainer(view: view, medium: content.medium)
    }
}

// MARK: - Extraction from SingleViewContent parent

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView where View: SingleViewContent {
    
    func picker() throws -> InspectableView<ViewType.Picker> {
        return try .init(try child(), parent: self)
    }
}

// MARK: - Extraction from MultipleViewContent parent

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView where View: MultipleViewContent {
    
    func picker(_ index: Int) throws -> InspectableView<ViewType.Picker> {
        return try .init(try child(at: index), parent: self, index: index)
    }
}

// MARK: - Non Standard Children

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension ViewType.Picker: SupplementaryChildrenLabelView { }

// MARK: - Custom Attributes

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView where View == ViewType.Picker {
    
    func labelView() throws -> InspectableView<ViewType.ClassifiedView> {
        return try View.supplementaryChildren(self).element(at: 0)
            .asInspectableView(ofType: ViewType.ClassifiedView.self)
    }
    
    func select<SelectionValue>(value: SelectionValue) throws where SelectionValue: Hashable {
        try guardIsResponsive()
        let bindings = try valueBindings(SelectionValue.self)
        bindings.forEach { $0.wrappedValue = value }
    }
    
    func selectedValue<SelectionValue>(_ type: SelectionValue.Type) throws -> SelectionValue {
        let bindings = try valueBindings(SelectionValue.self)
        guard let value = bindings.first else {
            throw InspectionError.attributeNotFound(
                label: "binding", type: Inspector.typeName(type: SelectionValue.self))
        }
        return value.wrappedValue
    }
    
    private func valueBindings<SelectionValue>(_ type: SelectionValue.Type, caller: StaticString = #function
    ) throws -> [Binding<SelectionValue>] {
        var bindings = try Inspector.attribute(path: "selection", value: content.view)
        if let single = bindings as? Binding<SelectionValue> {
            bindings = [single]
        }
        let typeName = Inspector.typeName(value: bindings)
        guard let casted = bindings as? [Binding<SelectionValue>] else {
            var endIndex = typeName.index(before: typeName.endIndex)
            if typeName.hasPrefix("Array") {
                endIndex = typeName.index(before: endIndex)
            }
            let expected = typeName[..<endIndex]
                .replacingOccurrences(of: "Array<Binding<", with: "")
                .replacingOccurrences(of: "Binding<", with: "")
            let factual = Inspector.typeName(type: SelectionValue.self)
            throw InspectionError
            .notSupported("\(caller) expected a value of type \(expected) but received \(factual)")
        }
        return casted
    }
}

// MARK: - Global View Modifiers

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView {

    func pickerStyle() throws -> Any {
        let modifier = try self.modifier({ modifier -> Bool in
            return modifier.modifierType.hasPrefix("PickerStyleWriter")
        }, call: "pickerStyle")
        return try Inspector.attribute(path: "modifier|style", value: modifier)
    }
}
