// Created by Michael Bachand on 12/18/22.
// Copyright © 2022 Airbnb Inc. All rights reserved.

import SwiftUI

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
