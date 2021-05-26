//
//  MapTests.swift
//  ViewInspectorTests
//
//  Created by Tyler Thompson on 5/25/21.
//

#if canImport(MapKit)
import MapKit
import SwiftUI
import XCTest

@testable import ViewInspector

@available(iOS 14.0, *)
class MapTests: XCTestCase {
    func testExtractionFromSingleViewContainer() throws {
        let sut = AnyView(Map(coordinateRegion: .constant(MKCoordinateRegion())))
        XCTAssertNoThrow(try sut.inspect().anyView().map())
    }

    func testExtractionFromMultipleViewContainer() throws {
        let view = HStack {
            Map(coordinateRegion: .constant(MKCoordinateRegion()))
            Map(coordinateRegion: .constant(MKCoordinateRegion()))
        }
        XCTAssertNoThrow(try view.inspect().hStack().map(0))
        XCTAssertNoThrow(try view.inspect().hStack().map(1))
    }

//    func testSearch() throws {
//        let view = AnyView(Map(coordinateRegion: .constant(MKCoordinateRegion())))
//        XCTAssertEqual(try view.inspect().find(ViewType.Map.self).pathToRoot, "anyView().map()")
//    }

    // MARK: - coordinateRegion()

    func testExternalCoordinateRegionValue() throws {
        let region = MKCoordinateRegion()
        let sut = Map(coordinateRegion: .constant(MKCoordinateRegion()))
        let value = try sut.inspect().map().coordinateRegion().wrappedValue
        XCTAssertEqual(value.center.latitude, region.center.latitude)
        XCTAssertEqual(value.center.longitude, region.center.longitude)
        XCTAssertEqual(value.span.latitudeDelta, region.span.latitudeDelta)
        XCTAssertEqual(value.span.longitudeDelta, region.span.longitudeDelta)
    }

    func testExtractingInteractionModes() throws {
        let region = MKCoordinateRegion()
        let sut = Map(coordinateRegion: .constant(region),
                      interactionModes: .pan,
                      showsUserLocation: false,
                      userTrackingMode: .constant(.none))
        let value = try sut.inspect().map().interactionModes()
        XCTAssertEqual(value, .pan)
    }

    func testExtractingShowsUserLocation() throws {
        let region = MKCoordinateRegion()
        let sut = Map(coordinateRegion: .constant(region),
                      interactionModes: .all,
                      showsUserLocation: true,
                      userTrackingMode: .constant(.none))
        let value = try sut.inspect().map().showsUserLocation()
        XCTAssertEqual(value, true)
    }

    func testExtractingUserTrackingMode() throws {
        let region = MKCoordinateRegion()
        let sut = Map(coordinateRegion: .constant(region),
                      interactionModes: .all,
                      showsUserLocation: true,
                      userTrackingMode: .constant(.follow))
        let value = try sut.inspect().map().userTrackingMode()
        XCTAssertEqual(value?.wrappedValue, .follow)
    }
}
#endif
