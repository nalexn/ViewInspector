import XCTest
import SwiftUI
@testable import ViewInspector

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
final class TextTests: XCTestCase {
    
    func testExtractionFromSingleViewContainer() throws {
        let view = AnyView(Text("Test"))
        XCTAssertNoThrow(try view.inspect().anyView().text())
    }
    
    func testExtractionFromMultipleViewContainer() throws {
        let view = HStack { Text("Test"); Text("Test") }
        XCTAssertNoThrow(try view.inspect().hStack().text(0))
        XCTAssertNoThrow(try view.inspect().hStack().text(1))
    }
    
    // MARK: - string()
    
    func testExternalStringValue() throws {
        let string = "Test"
        let sut = Text(string)
        let value = try sut.inspect().text().string()
        XCTAssertEqual(value, string)
    }
    
    func testLocalizableStringNoParams() throws {
        let sut = Text("Test")
        let value = try sut.inspect().text().string()
        XCTAssertEqual(value, "Test")
    }
    
    func testVerbatimStringNoParams() throws {
        let sut = Text(verbatim: "Test")
        let value = try sut.inspect().text().string()
        XCTAssertEqual(value, "Test")
    }
    
    func testStringWithOneParam() throws {
        let view = Text("Test \(12)")
        let sut = try view.inspect().text().string()
        XCTAssertEqual(sut, "Test 12")
    }
    
    func testStringWithMultipleParams() throws {
        let sut = Text(verbatim: "Test \(12) \(5.7) \("abc")")
        let value = try sut.inspect().text().string()
        XCTAssertEqual(value, "Test 12 5.7 abc")
    }
    
    func testStringWithSpecifier() throws {
        let sut = Text("\(12.541, specifier: "%.2f")")
        let value = try sut.inspect().text().string()
        XCTAssertEqual(value, "12.54")
    }
    
    func testObjectInitialization() throws {
        guard #available(iOS 14.0, macOS 11.0, tvOS 11.0, *)
        else { return }
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        let sut = Text(NSNumber(value: 12.541), formatter: formatter)
        let value = try sut.inspect().text().string()
        XCTAssertEqual(value, "12.54")
    }
    
    func testObjectInterpolation() throws {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        let sut = Text("\(NSNumber(value: 12.541), formatter: formatter)")
        let value = try sut.inspect().text().string()
        XCTAssertEqual(value, "12.54")
    }
    
    func testReferenceConvertibleInitialization() throws {
        guard #available(iOS 14.0, macOS 11.0, tvOS 11.0, *)
        else { return }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-mm-ss"
        let date = Date(timeIntervalSinceReferenceDate: 123)
        let sut = Text(date, formatter: formatter)
        let value = try sut.inspect().text().string()
        XCTAssertEqual(value, formatter.string(from: date))
    }
    
    func testReferenceConvertibleInterpolation() throws {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-mm-ss"
        let date = Date(timeIntervalSinceReferenceDate: 123)
        let sut = Text("\(date, formatter: formatter)")
        let value = try sut.inspect().text().string()
        XCTAssertEqual(value, formatter.string(from: date))
    }
    
    func testTextInterpolation() throws {
        guard #available(iOS 14.0, macOS 11.0, tvOS 11.0, *)
        else { return }
        let sut = Text("abc \(Text("xyz").bold()) \(Text("qwe"))")
        let value = try sut.inspect().text().string()
        XCTAssertEqual(value, "abc xyz qwe")
    }
    
    func testImageInterpolation() throws {
        guard #available(iOS 14.0, macOS 11.0, tvOS 11.0, *)
        else { return }
        let sut = Text("abc \(Image("test"))")
        let value = try sut.inspect().text().string()
        XCTAssertEqual(value, "abc Image(\"test\")")
    }
    
    func testCustomTextInterpolation() throws {
        let sut = Text("abc \(braces: "test")")
        let value = try sut.inspect().text().string()
        XCTAssertEqual(value, "abc [test]")
    }
    
    func testConcatenatedTexts() throws {
        let sut = Text("Test") + Text("Abc").bold() + Text(verbatim: "123")
        let value = try sut.inspect().text().string()
        XCTAssertEqual(value, "TestAbc123")
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension LocalizedStringKey.StringInterpolation {
    mutating func appendInterpolation(braces: String) {
        appendLiteral("[\(braces)]")
    }
}
