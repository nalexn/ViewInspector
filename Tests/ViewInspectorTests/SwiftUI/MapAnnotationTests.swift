#if canImport(MapKit)
import MapKit
import SwiftUI
import XCTest

@testable import ViewInspector

class MapAnnotationTests: XCTestCase {
    
    private let testCoordinate = CLLocationCoordinate2D(latitude: 1, longitude: 2)
    private let testAnchor = CGPoint(x: 3, y: 4)

    func testMapAnnotationAttributes() throws {
        guard #available(iOS 14.0, tvOS 14.0, macOS 11.0, *) else { return }
        let sut = MapAnnotation(coordinate: testCoordinate, anchorPoint: testAnchor) {
            EmptyView()
            Text("abc")
        }
        XCTAssertEqual(try sut.coordinate(), testCoordinate)
        XCTAssertEqual(try sut.anchorPoint(), testAnchor)
        let content = try sut.contentView()
        XCTAssertNoThrow(try content.emptyView(0))
        XCTAssertEqual(try content.text(1).string(), "abc")
    }
    
    func testMapMarkerAttributes() throws {
        guard #available(iOS 14.0, tvOS 14.0, macOS 11.0, *) else { return }
        let sut = MapMarker(coordinate: testCoordinate, tint: .red)
        XCTAssertEqual(try sut.coordinate(), testCoordinate)
        XCTAssertEqual(try sut.tintColor(), .red)
    }
    
    func testMapPinAttributes() throws {
        guard #available(iOS 14.0, tvOS 14.0, macOS 11.0, *) else { return }
        let sut = MapPin(coordinate: testCoordinate, tint: .blue)
        XCTAssertEqual(try sut.coordinate(), testCoordinate)
        XCTAssertEqual(try sut.tintColor(), .blue)
    }
    
    func testExtractionFromMap() throws {
        guard #available(iOS 14.0, tvOS 14.0, macOS 11.0, *) else { return }
        let coord = CLLocationCoordinate2D(latitude: 1, longitude: 2)
        let region = Binding<MKCoordinateRegion>(wrappedValue: .init())
        let items = Array(0...5)
        let customView = try Map(coordinateRegion: region, annotationItems: items) { item in
            MapAnnotation(coordinate: coord, content: { Text("\(item)") })
        }.inspect().map()
        let markerView = try Map(coordinateRegion: region, annotationItems: items) { item in
            MapMarker(coordinate: coord)
        }.inspect().map()
        let pinView = try Map(coordinateRegion: region, annotationItems: items) { item in
            MapPin(coordinate: coord)
        }.inspect().map()
        for item in items {
            let custom = try customView.mapAnnotation(item)
            XCTAssertEqual(custom.viewType, .custom)
            let marker = try markerView.mapAnnotation(item)
            XCTAssertEqual(marker.viewType, .marker)
            let pin = try pinView.mapAnnotation(item)
            XCTAssertEqual(pin.viewType, .pin)
            for view in [custom, marker, pin] {
                XCTAssertEqual(try view.coordinate(), coord)
                XCTAssertEqual(view.pathToRoot, "map().mapAnnotation(id<\(item.id)>)")
            }
        }
        XCTAssertThrows(try pinView.mapAnnotation("1"),
                        "View for mapAnnotation(id<1>) is absent")
        XCTAssertThrows(try pinView.mapAnnotation(9),
                        "View for mapAnnotation(id<9>) is absent")
        let simpleMap = try Map(coordinateRegion: region).inspect().map()
        XCTAssertThrows(try simpleMap.mapAnnotation(0),
                        "View for mapAnnotation(id<0>) is absent")
    }

}

#endif
