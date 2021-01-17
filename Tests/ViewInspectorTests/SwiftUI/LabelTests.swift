import XCTest
import SwiftUI
@testable import ViewInspector

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
final class LabelTests: XCTestCase {
    
    func testInspect() throws {
        guard #available(iOS 14, macOS 11.0, tvOS 14.0, *) else { return }
        XCTAssertNoThrow(try Label("title", image: "image").inspect())
    }
    
    func testExtractionFromSingleViewContainer() throws {
        guard #available(iOS 14, macOS 11.0, tvOS 14.0, *) else { return }
        let view = AnyView(Label("title", image: "image"))
        XCTAssertNoThrow(try view.inspect().anyView().label())
    }
    
    func testExtractionFromMultipleViewContainer() throws {
        guard #available(iOS 14, macOS 11.0, tvOS 14.0, *) else { return }
        let view = HStack {
            Text("")
            Label("title", image: "image")
            Text("")
        }
        XCTAssertNoThrow(try view.inspect().hStack().label(1))
    }
    
    func testSearch() throws {
        guard #available(iOS 14, macOS 11.0, tvOS 14.0, *) else { return }
        let view = HStack { Label("tx", image: "img") }
        XCTAssertEqual(try view.inspect().find(ViewType.Label.self).pathToRoot,
                       "hStack().label(0)")
        XCTAssertEqual(try view.inspect().find(text: "tx").pathToRoot,
                       "hStack().label(0).title().text()")
        XCTAssertEqual(try view.inspect().find(text: "img").pathToRoot,
                       "hStack().label(0).icon().image().labelView().text()")
    }
    
    func testTitleInspection() throws {
        guard #available(iOS 14, macOS 11.0, tvOS 14.0, *) else { return }
        let view = Label(title: {
            HStack { Text("abc") }
        }, icon: {
            VStack { Text("xyz") }
        })
        let sut = try view.inspect().label().title().hStack(0).text(0).string()
        XCTAssertEqual(sut, "abc")
    }
    
    func testIconInspection() throws {
        guard #available(iOS 14, macOS 11.0, tvOS 14.0, *) else { return }
        let view = Label(title: {
            HStack { Text("abc") }
        }, icon: {
            VStack { Text("xyz") }
        })
        let sut = try view.inspect().label().icon().vStack(0).text(0).string()
        XCTAssertEqual(sut, "xyz")
    }
}

// MARK: - View Modifiers

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
final class GlobalModifiersForLabel: XCTestCase {
    
    func testLabelStyle() throws {
        guard #available(iOS 14, macOS 11.0, tvOS 14.0, *) else { return }
        let sut = EmptyView().labelStyle(IconOnlyLabelStyle())
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testLabelStyleInspection() throws {
        guard #available(iOS 14, macOS 11.0, tvOS 14.0, *) else { return }
        let sut = EmptyView().labelStyle(IconOnlyLabelStyle())
        XCTAssertTrue(try sut.inspect().labelStyle() is IconOnlyLabelStyle)
    }
    
    func testCustomLabelStyleInspection() throws {
        guard #available(iOS 14, macOS 11.0, tvOS 14.0, *) else { return }
        let sut = TestLabelStyle()
        let title = try sut.inspect().vStack().styleConfigurationTitle(0)
        let icon = try sut.inspect().vStack().styleConfigurationIcon(1)
        XCTAssertEqual(try title.blur().radius, 3)
        XCTAssertEqual(try icon.padding(), EdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5))
        XCTAssertThrows(try EmptyView().inspect().styleConfigurationTitle(),
            "styleConfigurationTitle() found EmptyView instead of LabelStyleConfiguration.Title")
        XCTAssertThrows(try EmptyView().inspect().styleConfigurationIcon(),
            "styleConfigurationIcon() found EmptyView instead of LabelStyleConfiguration.Icon")
        XCTAssertEqual(try sut.inspect().find(ViewType.StyleConfiguration.Title.self).pathToRoot,
                       "vStack().styleConfigurationTitle(0)")
        XCTAssertEqual(try sut.inspect().find(ViewType.StyleConfiguration.Icon.self).pathToRoot,
                       "vStack().styleConfigurationIcon(1)")
    }
}

@available(iOS 14.0, macOS 11.0, tvOS 14.0, *)
struct TestLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        VStack {
            configuration.title
                .blur(radius: 3)
            configuration.icon
                .padding(5)
        }
    }
}
