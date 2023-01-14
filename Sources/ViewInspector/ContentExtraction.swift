import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
internal struct ContentExtractor {

    internal init(source: Any) throws {
        self.contentSource = try Self.contentSource(from: source)
    }

    internal func extractContent(environmentObjects: [AnyObject]) throws -> Any {
        try validateSourceBeforeExtraction()
        switch contentSource {
        case .view(let view):
            return try view.extractContent(environmentObjects: environmentObjects)
        case .viewModifier(let viewModifier):
            return try viewModifier.extractContent(environmentObjects: environmentObjects)
        case .gesture(let gesture):
            return try gesture.extractContent(environmentObjects: environmentObjects)
        }
    }

    private static func contentSource(from source: Any) throws -> ContentSource {
        switch source {
        case let view as any View:
            guard !Inspector.isSystemType(value: view) else {
                let name = Inspector.typeName(value: source)
                throw InspectionError.notSupported("Not a custom view type: \(name)")
            }
            return .view(view)
        case let viewModifier as any ViewModifier:
            guard viewModifier.hasBody else {
                throw InspectionError.notSupported("ViewModifier without the body")
            }
            return .viewModifier(viewModifier)
        case let gesture as any Gesture:
            return .gesture(gesture)
        default:
            let name = Inspector.typeName(value: source)
            throw InspectionError.notSupported("Not a content type: \(name)")
        }
    }

    private func validateSourceBeforeExtraction() throws {
        switch contentSource.source {
        #if os(macOS)
        case is any NSViewRepresentable:
            throw InspectionError.notSupported(
                """
                Please use `.actualView().nsView()` for inspecting \
                the contents of NSViewRepresentable
                """)
        case is any NSViewControllerRepresentable:
            throw InspectionError.notSupported(
                """
                Please use `.actualView().viewController()` for inspecting \
                the contents of NSViewControllerRepresentable
                """)
        #endif
        #if os(iOS) || os(tvOS)
        case is any UIViewRepresentable:
            throw InspectionError.notSupported(
                """
                Please use `.actualView().uiView()` for inspecting \
                the contents of UIViewRepresentable
                """)
        case is any UIViewControllerRepresentable:
            throw InspectionError.notSupported(
                """
                Please use `.actualView().viewController()` for inspecting \
                the contents of UIViewControllerRepresentable
                """)
        #endif
        #if os(watchOS)
        case is any WKInterfaceObjectRepresentable:
            throw InspectionError.notSupported(
                """
                Please use `.actualView().interfaceObject()` for inspecting \
                the contents of WKInterfaceObjectRepresentable
                """)
        #endif
        default:
            return
        }
    }

    private enum ContentSource {
        case view(any View)
        case viewModifier(any ViewModifier)
        case gesture(any Gesture)

        var source: Any {
            switch self {
            case .view(let source): return source
            case .viewModifier(let source): return source
            case .gesture(let source): return source
            }
        }
    }

    private let contentSource: ContentSource
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
private extension ViewModifier {
    var hasBody: Bool {
        if self is (any EnvironmentalModifier) {
            return true
        }
        return Body.self != Never.self
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension View {
    
    func extractContent(environmentObjects: [AnyObject]) throws -> Any {
        var copy = self
        environmentObjects.forEach { copy = EnvironmentInjection.inject(environmentObject: $0, into: copy) }
        let missingObjects = EnvironmentInjection.missingEnvironmentObjects(for: copy)
        if missingObjects.count > 0 {
            let view = Inspector.typeName(value: self)
            throw InspectionError
                .missingEnvironmentObjects(view: view, objects: missingObjects)
        }
        return copy.body
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension ViewModifier {
    
    func extractContent(environmentObjects: [AnyObject]) throws -> Any {
        var copy = self
        environmentObjects.forEach { copy = EnvironmentInjection.inject(environmentObject: $0, into: copy) }
        let missingObjects = EnvironmentInjection.missingEnvironmentObjects(for: copy)
        if missingObjects.count > 0 {
            let view = Inspector.typeName(value: self)
            throw InspectionError
                .missingEnvironmentObjects(view: view, objects: missingObjects)
        }
        if let envModifier = copy as? (any EnvironmentalModifier) {
            let resolved = envModifier.resolve(in: EnvironmentValues())
            return try resolved.extractContent(environmentObjects: environmentObjects)
        }
        return copy.body()
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension Gesture {
    func extractContent(environmentObjects: [AnyObject]) throws -> Any { () }
}
