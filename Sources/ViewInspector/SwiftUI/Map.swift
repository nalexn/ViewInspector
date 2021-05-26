//
//  Map.swift
//  ViewInspectorTests
//
//  Created by Tyler Thompson on 5/25/21.
//

#if canImport(MapKit)
import MapKit
import SwiftUI

@available(iOS 14.0, *)
public extension ViewType {
    struct Map: KnownViewType {
        public static let typePrefix: String = "Map"
        public static var namespacedPrefixes: [String] {
            return ["_MapKit_SwiftUI." + typePrefix]
        }
    }
}

// MARK: - Extraction from SingleViewContent parent

@available(iOS 14.0, *)
public extension InspectableView where View: SingleViewContent {
    func map() throws -> InspectableView<ViewType.Map> {
        return try .init(try child(), parent: self)
    }
//    static func child(_ content: Content) throws -> Content {
//        let view = try Inspector.attribute(path: "storage|view", value: content.view)
//        let medium = content.medium.resettingViewModifiers()
//        return try Inspector.unwrap(view: view, medium: medium)
//    }
}

@available(iOS 14.0, *)
public extension InspectableView where View == ViewType.Map {
//    static func child(_ content: Content) throws -> Content {
//        let view = try Inspector.attribute(label: "content", value: content.view)
//        let medium = content.medium.resettingViewModifiers()
//        return try Inspector.unwrap(view: view, medium: medium)
//    }
}

//@available(iOS 14.0, *)
//extension ViewType.Map: SingleViewContent {
//
//    public static func child(_ content: Content) throws -> Content {
//        let view = try Inspector.attribute(path: "storage|view", value: content.view)
//        let medium = content.medium.resettingViewModifiers()
//        return try Inspector.unwrap(view: view, medium: medium)
//    }
//}

// MARK: - Extraction from MultipleViewContent parent

@available(iOS 14.0, *)
public extension InspectableView where View: MultipleViewContent {
    func map(_ index: Int) throws -> InspectableView<ViewType.Map> {
        return try .init(try child(at: index), parent: self, index: index)
    }
}

// MARK: - Custom Attributes

@available(iOS 14.0, *)
public extension InspectableView where View == ViewType.Map {
    func coordinateRegion() throws -> Binding<MKCoordinateRegion> {
        return try ViewType.Map.extractCoordinateRegion(from: self)
    }

    func interactionModes() throws -> MapInteractionModes {
        return try ViewType.Map.extractInteractionModes(from: self)
    }

    func showsUserLocation() throws -> Bool {
        return try ViewType.Map.extractShowsUserLocation(from: self)
    }

    func userTrackingMode() throws -> Binding<MapUserTrackingMode>? {
        return try ViewType.Map.extractUserTrackingMode(from: self)
    }
}

@available(iOS 14.0, *)
private extension ViewType.Map {
    static func extractCoordinateRegion(from view: InspectableView<ViewType.Map>) throws -> Binding<MKCoordinateRegion> {
        let provider = try Inspector.attribute(label: "provider", value: view.content.view)
        let regionContainer = try Inspector.attribute(label: "region", value: provider)
        return try Inspector.attribute(label: "region", value: regionContainer, type: Binding<MKCoordinateRegion>.self)
    }

    static func extractInteractionModes(from view: InspectableView<ViewType.Map>) throws -> MapInteractionModes {
        let provider = try Inspector.attribute(label: "provider", value: view.content.view)
        return try Inspector.attribute(label: "interactionModes", value: provider, type: MapInteractionModes.self)
    }

    static func extractShowsUserLocation(from view: InspectableView<ViewType.Map>) throws -> Bool {
        let provider = try Inspector.attribute(label: "provider", value: view.content.view)
        return try Inspector.attribute(label: "showsUserLocation", value: provider, type: Bool.self)
    }

    static func extractUserTrackingMode(from view: InspectableView<ViewType.Map>) throws -> Binding<MapUserTrackingMode>? {
        let provider = try Inspector.attribute(label: "provider", value: view.content.view)
        return try Inspector.attribute(label: "userTrackingMode", value: provider, type: Binding<MapUserTrackingMode>?.self)
    }
}
#endif
