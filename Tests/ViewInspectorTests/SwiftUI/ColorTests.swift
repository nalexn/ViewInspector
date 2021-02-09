import XCTest
import SwiftUI
@testable import ViewInspector

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
final class ColorTests: XCTestCase {
    
    func testInspect() throws {
        XCTAssertNoThrow(try Color.red.inspect())
    }
    
    func testExtractionFromSingleViewContainer() throws {
        let view = AnyView(Color(red: 1, green: 0.5, blue: 0))
        XCTAssertNoThrow(try view.inspect().anyView().color())
    }
    
    func testExtractionFromMultipleViewContainer() throws {
        let view = HStack {
            Text("")
            Color.blue
            Text("")
            Color(hue: 1, saturation: 0.5, brightness: 0.25)
        }
        XCTAssertNoThrow(try view.inspect().hStack().color(1))
        XCTAssertNoThrow(try view.inspect().hStack().color(3))
    }
    
    func testSearch() throws {
        let view = Group { Color.red }
        XCTAssertEqual(try view.inspect().find(ViewType.Color.self).pathToRoot,
                       "group().color(0)")
    }
    
    func testValue() throws {
        let color = Color(red: 0.5, green: 0.25, blue: 1)
        let sut = try color.inspect().color().value()
        XCTAssertEqual(sut, color)
    }
    
    func testRGBA() throws {
        let tupleToArray: ((Float, Float, Float, Float)) -> [Float] = {
            [$0.0, $0.1, $0.2, $0.3]
        }
        
        let color1 = Color(.sRGBLinear, red: 0.1, green: 0.2, blue: 0.3, opacity: 0.9)
        let rgba1 = try color1.inspect().color().rgba()
        XCTAssertEqual(tupleToArray(rgba1), [0.1, 0.2, 0.3, 0.9])
        
        let color2 = Color(red: 0.1, green: 0.2, blue: 0.3, opacity: 0.9)
        let rgba2 = try color2.inspect().color().rgba()
        // .sRGB color space converts the original values.
        // They are NOT 0.1, 0.2 and 0.3
        XCTAssertNotEqual(tupleToArray(rgba2), [0.1, 0.2, 0.3, 0.9])
        
        let color3 = Color(.displayP3, red: 0.1, green: 0.2, blue: 0.3, opacity: 0.9)
        let rgba3 = try color3.inspect().color().rgba()
        XCTAssertEqual(tupleToArray(rgba3), [0.1, 0.2, 0.3, 0.9])
    }
    
    func testRGBAError() throws {
        XCTAssertThrows(try Color.accentColor.inspect().color().rgba(),
                        "RGBA values are not available")
    }
    
    func testName() throws {
        let color = Color("abc")
        XCTAssertEqual(try color.inspect().color().name(), "abc")
    }
    
    func testNameError() throws {
        XCTAssertThrows(try Color.accentColor.inspect().color().name(),
                        "Color name is not available")
    }
}
