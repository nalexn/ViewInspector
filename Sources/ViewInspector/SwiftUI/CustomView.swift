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
    
    struct ViewWithEnvObject2<T>: KnownViewType, CustomViewType where T: InspectableWithEnvObject2 {
        public static var typePrefix: String {
            return Inspector.typeName(type: T.self)
        }
    }
    
    struct ViewWithEnvObject3<T>: KnownViewType, CustomViewType where T: InspectableWithEnvObject3 {
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

public extension View where Self: InspectableWithEnvObject {
    
    func inspect(_ object: Object) throws -> InspectableView<ViewType.ViewWithEnvObject<Self>> {
        return try .init(Content(self), envObject: object)
    }
}

public extension View where Self: InspectableWithEnvObject2 {
    
    func inspect(_ object1: Object1, _ object2: Object2)
        throws -> InspectableView<ViewType.ViewWithEnvObject2<Self>> {
        return try .init(Content(self), envObject: EnvObjectsContainer([object1, object2]))
    }
}

public extension View where Self: InspectableWithEnvObject3 {
    
    func inspect(_ object1: Object1, _ object2: Object2, _ object3: Object3)
        throws -> InspectableView<ViewType.ViewWithEnvObject3<Self>> {
        return try .init(Content(self), envObject: EnvObjectsContainer([object1, object2, object3]))
    }
}

// MARK: - Content Extraction

extension ViewType.View: SingleViewContent {
    
    public static func child(_ content: Content, envObject: Any) throws -> Content {
        guard let body = (content.view as? Inspectable)?.content else {
            throw InspectionError.typeMismatch(content.view, T.self)
        }
        return try Inspector.unwrap(view: body, modifiers: [])
    }
}

extension ViewType.ViewWithEnvObject: SingleViewContent {
    
    public static func child(_ content: Content, envObject: Any) throws -> Content {
        guard let body = try (content.view as? EnvironmentObjectInjection)?.inject(envObject) else {
            throw InspectionError.typeMismatch(content.view, T.self)
        }
        return try Inspector.unwrap(view: body, modifiers: [])
    }
}

extension ViewType.ViewWithEnvObject2: SingleViewContent {
    
    public static func child(_ content: Content, envObject: Any) throws -> Content {
        guard let container = envObject as? EnvObjectsContainer,
            container.objects.count == 2
            else { throw InspectionError.injection }
        guard let body = try (content.view as? EnvironmentObjectInjection2)?
            .inject(container.objects[0], container.objects[1]) else {
            throw InspectionError.typeMismatch(content.view, T.self)
        }
        return try Inspector.unwrap(view: body, modifiers: [])
    }
}

extension ViewType.ViewWithEnvObject3: SingleViewContent {
    
    public static func child(_ content: Content, envObject: Any) throws -> Content {
        guard let container = envObject as? EnvObjectsContainer,
            container.objects.count == 3
            else { throw InspectionError.injection }
        guard let body = try (content.view as? EnvironmentObjectInjection3)?
            .inject(container.objects[0], container.objects[1], container.objects[2]) else {
            throw InspectionError.typeMismatch(content.view, T.self)
        }
        return try Inspector.unwrap(view: body, modifiers: [])
    }
}

// MARK: - Extraction from SingleViewContent parent

public extension InspectableView where View: SingleViewContent {
    
    func view<T>(_ type: T.Type) throws -> InspectableView<ViewType.View<T>>
        where T: Inspectable {
            let child = try View.child(content, envObject: envObject)
            let prefix = Inspector.typeName(type: type)
            try Inspector.guardType(value: child.view, prefix: prefix)
            return try .init(child)
    }
    
    func view<T>(_ type: T.Type, _ object: T.Object)
        throws -> InspectableView<ViewType.ViewWithEnvObject<T>>
        where T: InspectableWithEnvObject {
            let child = try View.child(content, envObject: object)
            let prefix = Inspector.typeName(type: type)
            try Inspector.guardType(value: child.view, prefix: prefix)
            return try .init(child, envObject: object)
    }
    
    func view<T>(_ type: T.Type, _ object1: T.Object1, _ object2: T.Object2)
        throws -> InspectableView<ViewType.ViewWithEnvObject2<T>>
        where T: InspectableWithEnvObject2 {
            let child = try View.child(content, envObject: envObject)
            let prefix = Inspector.typeName(type: type)
            try Inspector.guardType(value: child.view, prefix: prefix)
            return try .init(child, envObject: EnvObjectsContainer([object1, object2]))
    }
    
    func view<T>(_ type: T.Type, _ object1: T.Object1, _ object2: T.Object2, _ object3: T.Object3)
        throws -> InspectableView<ViewType.ViewWithEnvObject3<T>>
        where T: InspectableWithEnvObject3 {
            let child = try View.child(content, envObject: envObject)
            let prefix = Inspector.typeName(type: type)
            try Inspector.guardType(value: child.view, prefix: prefix)
            return try .init(child, envObject: EnvObjectsContainer([object1, object2, object3]))
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
    
    func view<T>(_ type: T.Type, _ object: T.Object, _ index: Int)
        throws -> InspectableView<ViewType.ViewWithEnvObject<T>>
        where T: InspectableWithEnvObject {
            let content = try child(at: index)
            let prefix = Inspector.typeName(type: type)
            try Inspector.guardType(value: content.view, prefix: prefix)
            return try .init(content, envObject: object)
    }
    
    func view<T>(_ type: T.Type, _ object1: T.Object1, _ object2: T.Object2, _ index: Int)
        throws -> InspectableView<ViewType.ViewWithEnvObject2<T>>
        where T: InspectableWithEnvObject2 {
            let content = try child(at: index)
            let prefix = Inspector.typeName(type: type)
            try Inspector.guardType(value: content.view, prefix: prefix)
            return try .init(content, envObject: EnvObjectsContainer([object1, object2]))
    }
    
    func view<T>(_ type: T.Type, _ object1: T.Object1, _ object2: T.Object2,
                 _ object3: T.Object3, _ index: Int)
        throws -> InspectableView<ViewType.ViewWithEnvObject3<T>>
        where T: InspectableWithEnvObject3 {
            let content = try child(at: index)
            let prefix = Inspector.typeName(type: type)
            try Inspector.guardType(value: content.view, prefix: prefix)
            return try .init(content, envObject: EnvObjectsContainer([object1, object2, object3]))
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

// MARK: - Environment Objects Container

private struct EnvObjectsContainer {
    let objects: [Any]
    
    init(_ objects: [Any]) {
        self.objects = objects
    }
}

// MARK: - Injecting type casted environment objects

public extension InspectableWithEnvObject {
    func inject(_ object: Any) throws -> Any {
        guard let castedObject = object as? Object
            else { throw InspectionError.injection }
        return body(castedObject)
    }
}

public extension InspectableWithEnvObject2 {
    func inject(_ object1: Any, _ object2: Any) throws -> Any {
        guard let castedObject1 = object1 as? Object1,
            let castedObject2 = object2 as? Object2
            else { throw InspectionError.injection }
        return body(castedObject1, castedObject2)
    }
}

public extension InspectableWithEnvObject3 {
    func inject(_ object1: Any, _ object2: Any, _ object3: Any) throws -> Any {
        guard let castedObject1 = object1 as? Object1,
            let castedObject2 = object2 as? Object2,
            let castedObject3 = object3 as? Object3
            else { throw InspectionError.injection }
        return body(castedObject1, castedObject2, castedObject3)
    }
}

private extension InspectionError {
    static var injection: InspectionError {
        .notSupported("Error with objects injection")
    }
}
