import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension ViewType {
    
    struct MultiDatePicker: KnownViewType {
        public static let typePrefix: String = "MultiDatePicker"
    }
}

// MARK: - Extraction from SingleViewContent parent

@available(iOS 16.0, *)
@available(macOS, unavailable)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
public extension InspectableView where View: SingleViewContent {
    
    func multiDatePicker() throws -> InspectableView<ViewType.MultiDatePicker> {
        return try .init(try child(), parent: self)
    }
}

// MARK: - Extraction from MultipleViewContent parent

@available(iOS 16.0, *)
@available(macOS, unavailable)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
public extension InspectableView where View: MultipleViewContent {
    
    func multiDatePicker(_ index: Int) throws -> InspectableView<ViewType.MultiDatePicker> {
        return try .init(try child(at: index), parent: self, index: index)
    }
}

// MARK: - Non Standard Children

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension ViewType.MultiDatePicker: SupplementaryChildrenLabelView { }

// MARK: - Custom Attributes

@available(iOS 16.0, *)
@available(macOS, unavailable)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
public extension InspectableView where View == ViewType.MultiDatePicker {
    
    func labelView() throws -> InspectableView<ViewType.ClassifiedView> {
        return try View.supplementaryChildren(self).element(at: 0)
            .asInspectableView(ofType: ViewType.ClassifiedView.self)
    }
    
    func select(dateComponents: Set<DateComponents>) throws {
        try guardIsResponsive()
        let binding = try Inspector.attribute(
            path: "_selection", value: content.view,
            type: Binding<Set<DateComponents>>.self)
        binding.wrappedValue = dateComponents
    }
    
    func minimumDate() throws -> Date? {
        return try Inspector.attribute(label: "minimumDate", value: content.view, type: Date?.self)
    }
    
    func maximumDate() throws -> Date? {
        return try Inspector.attribute(label: "maximumDate", value: content.view, type: Date?.self)
    }
}
