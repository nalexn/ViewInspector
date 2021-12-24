import XCTest
import SwiftUI
import CoreLocationUI.CLLocationButton
@testable import ViewInspector

@available(iOS 15.0, watchOS 8.0, *)
@available(tvOS, unavailable)
@available(macOS, unavailable)
final class LocationButtonTests: XCTestCase {
    
    func testExtractionFromSingleViewContainer() throws {
        let view = AnyView(LocationButton { })
        XCTAssertNoThrow(try view.inspect().anyView().locationButton())
    }
    
    func testExtractionFromMultipleViewContainer() throws {
        let view = HStack {
            LocationButton { }
            LocationButton { }
        }
        XCTAssertNoThrow(try view.inspect().hStack().locationButton(0))
        XCTAssertNoThrow(try view.inspect().hStack().locationButton(1))
    }
    
    func testSearch() throws {
        let sut = AnyView(LocationButton { })
        XCTAssertEqual(try sut.inspect().find(ViewType.LocationButton.self).pathToRoot, "anyView().locationButton()")
    }
    
    func testTitle() throws {
        let sut = LocationButton(.shareMyCurrentLocation, action: { })
        XCTAssertEqual(try sut.inspect().locationButton().title(), .shareMyCurrentLocation)
    }
    
    func testTap() throws {
        let exp = XCTestExpectation(description: #function)
        let sut = LocationButton { exp.fulfill() }
        try sut.inspect().locationButton().tap()
        wait(for: [exp], timeout: 0.1)
    }
}
