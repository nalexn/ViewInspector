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
    
    func testSearch() throws {
        let view = AnyView(Text("abc"))
        XCTAssertEqual(try view.inspect().find(ViewType.Text.self).pathToRoot, "anyView().text()")
        XCTAssertEqual(try view.inspect().find(text: "abc").pathToRoot, "anyView().text()")
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
    
    func testResourceLocalizationStringNoParams() throws {
        guard let bundle = Bundle.testResources else { return }
        let sut = Text("Test", tableName: "Test", bundle: bundle)
        let text = try sut.inspect().text()
        let value1 = try text.string()
        XCTAssertEqual(value1, "Test")
        let value2 = try text.string(locale: Locale(identifier: "en"))
        XCTAssertEqual(value2, "Test_en")
        let value3 = try text.string(locale: Locale(identifier: "en_AU"))
        XCTAssertEqual(value3, "Test_en_au")
        let value4 = try text.string(locale: Locale(identifier: "ru"))
        XCTAssertEqual(value4, "Тест_ru")
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
        guard #available(iOS 14.0, macOS 11.0, tvOS 14.0, *)
        else { return }
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        formatter.locale = Locale(identifier: "en")
        let sut = Text(NSNumber(value: 12.541), formatter: formatter)
        let value1 = try sut.inspect().text().string()
        XCTAssertEqual(value1, "12.54")
        formatter.locale = Locale(identifier: "ru")
        let value2 = try sut.inspect().text().string()
        XCTAssertEqual(value2, "12,54")
    }
    
    func testObjectInterpolation() throws {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        formatter.locale = Locale(identifier: "en")
        let sut = Text("\(NSNumber(value: 12.541), formatter: formatter)")
        let value = try sut.inspect().text().string()
        XCTAssertEqual(value, "12.54")
    }
    
    func testReferenceConvertibleInitialization() throws {
        guard #available(iOS 14.0, macOS 11.0, tvOS 14.0, *)
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
    
    func testDateStyleInitialization() throws {
        guard #available(iOS 14.0, macOS 11.0, tvOS 14.0, *)
        else { return }
        let date = Date(timeIntervalSinceReferenceDate: 123)
        let sut = Text(date, style: .timer)
        XCTAssertThrows(try sut.inspect().text().string(),
                        "Inspection of formatted Date is currently not supported")
    }
    
    func testDateIntervalInitialization() throws {
        guard #available(iOS 14.0, macOS 11.0, tvOS 14.0, *)
        else { return }
        let date1 = Date(timeIntervalSinceReferenceDate: 123)
        let date2 = Date(timeIntervalSinceReferenceDate: 123456)
        let sut1 = Text(date1...date2)
        XCTAssertThrows(try sut1.inspect().text().string(),
                        "Inspection of formatted Date is currently not supported")
        let interval = DateInterval(start: date1, end: date2)
        let sut2 = Text(interval)
        XCTAssertThrows(try sut2.inspect().text().string(),
                        "Inspection of formatted Date is currently not supported")
    }
    
    func testTextInterpolation() throws {
        guard #available(iOS 14.0, macOS 11.0, tvOS 14.0, *)
        else { return }
        let sut = Text("abc \(Text("xyz").bold()) \(Text("qwe"))")
        let value = try sut.inspect().text().string()
        XCTAssertEqual(value, "abc xyz qwe")
    }
    
    func testImageInterpolation() throws {
        guard #available(iOS 14.0, macOS 11.0, tvOS 14.0, *)
        else { return }
        let sut = Text("abc \(Image("test"))")
        let value = try sut.inspect().text().string()
        XCTAssertEqual(value, "abc Image('test')")
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
    
    func testImageExtraction() throws {
        guard #available(iOS 14.0, macOS 11.0, tvOS 14.0, *)
        else { return }
        let image1 = Image("abc").antialiased(true)
        let image2 = Image("def").resizable()
        let image3 = Image("xyz")
        let sut = Text("Text \(image1) \(Text(image2))") + Text("\(42, specifier: "%d") \(image3)")
        let images = try sut.inspect().text().images()
        XCTAssertEqual(images, [image1, image2, image3])
        let string = try sut.inspect().text().string()
        XCTAssertEqual(string, "Text Image('abc') Image('def')42 Image('xyz')")
        let sut2 = Text(Date()...Date())
        XCTAssertEqual(try sut2.inspect().text().images(), [])
        let sut3 = Text("abc")
        XCTAssertEqual(try sut3.inspect().text().images(), [])
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
extension LocalizedStringKey.StringInterpolation {
    mutating func appendInterpolation(braces: String) {
        appendLiteral("[\(braces)]")
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
private extension Bundle {
    
    static var testResources: Bundle? = {
        let bundleName = "ViewInspector_ViewInspectorTests"

        let candidates = [
            Bundle.main.resourceURL,
            Bundle(for: TextTests.self).resourceURL,
            Bundle.main.bundleURL,
        ]

        for candidate in candidates {
            let bundlePath = candidate?.appendingPathComponent(bundleName + ".bundle")
            if let bundle = bundlePath.flatMap(Bundle.init(url:)) {
                return bundle
            }
        }
        
        return nil
    }()
}
