import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension ViewType {
    
    struct ModifiedContent: KnownViewType {
        public static var typePrefix: String = "ModifiedContent"
        
        public static func inspectionCall(typeName: String) -> String {
            return "modifier(\(typeName).self)"
        }
    }
    
    struct ViewModifierContent: KnownViewType {
        public static var typePrefix: String = "_ViewModifier_Content"
        
        public static func inspectionCall(typeName: String) -> String {
            return "viewModifierContent(\(ViewType.indexPlaceholder))"
        }
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
        let modifierContent = try Inspector.unwrap(
            view: try modifier.extractContent(environmentObjects: content.heritage.environmentObjects),
            modifiers: [], heritage: content.heritage)
        let call = ViewType.ModifiedContent.inspectionCall(typeName: name)
        return try .init(modifierContent, parent: self, call: call)
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
internal extension Content {
    func customViewModifiers() -> [Inspectable] {
        return modifiers.compactMap({ modifier in
            try? Inspector.attribute(label: "modifier", value: modifier, type: Inspectable.self)
        })
    }
    
}

// MARK: - ModifiedContent Child Extraction

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension ViewType.ModifiedContent: SingleViewContent {
    
    public static func child(_ content: Content) throws -> Content {
        let view = try Inspector.attribute(label: "content", value: content.view)
        if Inspector.typeName(value: content.view)
            .contains("_EnvironmentKeyWritingModifier"),
           let object = try? Inspector.attribute(
            path: "modifier|value|some", value: content.view, type: AnyObject.self),
           !(object is NSObject) {
            return try Inspector.unwrap(view: view, modifiers: content.modifiers, heritage: content.heritage.appending(environmentObject: object))
        } else {
            return try Inspector.unwrap(view: view, modifiers: content.modifiers + [content.view], heritage: content.heritage)
        }
    }
}

// MARK: - ViewModifier content allocation

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
internal extension _ViewModifier_Content {
    private struct Allocator { }
    init() {
        self = unsafeBitCast(Allocator(), to: Self.self)
    }
}
