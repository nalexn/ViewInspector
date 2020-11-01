import XCTest
import SwiftUI
@testable import ViewInspector

#if !os(macOS)
@available(iOS 14.0, macOS 11.0, *)
@available(tvOS, unavailable)
final class MenuTests: XCTestCase {
    
    func testExtractionFromSingleViewContainer() throws {
        let view = AnyView(Menu("abc", content: { EmptyView() }))
        XCTAssertNoThrow(try view.inspect().anyView().menu())
    }
    
    func testExtractionFromMultipleViewContainer() throws {
        let view = HStack {
            Text("")
            Menu("abc", content: { EmptyView() })
            Text("")
        }
        XCTAssertNoThrow(try view.inspect().hStack().menu(1))
    }
    
    func testLabelInspection() throws {
        let view = Menu(content: {
            HStack { Text("abc") }
        }, label: {
            VStack { Text("xyz") }
        })
        let sut = try view.inspect().menu().labelView().vStack().text(0).string()
        XCTAssertEqual(sut, "xyz")
    }
    
    func testContentInspection() throws {
        let view = Menu(content: {
            HStack { Text("abc") }
        }, label: {
            VStack { Text("xyz") }
        })
        let sut = try view.inspect().menu().hStack(0).text(0).string()
        XCTAssertEqual(sut, "abc")
    }
    
    func testCustomMenuStyleInspection() throws {
        let sut = TestMenuStyle()
        let menu = try sut.inspect().vStack().menu(0)
        XCTAssertEqual(try menu.blur().radius, 3)
    }
}

@available(iOS 14.0, macOS 11.0, *)
@available(tvOS, unavailable)
struct TestMenuStyle: MenuStyle {
    func makeBody(configuration: Configuration) -> some View {
        VStack {
            Menu(configuration)
                .blur(radius: 3)
        }
    }
}
#endif
