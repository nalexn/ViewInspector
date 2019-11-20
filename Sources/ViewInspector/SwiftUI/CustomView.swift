import SwiftUI

public extension ViewType {
    
    struct View<T>: KnownViewType, CustomViewType where T: Inspectable {
        public static var typePrefix: String {
            return Inspector.typeName(type: T.self)
        }
    }
    
    struct ViewWithEnvObject<T>: KnownViewType, CustomViewType where T: InspectableWithEnvObject {
        public static var typePrefix: String {
            return Inspector.typeName(type: T.self)
        }
    }
}

public extension View where Self: Inspectable {
    
    func inspect() throws -> InspectableView<ViewType.View<Self>> {
        return try InspectableView<ViewType.View<Self>>(self)
    }
}

public extension View where Self: InspectableWithEnvObject {
    
    func inspect(_ object: Object) throws -> InspectableView<ViewType.ViewWithEnvObject<Self>> {
        return try InspectableView<ViewType.ViewWithEnvObject<Self>>(self, envObject: object)
    }
}

// MARK: - Content Extraction

extension ViewType.View: SingleViewContent {
    
    public static func content(view: Any, envObject: Any) throws -> Any {
        guard let body = (view as? Inspectable)?.content else {
            throw InspectionError.typeMismatch(view, T.self)
        }
        return body
    }
}

extension ViewType.ViewWithEnvObject: SingleViewContent {
    
    public static func content(view: Any, envObject: Any) throws -> Any {
        guard let body = try (view as? EnvironmentObjectInjection)?.content(envObject) else {
            throw InspectionError.typeMismatch(view, T.self)
        }
        return body
    }
}

// MARK: - Extraction from SingleViewContent parent

public extension InspectableView where View: SingleViewContent {
    
    func view<T>(_ type: T.Type) throws -> InspectableView<ViewType.View<T>>
        where T: Inspectable {
        let content = try View.content(view: view, envObject: envObject)
        let prefix = Inspector.typeName(type: type)
        try Inspector.guardType(value: content, prefix: prefix)
        return try InspectableView<ViewType.View<T>>(content)
    }
    
    func view<T>(_ type: T.Type, _ envObject: T.Object) throws ->
        InspectableView<ViewType.ViewWithEnvObject<T>>
        where T: InspectableWithEnvObject {
        let content = try View.content(view: view, envObject: envObject)
        let prefix = Inspector.typeName(type: type)
        try Inspector.guardType(value: content, prefix: prefix)
        return try InspectableView<ViewType.ViewWithEnvObject<T>>(content, envObject: envObject)
    }
}

// MARK: - Extraction from MultipleViewContent parent

public extension InspectableView where View: MultipleViewContent {
    
    func view<T>(_ type: T.Type, _ index: Int) throws -> InspectableView<ViewType.View<T>>
        where T: Inspectable {
        let content = try contentView(at: index)
        let prefix = Inspector.typeName(type: type)
        try Inspector.guardType(value: content, prefix: prefix)
        return try InspectableView<ViewType.View<T>>(content)
    }
    
    func view<T>(_ type: T.Type, _ envObject: T.Object, _ index: Int) throws ->
        InspectableView<ViewType.ViewWithEnvObject<T>>
        where T: InspectableWithEnvObject {
        let content = try contentView(at: index)
        let prefix = Inspector.typeName(type: type)
        try Inspector.guardType(value: content, prefix: prefix)
        return try InspectableView<ViewType.ViewWithEnvObject<T>>(content, envObject: envObject)
    }
}

// MARK: - Custom Attributes

public extension InspectableView where View: CustomViewType {
    
    func actualView() throws -> View.T {
        guard let casted = view as? View.T else {
            throw InspectionError.typeMismatch(view, View.T.self)
        }
        return casted
    }
}

// MARK: - 

extension InspectableWithEnvObject {
    func content(_ object: Any) throws -> Any {
        guard let castedObject = object as? Object else {
            throw InspectionError.typeMismatch(object, Object.self)
        }
        return content(castedObject)
    }
}
