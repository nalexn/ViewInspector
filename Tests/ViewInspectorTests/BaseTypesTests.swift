import XCTest
import SwiftUI
@testable import ViewInspector

final class BaseTypesTests: XCTestCase {
    
    func testInspectionErrorDescription() throws {
        let desc1 = InspectionError.typeMismatch(factual: "1", expected: "2")
            .localizedDescription
        let desc2 = InspectionError.attributeNotFound(label: "1", type: "2")
            .localizedDescription
        let desc3 = InspectionError.viewIndexOutOfBounds(index: 5, count: 3)
            .localizedDescription
        let desc4 = InspectionError.notSupported("Not supported").localizedDescription
        XCTAssertEqual(desc1, "Type mismatch: 1 is not 2")
        XCTAssertEqual(desc2, "2 does not have '1' attribute")
        XCTAssertEqual(desc3, "Enclosed view index '5' is out of bounds: '0 ..< 3'")
        XCTAssertEqual(desc4, "ViewInspector: Not supported")
    }
}
