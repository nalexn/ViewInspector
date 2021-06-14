#if canImport(MapKit)
import MapKit
import SwiftUI
import XCTest

@testable import ViewInspector

class MapTests: XCTestCase {
    
    private let testRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 123, longitude: 321),
        latitudinalMeters: 987, longitudinalMeters: 6)
    
    func testExtractionFromSingleViewContainer() throws {
        guard #available(iOS 14.0, tvOS 14.0, macOS 11.0, *) else { return }
        let sut = AnyView(Map(coordinateRegion: .constant(MKCoordinateRegion())))
        XCTAssertNoThrow(try sut.inspect().anyView().map())
    }

    func testExtractionFromMultipleViewContainer() throws {
        guard #available(iOS 14.0, tvOS 14.0, macOS 11.0, *) else { return }
        let view = HStack {
            Map(coordinateRegion: .constant(MKCoordinateRegion()))
            Map(coordinateRegion: .constant(MKCoordinateRegion()))
        }
        XCTAssertNoThrow(try view.inspect().hStack().map(0))
        XCTAssertNoThrow(try view.inspect().hStack().map(1))
    }

    func testSearch() throws {
        guard #available(iOS 14.0, tvOS 14.0, macOS 11.0, *) else { return }
        let view = AnyView(Map(coordinateRegion: .constant(MKCoordinateRegion())))
        XCTAssertEqual(try view.inspect().find(ViewType.Map.self).pathToRoot, "anyView().map()")
    }

    func testExtractingCoordinateRegionValue() throws {
        guard #available(iOS 14.0, tvOS 14.0, macOS 11.0, *) else { return }
        let sut = Map(coordinateRegion: .constant(testRegion))
        XCTAssertEqual(try sut.inspect().map().coordinateRegion(), testRegion)
    }
    
    func testSettingCoordinateRegionValue() throws {
        guard #available(iOS 14.0, tvOS 14.0, macOS 11.0, *) else { return }
        let binding = Binding(wrappedValue: MKCoordinateRegion())
        let sut = Map(coordinateRegion: binding)
        XCTAssertEqual(try sut.inspect().map().coordinateRegion(), MKCoordinateRegion())
        try sut.inspect().map().setCoordinateRegion(testRegion)
        XCTAssertEqual(try sut.inspect().map().coordinateRegion(), testRegion)
        XCTAssertEqual(binding.wrappedValue, testRegion)
    }
    
    func testErrorOnSettingCoordinateRegionWhenNonResponsive() throws {
        guard #available(iOS 14.0, tvOS 14.0, macOS 11.0, *) else { return }
        let binding = Binding(wrappedValue: MKCoordinateRegion())
        let sut = Map(coordinateRegion: binding).hidden()
        XCTAssertEqual(try sut.inspect().map().coordinateRegion(), MKCoordinateRegion())
        XCTAssertFalse(try sut.inspect().map().isResponsive())
        XCTAssertThrows(try sut.inspect().map().setCoordinateRegion(testRegion),
                        "Map is unresponsive: it is hidden")
    }
    
    func testExtractingMapRectValue() throws {
        guard #available(iOS 14.0, tvOS 14.0, macOS 11.0, *) else { return }
        let rect = MKMapRect(x: 3, y: 5, width: 1, height: 8)
        let sut = Map(mapRect: .constant(rect),
                      interactionModes: .all,
                      showsUserLocation: false,
                      userTrackingMode: .constant(.none))
        XCTAssertEqual(try sut.inspect().map().mapRect(), rect)
    }
    
    func testSettingMapRectValue() throws {
        guard #available(iOS 14.0, tvOS 14.0, macOS 11.0, *) else { return }
        let binding = Binding(wrappedValue: MKMapRect())
        let sut = Map(mapRect: binding,
                      interactionModes: .all,
                      showsUserLocation: false,
                      userTrackingMode: .constant(.none))
        XCTAssertEqual(try sut.inspect().map().mapRect(), MKMapRect())
        let rect = MKMapRect(x: 3, y: 5, width: 1, height: 8)
        try sut.inspect().map().setMapRect(rect)
        XCTAssertEqual(try sut.inspect().map().mapRect(), rect)
        XCTAssertEqual(binding.wrappedValue, rect)
    }
    
    func testErrorOnSettingMapRectWhenNonResponsive() throws {
        guard #available(iOS 14.0, tvOS 14.0, macOS 11.0, *) else { return }
        let binding = Binding(wrappedValue: MKMapRect())
        let sut = Map(mapRect: binding,
                      interactionModes: .all,
                      showsUserLocation: false,
                      userTrackingMode: .constant(.none))
            .hidden()
        XCTAssertEqual(try sut.inspect().map().mapRect(), MKMapRect())
        XCTAssertFalse(try sut.inspect().map().isResponsive())
        let rect = MKMapRect(x: 3, y: 5, width: 1, height: 8)
        XCTAssertThrows(try sut.inspect().map().setMapRect(rect),
                        "Map is unresponsive: it is hidden")
    }

    func testExtractingInteractionModes() throws {
        guard #available(iOS 14.0, tvOS 14.0, macOS 11.0, *) else { return }
        let region = MKCoordinateRegion()
        let sut = Map(coordinateRegion: .constant(region),
                      interactionModes: .pan,
                      showsUserLocation: false,
                      userTrackingMode: .constant(.none))
        let value = try sut.inspect().map().interactionModes()
        XCTAssertEqual(value, .pan)
    }

    func testExtractingShowsUserLocation() throws {
        guard #available(iOS 14.0, tvOS 14.0, macOS 11.0, *) else { return }
        let region = MKCoordinateRegion()
        let sut = Map(coordinateRegion: .constant(region),
                      interactionModes: .all,
                      showsUserLocation: true,
                      userTrackingMode: .constant(.none))
        let value = try sut.inspect().map().showsUserLocation()
        XCTAssertEqual(value, true)
    }

    func testExtractingUserTrackingMode() throws {
        guard #available(iOS 14.0, tvOS 14.0, macOS 11.0, *) else { return }
        let region = MKCoordinateRegion()
        let sut = Map(coordinateRegion: .constant(region),
                      interactionModes: .all,
                      showsUserLocation: true,
                      userTrackingMode: .constant(.follow))
        let value = try sut.inspect().map().userTrackingMode()
        XCTAssertEqual(value, .follow)
    }
    
    func testSettingUserTrackingMode() throws {
        guard #available(iOS 14.0, tvOS 14.0, macOS 11.0, *) else { return }
        let binding = Binding(wrappedValue: MapUserTrackingMode.follow)
        let sut = Map(coordinateRegion: .constant(MKCoordinateRegion()),
                      interactionModes: .all,
                      showsUserLocation: true,
                      userTrackingMode: binding)
        XCTAssertEqual(try sut.inspect().map().userTrackingMode(), .follow)
        try sut.inspect().map().setUserTrackingMode(.none)
        XCTAssertEqual(try sut.inspect().map().userTrackingMode(), .none)
        XCTAssertEqual(binding.wrappedValue, .none)
    }
}

// MARK: - Equatable

extension CLLocationCoordinate2D: Equatable {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return lhs.latitude == rhs.latitude
            && rhs.longitude == rhs.longitude
    }
}

extension MKCoordinateSpan: Equatable {
    public static func == (lhs: MKCoordinateSpan, rhs: MKCoordinateSpan) -> Bool {
        return lhs.latitudeDelta == rhs.latitudeDelta
            && lhs.longitudeDelta == rhs.longitudeDelta
    }
}

extension MKCoordinateRegion: Equatable {
    public static func == (lhs: MKCoordinateRegion, rhs: MKCoordinateRegion) -> Bool {
        return lhs.center == rhs.center && lhs.span == rhs.span
    }
}

extension MKMapPoint: Equatable {
    public static func == (lhs: MKMapPoint, rhs: MKMapPoint) -> Bool {
        return lhs.coordinate == rhs.coordinate
    }
}

extension MKMapSize: Equatable {
    public static func == (lhs: MKMapSize, rhs: MKMapSize) -> Bool {
        return lhs.width == lhs.width && lhs.height == rhs.height
    }
}

extension MKMapRect: Equatable {
    public static func == (lhs: MKMapRect, rhs: MKMapRect) -> Bool {
        return lhs.origin == rhs.origin && lhs.size == rhs.size
    }
}

#endif
