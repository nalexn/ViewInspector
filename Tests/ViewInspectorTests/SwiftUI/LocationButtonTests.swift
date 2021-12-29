#if os(iOS) || os(watchOS)

import XCTest
import SwiftUI
import CoreLocationUI.CLLocationButton
@testable import ViewInspector

@available(iOS 13.0, watchOS 6.0, *)
@available(tvOS, unavailable)
@available(macOS, unavailable)
final class LocationButtonTests: XCTestCase {
    
    func testExtractionFromSingleViewContainer() throws {
        guard #available(iOS 15.0, watchOS 8.0, *) else { throw XCTSkip() }
        let view = AnyView(LocationButton { })
        XCTAssertNoThrow(try view.inspect().anyView().locationButton())
    }
    
    func testExtractionFromMultipleViewContainer() throws {
        guard #available(iOS 15.0, watchOS 8.0, *) else { throw XCTSkip() }
        let view = HStack {
            LocationButton { }
            LocationButton { }
        }
        XCTAssertNoThrow(try view.inspect().hStack().locationButton(0))
        XCTAssertNoThrow(try view.inspect().hStack().locationButton(1))
    }
    
    func testSearch() throws {
        guard #available(iOS 15.0, watchOS 8.0, *) else { throw XCTSkip() }
        let sut = AnyView(LocationButton { })
        XCTAssertEqual(try sut.inspect().find(ViewType.LocationButton.self).pathToRoot, "anyView().locationButton()")
    }
    
    func testTitle() throws {
        guard #available(iOS 15.0, watchOS 8.0, *) else { throw XCTSkip() }
        let sut = LocationButton(.shareMyCurrentLocation, action: { })
        XCTAssertEqual(try sut.inspect().locationButton().title(), .shareMyCurrentLocation)
    }
    
    func testTap() throws {
        guard #available(iOS 15.0, watchOS 8.0, *) else { throw XCTSkip() }
        let exp = XCTestExpectation(description: #function)
        let sut = LocationButton { exp.fulfill() }
        try sut.inspect().locationButton().tap()
        wait(for: [exp], timeout: 0.1)
    }
}
#endif
