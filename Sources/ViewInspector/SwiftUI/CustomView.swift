import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public protocol CustomViewType {
    associatedtype T
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension ViewType {
    
    internal static let customViewGenericsPlaceholder = "<EmptyView>"
    
    struct View<T>: KnownViewType, CustomViewType {
        public static var typePrefix: String {
            guard T.self != ViewType.Stub.self
            else { return "" }
            return Inspector.typeName(type: T.self, generics: .customViewPlaceholder)
        }
        
        public static var namespacedPrefixes: [String] {
            guard T.self != ViewType.Stub.self
            else { return [] }
            return [Inspector.typeName(type: T.self, namespaced: true, generics: .remove)]
        }
        
        public static func inspectionCall(typeName: String) -> String {
            return "view(\(typeName).self\(ViewType.commaPlaceholder)\(ViewType.indexPlaceholder))"
        }
    }
}

// MARK: - Content Extraction

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension ViewType.View: SingleViewContent {
    
    public static func child(_ content: Content) throws -> Content {
        return try content.extractCustomView()
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension ViewType.View: MultipleViewContent {
    
    public static func children(_ content: Content) throws -> LazyGroup<Content> {
        return try content.extractCustomViewGroup()
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
internal extension Content {
    var isCustomView: Bool {
        return !Inspector.isSystemType(value: view)
    }
    
    func extractCustomView() throws -> Content {
        let contentExtractor = try ContentExtractor(source: view)
        let view = try contentExtractor.extractContent(environmentObjects: medium.environmentObjects)
        let medium = self.medium.resettingViewModifiers()
        return try Inspector.unwrap(view: view, medium: medium)
    }
    
    func extractCustomViewGroup() throws -> LazyGroup<Content> {
        let contentExtractor = try ContentExtractor(source: view)
        let view = try contentExtractor.extractContent(environmentObjects: medium.environmentObjects)
        return try Inspector.viewsInContainer(view: view, medium: medium)
    }
}

// MARK: - Extraction from SingleViewContent parent

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView where View: SingleViewContent {
    
    func view<T>(_ type: T.Type) throws -> InspectableView<ViewType.View<T>> where T: SwiftUI.View {
        guard !Inspector.isSystemType(type: type) else {
            let name = Inspector.typeName(type: type)
            throw InspectionError.notSupported(
                """
                Please replace .view(\(name).self) inspection call with \
                .\(name.firstLetterLowercased)() or .find(ViewType.\(name).self)
                """)
        }
        let child = try View.child(content)
        let prefix = Inspector.typeName(type: type, namespaced: true, generics: .remove)
        let base = ViewType.View<T>.inspectionCall(typeName: Inspector.typeName(type: type))
        let call = ViewType.inspectionCall(base: base, index: nil)
        try Inspector.guardType(value: child.view, namespacedPrefixes: [prefix], inspectionCall: call)
        return try .init(child, parent: self, call: call)
    }
}

// MARK: - Extraction from MultipleViewContent parent

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView where View: MultipleViewContent {
    
    func view<T>(_ type: T.Type, _ index: Int) throws -> InspectableView<ViewType.View<T>> where T: SwiftUI.View {
        guard !Inspector.isSystemType(type: type) else {
            let name = Inspector.typeName(type: type)
            throw InspectionError.notSupported(
                """
                Please replace .view(\(name).self, \(index)) inspection \
                call with .\(name.firstLetterLowercased)(\(index))
                """)
        }
        let content = try child(at: index)
        let prefix = Inspector.typeName(type: type, namespaced: true, generics: .remove)
        let base = ViewType.View<T>.inspectionCall(typeName: Inspector.typeName(type: type))
        let call = ViewType.inspectionCall(base: base, index: index)
        try Inspector.guardType(value: content.view, namespacedPrefixes: [prefix], inspectionCall: call)
        return try .init(content, parent: self, call: call)
    }
}

// MARK: - Custom Attributes

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension InspectableView where View: CustomViewType {
    
    func actualView() throws -> View.T {
        var view = try Inspector.cast(value: content.view, type: View.T.self)
        content.medium.environmentObjects.forEach {
            view = EnvironmentInjection.inject(environmentObject: $0, into: view)
        }
        return view
    }
}

#if os(macOS)
@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension NSViewRepresentable {
    func nsView() throws -> NSViewType {
        return try ViewHosting.lookup(Self.self)
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension NSViewControllerRepresentable {
    func viewController() throws -> NSViewControllerType {
        return try ViewHosting.lookup(Self.self)
    }
}

#elseif os(iOS) || os(tvOS)
@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension UIViewRepresentable {
    func uiView() throws -> UIViewType {
        return try ViewHosting.lookup(Self.self)
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension UIViewControllerRepresentable {
    func viewController() throws -> UIViewControllerType {
        return try ViewHosting.lookup(Self.self)
    }
}
#elseif os(watchOS)

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 7.0, *)
public extension WKInterfaceObjectRepresentable {
    func interfaceObject() throws -> WKInterfaceObjectType {
        return try ViewHosting.lookup(Self.self)
    }
}
#endif
