// Created by Michael Bachand on 12/18/22.
// Copyright © 2022 Airbnb Inc. All rights reserved.

import SwiftUI

struct ContentExtractor {

    init(source: Any) throws {
        guard let contentSource = Self.contentSource(from: source) else {
            throw SourceNotContentExtractable()
        }
        self.contentSource = contentSource
    }

    struct SourceNotContentExtractable: Error { }

    static func isContentExtractable(from source: Any) -> Bool {
        contentSource(from: source) != nil
    }

    private static func contentSource(from source: Any) -> ContentSource? {
        switch source {
        case let view as any View:
            return .view(view)
        case let viewModifier as any ViewModifier:
            return .viewModifier(viewModifier)
        case let gesture as any Gesture:
            return .gesture(gesture)
        default:
            return nil
        }
    }

    func extractContent(environmentObjects: [AnyObject]) throws -> Any {
        try validateSource()

        switch contentSource {
        case .view(let view):
            return try view.extractContent(environmentObjects: environmentObjects)
        case .viewModifier(let viewModifier):
            return try viewModifier.extractContent(environmentObjects: environmentObjects)
        case .gesture(let gesture):
            return try gesture.extractContent(environmentObjects: environmentObjects)
        }
    }

    private func validateSource() throws {
        switch contentSource.source {
        #if os(macOS)
        case is any NSViewRepresentable:
            throw InspectionError.notSupported(
                "Please use `.actualView().nsView()` for inspecting the contents of NSViewRepresentable")
        case is any NSViewControllerRepresentable:
            throw InspectionError.notSupported(
                "Please use `.actualView().viewController()` for inspecting the contents of NSViewControllerRepresentable")
        #endif
        #if os(iOS) || os(tvOS)
        case is any UIViewRepresentable:
            throw InspectionError.notSupported(
                "Please use `.actualView().uiView()` for inspecting the contents of UIViewRepresentable")
        case is any UIViewControllerRepresentable:
            throw InspectionError.notSupported(
                "Please use `.actualView().viewController()` for inspecting the contents of UIViewControllerRepresentable")
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
        return copy.body()
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension Gesture {
    func extractContent(environmentObjects: [AnyObject]) throws -> Any { () }
}
