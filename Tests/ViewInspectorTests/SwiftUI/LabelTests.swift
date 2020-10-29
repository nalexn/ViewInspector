import XCTest
import SwiftUI
@testable import ViewInspector

#if !os(macOS)
@available(iOS 14.0, macOS 11.0, tvOS 14.0, *)
final class LabelTests: XCTestCase {
    
    func testInspect() throws {
        XCTAssertNoThrow(try Label("title", image: "image").inspect())
    }
    
    func testExtractionFromSingleViewContainer() throws {
        let view = AnyView(Label("title", image: "image"))
        XCTAssertNoThrow(try view.inspect().anyView().label())
    }
    
    func testExtractionFromMultipleViewContainer() throws {
        let view = HStack {
            Text("")
            Label("title", image: "image")
            Text("")
        }
        XCTAssertNoThrow(try view.inspect().hStack().label(1))
    }
    
    func testTitleInspection() throws {
        let view = Label(title: {
            HStack { Text("abc") }
        }, icon: {
            VStack { Text("xyz") }
        })
        let sut = try view.inspect().label().title().hStack(0).text(0).string()
        XCTAssertEqual(sut, "abc")
    }
    
    func testIconInspection() throws {
        let view = Label(title: {
            HStack { Text("abc") }
        }, icon: {
            VStack { Text("xyz") }
        })
        let sut = try view.inspect().label().icon().vStack(0).text(0).string()
        XCTAssertEqual(sut, "xyz")
    }
}
#endif
