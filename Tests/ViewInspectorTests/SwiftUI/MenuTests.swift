import XCTest
import SwiftUI
@testable import ViewInspector

#if os(iOS) || os(macOS)
@available(iOS 13.0, macOS 10.15, *)
@available(tvOS, unavailable)
final class MenuTests: XCTestCase {
    
    func testExtractionFromSingleViewContainer() throws {
        guard #available(iOS 14, tvOS 14, macOS 11.0, *) else { return }
        let view = AnyView(Menu("abc", content: { EmptyView() }))
        XCTAssertNoThrow(try view.inspect().anyView().menu())
    }
    
    func testExtractionFromMultipleViewContainer() throws {
        guard #available(iOS 14, tvOS 14, macOS 11.0, *) else { return }
        let view = HStack {
            Text("")
            Menu("abc", content: { EmptyView() })
            Text("")
        }
        XCTAssertNoThrow(try view.inspect().hStack().menu(1))
    }
    
    func testSearch() throws {
        guard #available(iOS 14, tvOS 14, macOS 11.0, *) else { return }
        let view = AnyView(Menu(content: {
            HStack { Text("abc") }
        }, label: {
            VStack { Text("xyz") }
        }))
        XCTAssertEqual(try view.inspect().find(ViewType.Menu.self).pathToRoot,
                       "anyView().menu()")
        XCTAssertEqual(try view.inspect().find(text: "abc").pathToRoot,
                       "anyView().menu().hStack(0).text(0)")
        XCTAssertEqual(try view.inspect().find(text: "xyz").pathToRoot,
                       "anyView().menu().labelView().vStack().text(0)")
    }
    
    func testLabelInspection() throws {
        guard #available(iOS 14, tvOS 14, macOS 11.0, *) else { return }
        let view = Menu(content: {
            HStack { Text("abc") }
        }, label: {
            VStack { Text("xyz") }
        })
        let sut = try view.inspect().menu().labelView().vStack().text(0).string()
        XCTAssertEqual(sut, "xyz")
    }
    
    func testContentInspection() throws {
        guard #available(iOS 14, tvOS 14, macOS 11.0, *) else { return }
        let view = Menu(content: {
            HStack { Text("abc") }
        }, label: {
            VStack { Text("xyz") }
        })
        let sut = try view.inspect().menu().hStack(0).text(0).string()
        XCTAssertEqual(sut, "abc")
    }
    
    func testLabelStyleInspection() throws {
        guard #available(iOS 14, tvOS 14, macOS 11.0, *) else { return }
        let sut = EmptyView().menuStyle(DefaultMenuStyle())
        XCTAssertTrue(try sut.inspect().menuStyle() is DefaultMenuStyle)
    }
    
    func testCustomMenuStyleInspection() throws {
        guard #available(iOS 14, tvOS 14, macOS 11.0, *) else { return }
        let sut = TestMenuStyle()
        let menu = try sut.inspect().vStack().menu(0)
        XCTAssertEqual(try menu.blur().radius, 3)
        XCTAssertEqual(try sut.inspect().find(ViewType.StyleConfiguration.Content.self).pathToRoot,
                       "vStack().menu(0).styleConfigurationContent(0)")
    }
}

@available(iOS 14.0, macOS 11.0, *)
@available(tvOS, unavailable)
private struct TestMenuStyle: MenuStyle {
    func makeBody(configuration: Configuration) -> some View {
        VStack {
            Menu(configuration)
                .blur(radius: 3)
        }
    }
}
#endif
