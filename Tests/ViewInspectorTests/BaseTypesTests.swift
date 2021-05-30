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
        let desc51 = InspectionError
            .modifierNotFound(parent: "Text", modifier: "onAppear", index: 0).localizedDescription
        let desc52 = InspectionError
            .modifierNotFound(parent: "Text", modifier: "onAppear", index: 3).localizedDescription
        let desc6 = InspectionError.notSupported("Not supported").localizedDescription
        let desc7 = InspectionError.textAttribute("Not found").localizedDescription
        let desc81 = InspectionError.searchFailure(skipped: 0, blockers: ["Abc", "Def"]).localizedDescription
        let desc82 = InspectionError.searchFailure(skipped: 1, blockers: ["Xyz"]).localizedDescription
        let desc83 = InspectionError.searchFailure(skipped: 3, blockers: []).localizedDescription
        let desc9 = InspectionError.callbackNotFound(parent: "Abc", callback: "Xyz").localizedDescription
        let desc10 = InspectionError.unresponsiveControl(name: "Abc", reason: "Def").localizedDescription
        XCTAssertEqual(desc1, "Type mismatch: 1 is not 2")
        XCTAssertEqual(desc2, "2 does not have '1' attribute")
        XCTAssertEqual(desc3, "Enclosed view index '5' is out of bounds: '0 ..< 3'")
        XCTAssertEqual(desc4, "View for Optional<Text> is absent")
        XCTAssertEqual(desc51, "Text does not have 'onAppear' modifier")
        XCTAssertEqual(desc52, "Text does not have 'onAppear' modifier at index 3")
        XCTAssertEqual(desc6, "Not supported")
        XCTAssertEqual(desc7, "Not found")
        XCTAssertEqual(desc81, "Search did not find a match. Possible blockers: Abc, Def")
        XCTAssertEqual(desc82, "Search did only find 1 matches. Possible blockers: Xyz")
        XCTAssertEqual(desc83, "Search did only find 3 matches")
        XCTAssertEqual(desc9, "Abc does not have 'Xyz' callback")
        XCTAssertEqual(desc10, "Abc is unresponsive: Def")
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
