import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension ViewType {
    
    struct SecureField: KnownViewType {
        public static var typePrefix: String = "SecureField"
    }
}

// MARK: - Extraction from SingleViewContent parent

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView where View: SingleViewContent {
    
    func secureField() throws -> InspectableView<ViewType.SecureField> {
        return try .init(try child(), parent: self)
    }
}

// MARK: - Extraction from MultipleViewContent parent

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView where View: MultipleViewContent {
    
    func secureField(_ index: Int) throws -> InspectableView<ViewType.SecureField> {
        return try .init(try child(at: index), parent: self, index: index)
    }
}

// MARK: - Non Standard Children

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension ViewType.SecureField: SupplementaryChildrenLabelView { }

// MARK: - Custom Attributes

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView where View == ViewType.SecureField {
    
    func labelView() throws -> InspectableView<ViewType.ClassifiedView> {
        return try View.supplementaryChildren(self).element(at: 0)
    }
    
    func input() throws -> String {
        return try inputBinding().wrappedValue
    }
    
    func setInput(_ value: String) throws {
        try inputBinding().wrappedValue = value
    }
    
    private func inputBinding() throws -> Binding<String> {
        return try Inspector.attribute(
            label: "text", value: content.view, type: Binding<String>.self)
    }
    
    func callOnCommit() throws {
        typealias Callback = () -> Void
        let callback = try Inspector
            .attribute(label: "onCommit", value: content.view, type: Callback.self)
        callback()
    }
}
