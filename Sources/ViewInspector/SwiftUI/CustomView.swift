import SwiftUI

public extension ViewType {
    
    struct Custom<T>: KnownViewType, GenericViewType where T: Inspectable {
        public static var typePrefix: String {
            return Inspector.typeName(type: T.self)
        }
    }
}

public extension View where Self: Inspectable {
    
    func inspect() throws -> InspectableView<ViewType.Custom<Self>> {
        return try InspectableView<ViewType.Custom<Self>>(self)
    }
}

// MARK: - SingleViewContent

extension ViewType.Custom: SingleViewContent {
    
    public static func content(view: Any) throws -> Any {
        guard let body = (view as? Inspectable)?.content else {
            throw InspectionError.typeMismatch(view, T.self)
        }
        return body
    }
}

// MARK: - SingleViewContent

public extension InspectableView where View: SingleViewContent {
    
    func view<T>(_ type: T.Type) throws -> InspectableView<ViewType.Custom<T>>
        where T: Inspectable {
        let content = try View.content(view: view)
        let prefix = Inspector.typeName(type: type)
        try Inspector.guardType(value: content, prefix: prefix)
        return try InspectableView<ViewType.Custom<T>>(content)
    }
}

// MARK: - MultipleViewContent

public extension InspectableView where View: MultipleViewContent {
    
    func view<T>(_ type: T.Type, _ index: Int) throws -> InspectableView<ViewType.Custom<T>>
        where T: Inspectable {
        let content = try contentView(at: index)
        let prefix = Inspector.typeName(type: type)
        try Inspector.guardType(value: content, prefix: prefix)
        return try InspectableView<ViewType.Custom<T>>(content)
    }
}

// MARK: - Custom Attributes

public extension InspectableView where View: GenericViewType {
    
    func actualView() throws -> View.T {
        guard let casted = view as? View.T else {
            throw InspectionError.typeMismatch(view, View.T.self)
        }
        return casted
    }
}
