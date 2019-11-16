import XCTest
import SwiftUI
@testable import ViewInspector

final class TextTests: XCTestCase {
    
    // MARK: - string()
    
    func testLocalizableStringNoParams() throws {
        let view = Text("Test")
        let sut = try view.inspect().string()
        XCTAssertEqual(sut, "Test")
    }
    
    func testLocalizableStringWithOneParam() throws {
        let view = Text("Test \(12)")
        let sut = try view.inspect().string()
        XCTAssertEqual(sut, "Test 12")
    }
    
    func testLocalizableStringWithMultipleParams() throws {
        let view = Text("Test \(12) \(5.7) \("abc")")
        let sut = try view.inspect().string()
        XCTAssertEqual(sut, "Test 12 5.7 abc")
    }
    
    func testExternalStringValue() throws {
        let string = "Test"
        let view = Text(string)
        let sut = try view.inspect().string()
        XCTAssertEqual(sut, string)
    }
    
    static var allTests = [
        ("testLocalizableStringNoParams", testLocalizableStringNoParams),
        ("testLocalizableStringWithOneParam", testLocalizableStringWithOneParam),
        ("testLocalizableStringWithMultipleParams", testLocalizableStringWithMultipleParams),
        ("testExternalStringValue", testExternalStringValue),
    ]
}
