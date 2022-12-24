#if canImport(MapKit)
import MapKit
import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension ViewType {
    struct Map: KnownViewType {
        public static let typePrefix: String = "Map"
        public static var namespacedPrefixes: [String] {
            return ["_MapKit_SwiftUI." + typePrefix]
        }
        public static func inspectionCall(typeName: String) -> String {
            return "map(\(ViewType.indexPlaceholder))"
        }
    }
}

// MARK: - Extraction from SingleViewContent parent

@available(iOS 14.0, tvOS 14.0, macOS 11.0, *)
public extension InspectableView where View: SingleViewContent {
    func map() throws -> InspectableView<ViewType.Map> {
        return try .init(try child(), parent: self)
    }
}

@available(iOS 14.0, tvOS 14.0, macOS 11.0, *)
public extension InspectableView where View: MultipleViewContent {
    func map(_ index: Int) throws -> InspectableView<ViewType.Map> {
        return try .init(try child(at: index), parent: self, index: index)
    }
}

// MARK: - Custom Attributes

@available(iOS 14.0, tvOS 14.0, macOS 11.0, watchOS 7.0, *)
public extension InspectableView where View == ViewType.Map {
    
    func coordinateRegion() throws -> MKCoordinateRegion {
        return try coordinateRegionBinding().wrappedValue
    }
    
    func setCoordinateRegion(_ region: MKCoordinateRegion) throws {
        try guardIsResponsive()
        try coordinateRegionBinding().wrappedValue = region
    }
    
    func mapRect() throws -> MKMapRect {
        return try mapRectBinding().wrappedValue
    }
    
    func setMapRect(_ rect: MKMapRect) throws {
        try guardIsResponsive()
        try mapRectBinding().wrappedValue = rect
    }
    
    func userTrackingMode() throws -> MapUserTrackingMode {
        return try userTrackingModeBinding()?.wrappedValue ?? .none
    }
    
    func setUserTrackingMode(_ mode: MapUserTrackingMode) throws {
        try guardIsResponsive()
        try userTrackingModeBinding()?.wrappedValue = mode
    }
    
    func interactionModes() throws -> MapInteractionModes {
        return try Inspector.attribute(path: "provider|interactionModes",
                                       value: content.view,
                                       type: MapInteractionModes.self)
    }

    func showsUserLocation() throws -> Bool {
        return try Inspector.attribute(path: "provider|showsUserLocation",
                                       value: content.view,
                                       type: Bool.self)
    }
    
    func mapAnnotation<I>(_ item: I) throws -> InspectableView<ViewType.MapAnnotation>
    where I: Identifiable {
        let call = "mapAnnotation(id<\(item.id)>)"
        guard let provider = try? Inspector
                .attribute(label: "provider", value: content.view, type: IdentifiableItemsContainer.self),
              provider.contains(item) else {
            throw InspectionError.viewNotFound(parent: call)
        }
        typealias Builder = (I) -> _MapAnnotationData
        let builder = try Inspector.attribute(
            path: "provider|content|some", value: content.view, type: Builder.self)
        let annotation = builder(item)
        let medium = content.medium.resettingViewModifiers()
        return try .init(Content(annotation, medium: medium), parent: self, call: call)
    }
}

@available(iOS 14.0, tvOS 14.0, macOS 11.0, watchOS 7.0, *)
private extension InspectableView where View == ViewType.Map {
    
    func coordinateRegionBinding() throws -> Binding<MKCoordinateRegion> {
        return try Inspector.attribute(path: "provider|region|region",
                                       value: content.view,
                                       type: Binding<MKCoordinateRegion>.self)
    }
    
    func mapRectBinding() throws -> Binding<MKMapRect> {
        return try Inspector.attribute(path: "provider|region|rect",
                                       value: content.view,
                                       type: Binding<MKMapRect>.self)
    }
    
    func userTrackingModeBinding() throws -> Binding<MapUserTrackingMode>? {
        return try Inspector.attribute(path: "provider|userTrackingMode",
                                       value: content.view,
                                       type: Binding<MapUserTrackingMode>?.self)
    }
}

@available(iOS 14.0, tvOS 14.0, macOS 11.0, *)
internal protocol IdentifiableItemsContainer {
    func contains<T: Identifiable>(_ item: T) -> Bool
}

@available(iOS 14.0, tvOS 14.0, macOS 11.0, watchOS 7.0, *)
extension _DefaultAnnotatedMapContent: IdentifiableItemsContainer {
    func contains<T: Identifiable>(_ item: T) -> Bool {
        guard let item = item as? Items.Element,
              let items = try? Inspector.attribute(label: "items", value: self, type: Items?.self)
        else { return false }
        return items.lazy.map({ $0.id }).contains(item.id)
    }
}

#endif
