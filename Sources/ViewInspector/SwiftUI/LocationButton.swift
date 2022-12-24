import SwiftUI
#if canImport(CoreLocationUI)
import CoreLocationUI.CLLocationButton
#endif

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
public extension ViewType {
    
    struct LocationButton: KnownViewType {
        public static let typePrefix: String = "LocationButton"
        public static var namespacedPrefixes: [String] {
            return ["_CoreLocationUI_SwiftUI." + typePrefix]
        }
        public static func inspectionCall(typeName: String) -> String {
            return "locationButton(\(ViewType.indexPlaceholder))"
        }
    }
}

// MARK: - Extraction from SingleViewContent parent

@available(iOS 15.0, watchOS 8.0, *)
@available(macOS, unavailable)
@available(tvOS, unavailable)
public extension InspectableView where View: SingleViewContent {
    
    func locationButton() throws -> InspectableView<ViewType.LocationButton> {
        return try .init(try child(), parent: self)
    }
}

// MARK: - Extraction from MultipleViewContent parent

@available(iOS 15.0, watchOS 8.0, *)
@available(macOS, unavailable)
@available(tvOS, unavailable)
public extension InspectableView where View: MultipleViewContent {
    
    func locationButton(_ index: Int) throws -> InspectableView<ViewType.LocationButton> {
        return try .init(try child(at: index), parent: self, index: index)
    }
}

// MARK: - Custom Attributes

@available(iOS 15.0, watchOS 8.0, *)
@available(macOS, unavailable)
@available(tvOS, unavailable)
public extension InspectableView where View == ViewType.LocationButton {
    
    #if canImport(CoreLocationUI) && !os(watchOS)
    func title() throws -> LocationButton.Title {
        let label = try Inspector.attribute(
            path: "configuration|title|some", value: content.view, type: CLLocationButtonLabel.self)
        return LocationButton.Title(label: label)
    }
    #endif
    
    func tap() throws {
        try guardIsResponsive()
        typealias Callback = () -> Void
        let callback = try Inspector.attribute(
            path: "configuration|action", value: content.view, type: Callback.self)
        callback()
    }
}

#if canImport(CoreLocationUI) && !os(watchOS)
@available(iOS 15.0, watchOS 8.0, *)
@available(macOS, unavailable)
@available(tvOS, unavailable)
extension LocationButton.Title: BinaryEquatable {
    init(label: CLLocationButtonLabel) {
        switch label {
        case .none, .currentLocation:
            self = .currentLocation
        case .sendCurrentLocation:
            self = .sendCurrentLocation
        case .sendMyCurrentLocation:
            self = .sendMyCurrentLocation
        case .shareCurrentLocation:
            self = .shareCurrentLocation
        case .shareMyCurrentLocation:
            self = .shareMyCurrentLocation
        @unknown default:
            self = .currentLocation
        }
    }
}
#endif
