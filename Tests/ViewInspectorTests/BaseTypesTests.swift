import XCTest
import SwiftUI
@testable import ViewInspector

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
final class BaseTypesTests: XCTestCase {
    
    func testInspectionErrorDescription() throws {
        let desc1 = InspectionError.typeMismatch(factual: "1", expected: "2")
            .localizedDescription
        let desc2 = InspectionError.attributeNotFound(label: "1", type: "2")
            .localizedDescription
        let desc3 = InspectionError.viewIndexOutOfBounds(index: 5, count: 3)
            .localizedDescription
        let desc4 = InspectionError.viewNotFound(parent: "Optional<Text>").localizedDescription
        let desc5 = InspectionError.modifierNotFound(parent: "Text", modifier: "onAppear").localizedDescription
        let desc6 = InspectionError.notSupported("Not supported").localizedDescription
        let desc7 = InspectionError.textAttribute("Not found").localizedDescription
        XCTAssertEqual(desc1, "Type mismatch: 1 is not 2")
        XCTAssertEqual(desc2, "2 does not have '1' attribute")
        XCTAssertEqual(desc3, "Enclosed view index '5' is out of bounds: '0 ..< 3'")
        XCTAssertEqual(desc4, "View for Optional<Text> is absent")
        XCTAssertEqual(desc5, "Text does not have 'onAppear' modifier")
        XCTAssertEqual(desc6, "Not supported")
        XCTAssertEqual(desc7, "Not found")
    }
    
    func testBindingExtension() {
        let sut = Binding(wrappedValue: false)
        XCTAssertFalse(sut.wrappedValue)
        sut.wrappedValue = true
        XCTAssertTrue(sut.wrappedValue)
    }
}

func XCTAssertThrows<T>(_ expression: @autoclosure () throws -> T, _ message: String,
                        file: StaticString = #file, line: UInt = #line) {
    do {
        _ = try expression()
        XCTFail("Expression did not throw any error")
    } catch let error {
        XCTAssertEqual(error.localizedDescription, message, file: file, line: line)
    }
}
