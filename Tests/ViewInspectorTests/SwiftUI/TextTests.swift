import XCTest
import SwiftUI
@testable import ViewInspector

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
final class TextTests: XCTestCase {
    
    // MARK: - string()
    
    func testLocalizableStringNoParams() throws {
        let view = Text("Test")
        let sut = try view.inspect().text().string()
        XCTAssertEqual(sut, "Test")
    }
    
    func testLocalizableStringWithOneParam() throws {
        let view = Text("Test \(12)")
        let sut = try view.inspect().text().string()
        XCTAssertEqual(sut, "Test 12")
    }
    
    func testLocalizableStringWithMultipleParams() throws {
        let view = Text("Test \(12) \(5.7) \("abc")")
        let sut = try view.inspect().text().string()
        XCTAssertEqual(sut, "Test 12 5.7 abc")
    }
    
    func testExternalStringValue() throws {
        let string = "Test"
        let view = Text(string)
        let sut = try view.inspect().text().string()
        XCTAssertEqual(sut, string)
    }
    
    func testExtractionFromSingleViewContainer() throws {
        let view = AnyView(Text("Test"))
        XCTAssertNoThrow(try view.inspect().anyView().text())
    }
    
    func testExtractionFromMultipleViewContainer() throws {
        let view = HStack { Text("Test"); Text("Test") }
        XCTAssertNoThrow(try view.inspect().hStack().text(0))
        XCTAssertNoThrow(try view.inspect().hStack().text(1))
    }
}

// MARK: - View Modifiers

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
final class GlobalModifiersForText: XCTestCase {
    
    func testFont() throws {
        let sut = EmptyView().font(.body)
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testLineLimit() throws {
        let sut = EmptyView().lineLimit(5)
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testLineSpacing() throws {
        let sut = EmptyView().lineSpacing(5)
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testMultilineTextAlignment() throws {
        let sut = EmptyView().multilineTextAlignment(.center)
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testMinimumScaleFactor() throws {
        let sut = EmptyView().minimumScaleFactor(5)
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testTruncationMode() throws {
        let sut = EmptyView().truncationMode(.tail)
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testAllowsTightening() throws {
        let sut = EmptyView().allowsTightening(true)
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testFlipsForRightToLeftLayoutDirection() throws {
        let sut = EmptyView().flipsForRightToLeftLayoutDirection(true)
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
}
