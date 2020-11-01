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

// MARK: - View Modifiers

@available(iOS 14.0, macOS 11.0, tvOS 14.0, *)
final class GlobalModifiersForLabel: XCTestCase {
    
    func testLabelStyle() throws {
        let sut = EmptyView().labelStyle(IconOnlyLabelStyle())
        XCTAssertNoThrow(try sut.inspect().emptyView())
    }
    
    func testLabelStyleInspection() throws {
        let sut = EmptyView().labelStyle(IconOnlyLabelStyle())
        XCTAssertTrue(try sut.inspect().labelStyle() is IconOnlyLabelStyle)
    }
    
    func testCustomLabelStyleInspection() throws {
        let sut = TestLabelStyle()
        let title = try sut.inspect().vStack().styleConfigurationTitle(0)
        let icon = try sut.inspect().vStack().styleConfigurationIcon(1)
        XCTAssertEqual(try title.blur().radius, 3)
        XCTAssertEqual(try icon.padding(), EdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5))
        XCTAssertThrows(try EmptyView().inspect().styleConfigurationTitle(),
                        "Type mismatch: EmptyView is not Title")
        XCTAssertThrows(try EmptyView().inspect().styleConfigurationIcon(),
                        "Type mismatch: EmptyView is not Icon")
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
#endif
