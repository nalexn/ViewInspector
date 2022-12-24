#if canImport(MapKit)
import MapKit
import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension ViewType {
    struct MapAnnotation: KnownViewType {
        public static let typePrefix: String = "_MapAnnotationData"
        public static var namespacedPrefixes: [String] {
            return ["_MapKit_SwiftUI." + typePrefix]
        }
    }
}

@available(iOS 14.0, tvOS 14.0, macOS 11.0, *)
public extension ViewType.MapAnnotation {
    enum ViewType: String {
        case pin
        case marker
        case custom
    }
}

// MARK: - Custom Attributes

@available(iOS 14.0, tvOS 14.0, macOS 11.0, *)
public extension InspectableView where View == ViewType.MapAnnotation {
    
    func coordinate() throws -> CLLocationCoordinate2D {
        return try Inspector.attribute(
            label: "coordinate", value: content.view, type: CLLocationCoordinate2D.self)
    }
    
    var viewType: ViewType.MapAnnotation.ViewType {
        let value = try? Inspector.attribute(label: "viewType", value: content.view)
        return value
            .flatMap { String(describing: $0) }
            .flatMap { ViewType.MapAnnotation.ViewType(rawValue: $0) } ?? .custom
    }
}

// MARK: - SwiftUI MapAnnotation

@available(iOS 14.0, tvOS 14.0, macOS 11.0, watchOS 7.0, *)
public extension MapAnnotation {
    
    func coordinate() throws -> CLLocationCoordinate2D {
        return try Inspector.attribute(
            label: "coordinate", value: self, type: CLLocationCoordinate2D.self)
    }
    
    func anchorPoint() throws -> CGPoint {
        return try Inspector.attribute(
            label: "anchorPoint", value: self, type: CGPoint.self)
    }
    
    func contentView() throws -> InspectableView<ViewType.ClassifiedView> {
        let view = try Inspector.attribute(label: "content", value: self)
        let content = ViewInspector.Content(view, medium: .empty)
        return try .init(try Inspector.unwrap(content: content), parent: nil)
    }
}

// MARK: - SwiftUI MapMarker

@available(iOS 14.0, tvOS 14.0, macOS 11.0, watchOS 7.0, *)
public extension MapMarker {
    
    func coordinate() throws -> CLLocationCoordinate2D {
        return try Inspector.attribute(
            label: "coordinate", value: self, type: CLLocationCoordinate2D.self)
    }
    
    func tintColor() throws -> Color? {
        return try Inspector.attribute(
            label: "tintColor", value: self, type: Color?.self)
    }
}

// MARK: - SwiftUI MapPin

@available(iOS 14.0, tvOS 14.0, macOS 11.0, watchOS 7.0, *)
public extension MapPin {
    
    func coordinate() throws -> CLLocationCoordinate2D {
        return try Inspector.attribute(
            label: "coordinate", value: self, type: CLLocationCoordinate2D.self)
    }
    
    func tintColor() throws -> Color? {
        return try Inspector.attribute(
            label: "tintColor", value: self, type: Color?.self)
    }
}

#endif
