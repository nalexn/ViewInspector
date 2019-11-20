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

// MARK: - Content Extraction

extension ViewType.DatePicker: SingleViewContent {
    
    public static func content(view: Any, envObject: Any) throws -> Any {
        let view = try Inspector.attribute(label: "label", value: view)
        return try Inspector.unwrap(view: view)
    }
}

// MARK: - Extraction from SingleViewContent parent

public extension InspectableView where View: SingleViewContent {
    
    func datePicker() throws -> InspectableView<ViewType.DatePicker> {
        let content = try View.content(view: view, envObject: envObject)
        return try InspectableView<ViewType.DatePicker>(content)
    }
}

// MARK: - Extraction from MultipleViewContent parent

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
