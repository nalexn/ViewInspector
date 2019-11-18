import SwiftUI

public extension ViewType {
    
    struct DatePicker: KnownViewType {
        public static let typePrefix: String = "DatePicker"
    }
}

public extension DatePicker {
    
    func inspect() throws -> InspectableView<ViewType.DatePicker> {
        return try InspectableView<ViewType.DatePicker>(self)
    }
}

// MARK: - SingleViewContent

extension ViewType.DatePicker: SingleViewContent {
    
    public static func content(view: Any) throws -> Any {
        return try Inspector.attribute(label: "label", value: view)
    }
}

// MARK: - SingleViewContent

public extension InspectableView where View: SingleViewContent {
    
    func datePicker() throws -> InspectableView<ViewType.DatePicker> {
        let content = try View.content(view: view)
        return try InspectableView<ViewType.DatePicker>(content)
    }
}

// MARK: - MultipleViewContent

public extension InspectableView where View: MultipleViewContent {
    
    func datePicker(_ index: Int) throws -> InspectableView<ViewType.DatePicker> {
        let content = try contentView(at: index)
        return try InspectableView<ViewType.DatePicker>(content)
    }
}

// MARK: - Custom Attributes

public extension InspectableView where View == ViewType.DatePicker {
    
    func date() throws -> Binding<Date> {
        let selection = try? Inspector.attribute(label: "selection", value: view)
        typealias Result = Binding<Date>
        guard let binding = selection as? Result else {
            throw InspectionError.typeMismatch(selection, Result.self)
        }
        return binding
    }
}
