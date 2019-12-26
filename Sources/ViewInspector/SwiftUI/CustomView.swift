import SwiftUI

public extension ViewType {
    
    struct View<T>: KnownViewType, CustomViewType where T: Inspectable {
        public static var typePrefix: String {
            return Inspector.typeName(type: T.self)
        }
    }
    
    struct ViewWithOneParam<T>: KnownViewType, CustomViewType where T: InspectableWithOneParam {
        public static var typePrefix: String {
            return Inspector.typeName(type: T.self)
        }
    }
    
    struct ViewWithTwoParam<T>: KnownViewType, CustomViewType where T: InspectableWithTwoParam {
        public static var typePrefix: String {
            return Inspector.typeName(type: T.self)
        }
    }
    
    struct ViewWithThreeParam<T>: KnownViewType, CustomViewType where T: InspectableWithThreeParam {
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

public extension View where Self: InspectableWithOneParam {
    
    func inspect(_ param: Parameter) throws -> InspectableView<ViewType.ViewWithOneParam<Self>> {
        return try .init(Content(self), injection: InjectionParameters([param]))
    }
}

public extension View where Self: InspectableWithTwoParam {
    
    func inspect(_ param1: Parameter1, _ param2: Parameter2)
        throws -> InspectableView<ViewType.ViewWithTwoParam<Self>> {
        return try .init(Content(self), injection: InjectionParameters([param1, param2]))
    }
}

public extension View where Self: InspectableWithThreeParam {
    
    func inspect(_ param1: Parameter1, _ param2: Parameter2, _ param3: Parameter3)
        throws -> InspectableView<ViewType.ViewWithThreeParam<Self>> {
        return try .init(Content(self), injection: InjectionParameters([param1, param2, param3]))
    }
}

// MARK: - Content Extraction

extension ViewType.View: SingleViewContent {
    
    public static func child(_ content: Content, injection: Any) throws -> Content {
        guard let body = (content.view as? Inspectable)?.content else {
            throw InspectionError.typeMismatch(content.view, T.self)
        }
        return try Inspector.unwrap(view: body, modifiers: [])
    }
}

extension ViewType.ViewWithOneParam: SingleViewContent {
    
    public static func child(_ content: Content, injection: Any) throws -> Content {
        guard let container = injection as? InjectionParameters,
            container.params.count == 1
            else { throw InspectionError.injection }
        guard let body = try (content.view as? SingleParameterInjection)?
            .inject(container.params[0]) else {
            throw InspectionError.typeMismatch(content.view, T.self)
        }
        return try Inspector.unwrap(view: body, modifiers: [])
    }
}

extension ViewType.ViewWithTwoParam: SingleViewContent {
    
    public static func child(_ content: Content, injection: Any) throws -> Content {
        guard let container = injection as? InjectionParameters,
            container.params.count == 2
            else { throw InspectionError.injection }
        guard let body = try (content.view as? DualParameterInjection)?
            .inject(container.params[0], container.params[1]) else {
            throw InspectionError.typeMismatch(content.view, T.self)
        }
        return try Inspector.unwrap(view: body, modifiers: [])
    }
}

extension ViewType.ViewWithThreeParam: SingleViewContent {
    
    public static func child(_ content: Content, injection: Any) throws -> Content {
        guard let container = injection as? InjectionParameters,
            container.params.count == 3
            else { throw InspectionError.injection }
        guard let body = try (content.view as? TripleParameterInjection)?
            .inject(container.params[0], container.params[1], container.params[2]) else {
            throw InspectionError.typeMismatch(content.view, T.self)
        }
        return try Inspector.unwrap(view: body, modifiers: [])
    }
}

// MARK: - Extraction from SingleViewContent parent

public extension InspectableView where View: SingleViewContent {
    
    func view<T>(_ type: T.Type) throws -> InspectableView<ViewType.View<T>>
        where T: Inspectable {
            let child = try View.child(content, injection: injection)
            let prefix = Inspector.typeName(type: type)
            try Inspector.guardType(value: child.view, prefix: prefix)
            return try .init(child)
    }
    
    func view<T>(_ type: T.Type, _ param: T.Parameter)
        throws -> InspectableView<ViewType.ViewWithOneParam<T>>
        where T: InspectableWithOneParam {
            let child = try View.child(content, injection: injection)
            let prefix = Inspector.typeName(type: type)
            try Inspector.guardType(value: child.view, prefix: prefix)
            return try .init(child, injection: InjectionParameters([param]))
    }
    
    func view<T>(_ type: T.Type, _ param1: T.Parameter1, _ param2: T.Parameter2)
        throws -> InspectableView<ViewType.ViewWithTwoParam<T>>
        where T: InspectableWithTwoParam {
            let child = try View.child(content, injection: injection)
            let prefix = Inspector.typeName(type: type)
            try Inspector.guardType(value: child.view, prefix: prefix)
            return try .init(child, injection: InjectionParameters([param1, param2]))
    }
    
    func view<T>(_ type: T.Type, _ param1: T.Parameter1, _ param2: T.Parameter2, _ param3: T.Parameter3)
        throws -> InspectableView<ViewType.ViewWithThreeParam<T>>
        where T: InspectableWithThreeParam {
            let child = try View.child(content, injection: injection)
            let prefix = Inspector.typeName(type: type)
            try Inspector.guardType(value: child.view, prefix: prefix)
            return try .init(child, injection: InjectionParameters([param1, param2, param3]))
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
    
    func view<T>(_ type: T.Type, _ param: T.Parameter, _ index: Int)
        throws -> InspectableView<ViewType.ViewWithOneParam<T>>
        where T: InspectableWithOneParam {
            let content = try child(at: index)
            let prefix = Inspector.typeName(type: type)
            try Inspector.guardType(value: content.view, prefix: prefix)
            return try .init(content, injection: InjectionParameters([param]))
    }
    
    func view<T>(_ type: T.Type, _ param1: T.Parameter1, _ param2: T.Parameter2, _ index: Int)
        throws -> InspectableView<ViewType.ViewWithTwoParam<T>>
        where T: InspectableWithTwoParam {
            let content = try child(at: index)
            let prefix = Inspector.typeName(type: type)
            try Inspector.guardType(value: content.view, prefix: prefix)
            return try .init(content, injection: InjectionParameters([param1, param2]))
    }
    
    func view<T>(_ type: T.Type, _ param1: T.Parameter1, _ param2: T.Parameter2,
                 _ param3: T.Parameter3, _ index: Int)
        throws -> InspectableView<ViewType.ViewWithThreeParam<T>>
        where T: InspectableWithThreeParam {
            let content = try child(at: index)
            let prefix = Inspector.typeName(type: type)
            try Inspector.guardType(value: content.view, prefix: prefix)
            return try .init(content, injection: InjectionParameters([param1, param2, param3]))
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

// MARK: - Injecting type casted environment objects

public extension InspectableWithOneParam {
    func inject(_ param: Any) throws -> Any {
        guard let casted = param as? Parameter
            else { throw InspectionError.injection }
        return body(casted)
    }
}

public extension InspectableWithTwoParam {
    func inject(_ param1: Any, _ param2: Any) throws -> Any {
        guard let casted1 = param1 as? Parameter1,
            let casted2 = param2 as? Parameter2
            else { throw InspectionError.injection }
        return body(casted1, casted2)
    }
}

public extension InspectableWithThreeParam {
    func inject(_ param1: Any, _ param2: Any, _ param3: Any) throws -> Any {
        guard let casted1 = param1 as? Parameter1,
            let casted2 = param2 as? Parameter2,
            let casted3 = param3 as? Parameter3
            else { throw InspectionError.injection }
        return body(casted1, casted2, casted3)
    }
}

private extension InspectionError {
    static var injection: InspectionError {
        .notSupported("Error with objects injection")
    }
}
