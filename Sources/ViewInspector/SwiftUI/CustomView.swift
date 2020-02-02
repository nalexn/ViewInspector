import SwiftUI

public extension ViewType {
    
    struct View<T>: KnownViewType, CustomViewType where T: Inspectable {
        public static var typePrefix: String {
            return Inspector.typeName(type: T.self)
        }
    }
}

public extension View where Self: Inspectable {
    
    func inspect() throws -> InspectableView<ViewType.View<Self>> {
        return try .init(ViewInspector.Content(self))
    }
}

// MARK: - Content Extraction

extension ViewType.View: SingleViewContent {
    
    public static func child(_ content: Content) throws -> Content {
        guard let body = (content.view as? Inspectable)?.content else {
            throw InspectionError.typeMismatch(content.view, T.self)
        }
        return try Inspector.unwrap(view: body, modifiers: [])
    }
}

// MARK: - Extraction from SingleViewContent parent

public extension InspectableView where View: SingleViewContent {
    
    func view<T>(_ type: T.Type) throws -> InspectableView<ViewType.View<T>>
        where T: Inspectable {
            let child = try View.child(content)
            let prefix = Inspector.typeName(type: type)
            try Inspector.guardType(value: child.view, prefix: prefix)
            return try .init(child)
    }
}

// MARK: - Extraction from MultipleViewContent parent

public extension InspectableView where View: MultipleViewContent {
    
    func view<T>(_ type: T.Type, _ index: Int) throws -> InspectableView<ViewType.View<T>>
        where T: Inspectable {
            let content = try child(at: index)
            let prefix = Inspector.typeName(type: type)
            try Inspector.guardType(value: content.view, prefix: prefix)
            return try .init(content)
    }
}

// MARK: - Custom Attributes

public extension InspectableView where View: CustomViewType {
    
    func actualView() throws -> View.T {
        guard let casted = content.view as? View.T else {
            throw InspectionError.typeMismatch(content.view, View.T.self)
        }
        return casted
    }
}

#if os(macOS)
public extension NSViewRepresentable where Self: Inspectable {
    func nsView() throws -> NSViewType {
        return try ViewHosting.lookup(Self.self)
    }
}
#else
public extension UIViewRepresentable where Self: Inspectable {
    func uiView() throws -> UIViewType {
        return try ViewHosting.lookup(Self.self)
    }
}
#endif
