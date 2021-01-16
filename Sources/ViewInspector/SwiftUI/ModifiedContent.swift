import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension ViewType {
    
    struct ModifiedContent: KnownViewType {
        public static var typePrefix: String = "ModifiedContent"
    }
    
    struct ViewModifierContent: KnownViewType {
        public static var typePrefix: String = "_ViewModifier_Content"
    }
}

// MARK: - Extraction from SingleViewContent parent

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView where View: SingleViewContent {
    
    func viewModifierContent() throws -> InspectableView<ViewType.ViewModifierContent> {
        return try .init(try child(), parent: self)
    }
}

// MARK: - Extraction from MultipleViewContent parent

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView where View: MultipleViewContent {
    
    func viewModifierContent(_ index: Int) throws -> InspectableView<ViewType.ViewModifierContent> {
        return try .init(try child(at: index), parent: self, index: index)
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView {
    
    func modifier<T>(_ type: T.Type) throws -> InspectableView<ViewType.ClassifiedView>
    where T: ViewModifier, T: Inspectable {
        let name = Inspector.typeName(type: type)
        guard let modifier = content.modifiers.compactMap({ modifier in
            try? Inspector.attribute(label: "modifier", value: modifier, type: type)
        }).first else {
            throw InspectionError.modifierNotFound(parent: Inspector.typeName(value: content.view),
                                                   modifier: name)
        }
        let content = try Inspector.unwrap(view: try modifier.extractContent(), modifiers: [])
        let call = "modifier(\(name).self)"
        return try .init(content, parent: self, call: call)
    }
}

// MARK: - ModifiedContent Child Extraction

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension ViewType.ModifiedContent: SingleViewContent {
    
    public static func child(_ content: Content) throws -> Content {
        let view = try Inspector.attribute(label: "content", value: content.view)
        return try Inspector.unwrap(view: view, modifiers: content.modifiers + [content.view])
    }
}
